#!/usr/bin/env python3
"""Report what each Claude Code session transcript and plan is, what it is
linked to, and hints on whether it is still needed.

Usage: sessions-report.py [-p PROJECT_SUBSTRING] [-o]   (-o: only orphans)

Per session it shows: title, first prompt, dates, size, prompt count, the
plan it wrote (plans/<slug>.md) and whether that plan was approved,
files it edited that are still uncommitted in git, continuation links,
background jobs, and the per-session folders (file-history, session-env).
"""
import collections, datetime as dt, glob, json, os, re, subprocess, sys, time

D = os.environ.get("CLAUDE_CONFIG_DIR", os.path.expanduser("~/.claude"))
NOW = time.time()
EDIT_TOOLS = {"Write", "Edit", "MultiEdit", "NotebookEdit"}
# Slash commands that are housekeeping, not a real prompt.
NOISE_CMDS = {"/clear", "/model", "/compact", "/resume", "/config", "/exit", "/rewind",
              "/effort", "/fast", "/cost", "/status", "/help", "/login", "/logout", "/theme"}

args = sys.argv[1:]
only_orphans = "-o" in args
pfilter = args[args.index("-p") + 1] if "-p" in args else None


def size(path):
    if os.path.isfile(path):
        return os.path.getsize(path)
    t = 0
    for r, _, fs in os.walk(path):
        for f in fs:
            try:
                t += os.path.getsize(os.path.join(r, f))
            except OSError:
                pass
    return t


def hsize(n):
    for u in "BKMG":
        if n < 1024:
            return f"{n:.0f}{u}" if u == "B" else f"{n:.1f}{u}"
        n /= 1024
    return f"{n:.1f}T"


def ts(s):
    try:
        return dt.datetime.fromisoformat(s.replace("Z", "+00:00")).timestamp()
    except Exception:
        return None


def records(path):
    with open(path, errors="replace") as fh:
        for line in fh:
            try:
                yield json.loads(line)
            except ValueError:
                continue


