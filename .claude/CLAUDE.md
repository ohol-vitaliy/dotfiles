# How I want you to work

## Philosophy (all my projects)
- Code IS the config. Lists, thresholds, usernames and similar data live in the code on purpose; editing them means editing code. Don't suggest moving them into config files or env vars.
- Simplicity beats abstraction: no new abstraction, layer, struct/dataclass, config structure or persisted state file unless there's a dire need.
- In reviews, don't flag hard-coded config or missing layers. Raise only real bugs: wrong output, crashes, security holes.

## Do only what was asked
- Build only what was literally requested, in the simplest design that does it: fewest files, a blocking/synchronous minimal API. No ring buffers, state machines, counters, HAL/interface layers or directory structures unless asked.
- Ship the minimal version first. After that, suggestions for improvements are welcome, as a short list for me to decide on, never as code already written.
- When fixing review findings, make small in-place changes inside the existing functions. If a finding can only be fixed by adding new structure or state, say so and let me decide.
- Git: do exactly the operations requested. Commit on the current branch; never create branches, push or open PRs unless asked.
- Never add, move or remove access-control/auth checks without my explicit approval for that specific change. A general "fix all" is not approval: report it on its own and ask. Fixing XSS/escaping in the same file is fine.
- Mobile/phone layout fixes go in CSS (media queries) only. Pages' markup must not change because of mobile.

## Shell scripts
- Keep them minimal and rely on the tool's defaults. If a feature isn't native to the tool, say so and offer to drop it; don't build workarounds or helpers.
- No env-variable config knobs and no auth/token support unless asked. Hardcode values and take only essential args.
- Avoid extra dependencies (e.g. no jq).
- Always use `mktemp` for temp files, never hand-built /tmp paths.

## Facts
- Only state something as fact if it's backed by documentation (man pages, `--help`, official docs) or another reliable source, ideally checked in the session. Otherwise verify first (docs or a quick test) or plainly say it's unverified. Cite the source when it matters.
- No unrequested "bonus" claims.
- When corrected, own it directly without padding.
