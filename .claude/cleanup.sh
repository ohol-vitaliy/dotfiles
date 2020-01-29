#!/bin/sh
# Clean temporary / regenerable data out of ~/.claude.
#
# Always kept: settings.json, .credentials.json, skills/, plugins (installed),
#              projects/*/memory/, sessions/ (live session registry).
#
# Usage: cleanup.sh [-n] [-t DAYS] [-a]
#   -n        dry run: only print what would be removed
#   -t DAYS   also remove session transcripts (projects/*/*.jsonl + their
#             subdirs) not modified in DAYS days
#   -a        aggressive: also remove plans/ and history.jsonl (prompt history)

set -eu

DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
DRY=0
DAYS=""
AGGR=0

while getopts "nt:ah" opt; do
    case "$opt" in
        n) DRY=1 ;;
        t) DAYS="$OPTARG" ;;
        a) AGGR=1 ;;
        *) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    esac
done

case "$DAYS" in
    ''|*[!0-9]*) [ -n "$DAYS" ] && { echo "-t needs a number of days" >&2; exit 1; } ;;
esac

cd "$DIR" || exit 1

if pgrep -x claude >/dev/null 2>&1; then
    echo "warning: claude is running; its in-use files may be recreated" >&2
fi

before=$(du -sk . | cut -f1)

rm_path() {
    for p in "$@"; do
        [ -e "$p" ] || continue
        if [ "$DRY" -eq 1 ]; then
            printf 'would remove: %s (%s)\n' "$p" "$(du -sh "$p" | cut -f1)"
        else
            rm -rf -- "$p"
            printf 'removed: %s\n' "$p"
        fi
    done
}

# Remove the contents of a directory but keep the directory itself.
empty_dir() {
    for d in "$@"; do
        [ -d "$d" ] || continue
        for p in "$d"/* "$d"/.[!.]*; do
            rm_path "$p"
        done
    done
}

# --- Always removed: regenerable state --------------------------------------

# cache/: changelog, model catalog, issue lookups.
#   Effect: re-downloaded on next start; first launch may be slightly slower.
empty_dir cache

# shell-snapshots/: captured shell env (aliases, functions, PATH) per session.
#   Effect: recreated when a session starts; running sessions may lose theirs.
empty_dir shell-snapshots

# session-env/: per-session environment state.
#   Effect: recreated on demand; old sessions lose nothing of value.
empty_dir session-env

# telemetry/: queued/failed analytics events waiting to be resent.
#   Effect: those events are simply never sent.
empty_dir telemetry

# downloads/: temporary downloads (e.g. update files).
#   Effect: none; re-downloaded if needed.
empty_dir downloads

# backups/: automatic copies of ~/.claude.json.
#   Effect: no way to restore ~/.claude.json if it gets corrupted
#   (new backups keep being made as Claude runs).
empty_dir backups

# file-history/: file snapshots taken before Claude edits them.
#   Effect: can no longer rewind (/rewind, Esc Esc) file edits made in
#   past sessions. Conversations themselves remain resumable.
empty_dir file-history

# Legacy / optional dirs (todo lists, debug logs, feature-flag cache,
# pasted-text cache, IDE lock files).
#   Effect: none for new sessions; old sessions' todo lists are gone.
empty_dir todos debug statsig paste-cache ide

# plugins/plugin-directory-cache-v2.json: cached plugin marketplace listing.
#   Effect: refetched next time you browse plugins. Installed plugins stay.
# stats-cache.json: cached usage stats.
#   Effect: recomputed from transcripts by /stats (stats for deleted
#   transcripts are gone for good).
rm_path plugins/plugin-directory-cache-v2.json stats-cache.json

# --- Optional (-t DAYS): old session transcripts ------------------------------
# projects/<project>/<session>.jsonl: the full conversation log.
# projects/<project>/<session>/: its subagent logs and large tool outputs.
#   Effect: those sessions disappear from --resume / --continue and can't
#   be reopened; /stats loses their usage. memory/ dirs are never touched,
#   so per-project memory survives.
if [ -n "$DAYS" ]; then
    for proj in projects/*/; do
        [ -d "$proj" ] || continue
        find "$proj" -maxdepth 1 -type f -name '*.jsonl' -mtime +"$DAYS" |
        while IFS= read -r f; do
            rm_path "$f" "${f%.jsonl}"
        done
    done
    # Drop project dirs left with nothing but an empty memory/ (or nothing)
    for proj in projects/*/; do
        [ -d "$proj" ] || continue
        if [ -z "$(ls -A "$proj" | grep -v '^memory$')" ] &&
           [ -z "$(ls -A "${proj}memory" 2>/dev/null)" ]; then
            rm_path "${proj%/}"
        fi
    done
fi

# --- Optional (-a): plans and prompt history ----------------------------------
# plans/: plans written in plan mode.
#   Effect: past plans are gone; sessions that referenced them can't reread them.
# history.jsonl: your typed prompts across all projects.
#   Effect: Up-arrow / Ctrl+R prompt history starts empty.
if [ "$AGGR" -eq 1 ]; then
    empty_dir plans
    rm_path history.jsonl
fi

if [ "$DRY" -eq 0 ]; then
    after=$(du -sk . | cut -f1)
    echo "freed $(( (before - after) / 1024 )) MiB (${before}K -> ${after}K)"
fi