def prompt_text(rec):
    """Return the user's typed prompt for a user record, or None."""
    if rec.get("type") != "user" or rec.get("isMeta") or rec.get("isSidechain"):
        return None
    c = rec.get("message", {}).get("content")
    if isinstance(c, list):
        texts = [b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text"]
        if not texts or any(isinstance(b, dict) and b.get("type") == "tool_result" for b in c):
            return None
        c = " ".join(texts)
    if not isinstance(c, str):
        return None
    m = re.search(r"<command-name>(/[^<]+)</command-name>.*?<command-args>([^<]*)", c, re.S)
    if m:
        if m.group(1) in NOISE_CMDS:
            return None
        return (m.group(1) + " " + m.group(2)).strip()
    if c.startswith("<"):
        return None
    return c


# ---- live sessions, jobs ---------------------------------------------------
live = set()
for f in glob.glob(f"{D}/sessions/*.json"):
    try:
        live.add(json.load(open(f))["sessionId"])
    except Exception:
        pass

jobs = {}
for f in glob.glob(f"{D}/jobs/*/state.json"):
    try:
        st = json.load(open(f))
        jobs[os.path.basename(os.path.dirname(f))] = st
    except Exception:
        pass

# ---- scan transcripts --------------------------------------------------------
sessions = {}
continued_from = collections.defaultdict(list)
for path in sorted(glob.glob(f"{D}/projects/*/*.jsonl")):
    proj = os.path.basename(os.path.dirname(path))
    sid = os.path.basename(path)[:-6]
    s = dict(sid=sid, proj=proj, path=path, titles={}, prompts=[], first=None, last=None,
             cwds=collections.Counter(), branches=set(), slugs=set(), edits=set(),
             plan_written=set(), plan_approved=False, plan_rejected=False, cont_to=None, subagents=0)
    pending_exit = set()
    files = [path] + glob.glob(f"{path[:-6]}/subagents/*.jsonl")
    s["subagents"] = len(files) - 1
    for fi, fpath in enumerate(files):
        for r in records(fpath):
            t = r.get("type")
            if fi == 0:
                if t in ("custom-title", "ai-title", "agent-name"):
                    s["titles"][t] = r.get("customTitle") or r.get("aiTitle") or r.get("agentName")
                elif t == "continued-in":
                    s["cont_to"] = r.get("continuedInSessionId")
                    continued_from[s["cont_to"]].append(sid)
                p = prompt_text(r)
                if p:
                    s["prompts"].append(p)
                if r.get("cwd"):
                    s["cwds"][r["cwd"]] += 1
                if r.get("gitBranch"):
                    s["branches"].add(r["gitBranch"])
                if r.get("slug"):
                    s["slugs"].add(r["slug"])
                x = ts(r.get("timestamp", ""))
                if x:
                    s["first"] = min(s["first"] or x, x)
                    s["last"] = max(s["last"] or x, x)
            msg = r.get("message") or {}
            content = msg.get("content") if isinstance(msg, dict) else None
            if not isinstance(content, list):
                continue
            for b in content:
                if not isinstance(b, dict):
                    continue
                if b.get("type") == "tool_use":
                    fp = (b.get("input") or {}).get("file_path") or (b.get("input") or {}).get("notebook_path")
                    if b.get("name") in EDIT_TOOLS and fp:
                        if "/.claude/plans/" in fp:
                            s["plan_written"].add(os.path.basename(fp)[:-3])
                        elif not re.search(r"/\.claude/projects/[^/]+/memory/|^/tmp/", fp):
                            s["edits"].add(fp)
                    if b.get("name") == "ExitPlanMode" and fi == 0:
                        pending_exit.add(b.get("id"))
                elif b.get("type") == "tool_result" and b.get("tool_use_id") in pending_exit:
                    txt = json.dumps(b.get("content"))
                    if "approved your plan" in txt:
                        s["plan_approved"] = True
                    else:
                        s["plan_rejected"] = True
    if not s["last"]:
        s["last"] = os.path.getmtime(path)
        s["first"] = s["first"] or s["last"]
    s["size"] = size(path) + (size(path[:-6]) if os.path.isdir(path[:-6]) else 0)
    s["cwd"] = s["cwds"].most_common(1)[0][0] if s["cwds"] else None
    sessions[sid] = s

# ---- git: which edited files are still uncommitted ---------------------------
_git_cache = {}


def git_dirty(directory):
    """Return (toplevel, set of dirty absolute paths) for the repo holding directory."""
    while directory and not os.path.isdir(directory):
        directory = os.path.dirname(directory)
    if not directory:
        return None, set()
    if directory in _git_cache:
        return _git_cache[directory]
    res = (None, set())
    try:
        top = subprocess.run(["git", "-C", directory, "rev-parse", "--show-toplevel"],
                             capture_output=True, text=True, timeout=10).stdout.strip()
        if top:
            out = subprocess.run(["git", "-C", top, "status", "--porcelain", "-z", "-uall"],
                                 capture_output=True, text=True, timeout=30).stdout
            dirty = {os.path.join(top, e[3:]) for e in out.split("\0") if len(e) > 3}
            res = (top, dirty)
    except Exception:
        pass
    _git_cache[directory] = res
    return res


# A dirty file is blamed only on the most recent session that edited it.
last_editor = {}
for s in sessions.values():
    for f in s["edits"]:
        if f not in last_editor or s["last"] > sessions[last_editor[f]]["last"]:
            last_editor[f] = s["sid"]
for s in sessions.values():
    s["uncommitted"], s["no_git"], s["gone"] = set(), set(), set()
    for f in s["edits"]:
        if not os.path.exists(f):
            s["gone"].add(f)
            continue
        top, dirty = git_dirty(os.path.dirname(f))
        if top is None:
            s["no_git"].add(f)
        elif f in dirty and last_editor[f] == s["sid"]:
            s["uncommitted"].add(f)

# ---- plans ---------------------------------------------------------------------
slug_owner = {}
for s in sessions.values():
    for sl in s["slugs"] | s["plan_written"]:
        slug_owner.setdefault(sl, s["sid"])
plans = {}
for f in sorted(glob.glob(f"{D}/plans/*.md")):
    slug = os.path.basename(f)[:-3]
    head = next((l.strip("# \n") for l in open(f, errors="replace") if l.strip()), "")
    plans[slug] = dict(path=f, head=head, size=os.path.getsize(f),
                       mtime=os.path.getmtime(f), owner=slug_owner.get(slug))

# ---- per-session side folders and orphans -----------------------------------------
side = {}
for name in ("file-history", "session-env"):
    for d in glob.glob(f"{D}/{name}/*/"):
        sid = os.path.basename(d.rstrip("/"))
        side.setdefault(sid, {})[name] = size(d)
orphans = [(sid, v) for sid, v in side.items() if sid not in sessions]
orphan_jobs = [j for j in jobs if not any(sid.startswith(j) for sid in sessions)]


# ---- verdict hints ------------------------------------------------------------------
# KEEP  = something depends on it right now
# CHECK = deleting may lose the only context for unfinished work
# SAFE  = nothing depends on it; you only lose the ability to --resume / reread it
def hint(s):
    sid = s["sid"]
    job = next((st for j, st in jobs.items() if sid.startswith(j)), None)
    if sid in live:
        return "KEEP", "running right now"
    if job and job.get("state") not in ("done", "failed", "stopped"):
        return "KEEP", f"background job is {job.get('state')}"
    if s["uncommitted"]:
        return "CHECK", f"{len(s['uncommitted'])} file(s) it edited are still uncommitted"
    if s["cwd"] and not os.path.isdir(s["cwd"]):
        return "SAFE", "project folder no longer exists"
    if not s["prompts"] or (len(s["prompts"]) <= 1 and s["size"] < 300 * 1024):
        return "SAFE", "trivial (≤1 prompt)"
    if s["cont_to"] and s["cont_to"] in sessions:
        return "SAFE", "continued in a later session"
    return "SAFE", "nothing pending; edits committed or none"


def notes(s):
    out = []
    age = (NOW - s["last"]) / 86400
    if age < 3 and s["sid"] not in live:
        out.append(f"recent ({age:.1f}d ago): delete only if you won't --resume it")
    if s["no_git"]:
        out.append("edited outside git (old versions only in this transcript/file-history): "
                   + ", ".join(short(f) for f in sorted(s["no_git"])[:4]))
    return out


def fmt_t(x):
    return dt.datetime.fromtimestamp(x).strftime("%b %d %H:%M") if x else "?"


# ---- output ---------------------------------------------------------------------------
B = "\033[1m" if sys.stdout.isatty() else ""
R = "\033[0m" if sys.stdout.isatty() else ""
COL = {"KEEP": "\033[32m", "CHECK": "\033[33m", "SAFE": "\033[2m"} if sys.stdout.isatty() else collections.defaultdict(str)
home = os.path.expanduser("~")
short = lambda p: p.replace(home, "~") if p else p

if not only_orphans:
    byproj = collections.defaultdict(list)
    for s in sessions.values():
        if pfilter and pfilter not in s["proj"]:
            continue
        byproj[s["proj"]].append(s)
    tally = collections.Counter()
    for proj in sorted(byproj, key=lambda p: -max(x["last"] for x in byproj[p])):
        ss = sorted(byproj[proj], key=lambda x: -x["last"])
        cwd = next((x["cwd"] for x in ss if x["cwd"]), None)
        mem = glob.glob(f"{D}/projects/{proj}/memory/*")
        exists = "exists" if cwd and os.path.isdir(cwd) else "MISSING"
        print(f"\n{B}{short(cwd) or proj}{R}  [{exists}]  {len(ss)} session(s), "
              f"{hsize(sum(x['size'] for x in ss))}, memory files: {len(mem)} (kept separately)")
        for s in ss:
            v, why = hint(s)
            tally[v] += 1
            title = s["titles"].get("custom-title") or s["titles"].get("ai-title") or s["titles"].get("agent-name") or ""
            first = (s["prompts"][0] if s["prompts"] else "(no prompt)").replace("\n", " ")[:70]
            print(f"  {COL[v]}{v:5}{R} {s['sid'][:8]}  {fmt_t(s['first'])} → {fmt_t(s['last'])}  "
                  f"{hsize(s['size']):>6}  {len(s['prompts']):>3} prompts  {B}{title}{R}")
            print(f"        why: {why}")
            print(f"        first prompt: {first!r}")
            extra = notes(s)
            for sl in sorted(s["slugs"]):
                if sl in plans:
                    st = "approved" if s["plan_approved"] else ("rejected" if s["plan_rejected"] else "not submitted")
                    extra.append(f"plan: plans/{sl}.md ({st})")
            if s["uncommitted"]:
                extra.append("uncommitted: " + ", ".join(short(f) for f in sorted(s["uncommitted"])[:4]))
            if s["edits"]:
                extra.append(f"edited {len(s['edits'])} file(s)" + (f", {len(s['gone'])} since deleted" if s["gone"] else ""))
            if s["cont_to"]:
                extra.append(f"continued in → {s['cont_to'][:8]}")
            if continued_from.get(s["sid"]):
                extra.append("continued from ← " + ", ".join(x[:8] for x in continued_from[s["sid"]]))
            job = next((st for j, st in jobs.items() if s["sid"].startswith(j)), None)
            if job:
                extra.append(f"job: {job.get('state')} — {job.get('detail', '')[:60]}")
            if s["subagents"]:
                extra.append(f"{s['subagents']} subagent log(s)")
            sd = side.get(s["sid"], {})
            if sd:
                extra.append("side: " + ", ".join(f"{k} {hsize(v)}" for k, v in sd.items()))
            for e in extra:
                print(f"        {e}")
    print(f"\n{B}Totals:{R} " + ", ".join(f"{k} {v}" for k, v in sorted(tally.items())))

    have = {s["proj"] for s in sessions.values()}
    empty = [p for p in sorted(glob.glob(f"{D}/projects/*/")) if os.path.basename(p.rstrip("/")) not in have]
    if empty:
        print(f"\n{B}Project folders with no sessions{R} (memory is keyed by git root, transcripts by cwd)")
        for p in empty:
            mem = glob.glob(f"{p}memory/*")
            print(f"  {p}  memory files: {len(mem)}" + ("  ← KEEP: holds memory" if mem else "  (removable)"))

    print(f"\n{B}Plans (plans/<slug>.md — one per session that used plan mode){R}")
    for slug, p in sorted(plans.items(), key=lambda kv: -kv[1]["mtime"]):
        o = sessions.get(p["owner"])
        if o:
            st = "approved" if o["plan_approved"] else ("rejected" if o["plan_rejected"] else "never submitted")
            own = f"session {o['sid'][:8]} in {short(o['cwd'])} ({st}; verdict: {hint(o)[0]})"
        else:
            own = "ORPHAN — its session transcript is gone"
        print(f"  {slug}.md  {hsize(p['size'])}  {fmt_t(p['mtime'])}  \"{p['head'][:50]}\"\n      → {own}")

print(f"\n{B}Orphans (left behind by deleted sessions — always safe to remove){R}")
if not orphans and not orphan_jobs and all(p["owner"] in sessions for p in plans.values()):
    print("  none")
for sid, v in orphans:
    print(f"  {sid[:8]}: " + ", ".join(f"{D}/{k}/{sid} ({hsize(n)})" for k, n in v.items()))
for j in orphan_jobs:
    print(f"  {D}/jobs/{j} (job state: {jobs[j].get('state')})")
for slug, p in plans.items():
    if p["owner"] not in sessions:
        print(f"  {p['path']}")
