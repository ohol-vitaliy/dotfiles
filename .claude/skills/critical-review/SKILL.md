---
name: critical-review
description: Critical, skeptical review of a whole codebase or area (UI, logic, UX, architecture). Assumes nothing works as claimed, proves each finding with a concrete failure, and presents a numbered list the user triages item by item; then fixes only the approved items with minimal changes, tests and a clean commit. Use when asked to "look critically", "with skepticism", review the whole code, say "what can be improved", or fix review items by number.
---

# Critical review

A skeptical reviewer's job is to find what is **actually wrong**, not to list what could be different. Assume the code, its comments and its docs are wrong until you've checked them. There's a hard stop between the **review** (read-only) and the **fix** (approved items only).

## The skeptical stance

- **Don't trust what the code says about itself.**
  - A comment like "escaped", "validated" or "can't happen" is a claim. Trace the value and check it.
  - When a README or docstring describes behaviour, check that the code does that. A mismatch is a finding.
  - A test passing proves only what it asserts. Look at what it doesn't assert.
- **Follow untrusted data end to end:** user input, remote content, sensor/API payloads and files. Check where each is decoded, filtered, stored and rendered, and whether every step agrees with the others. A filter in one place often silently changes meaning somewhere else, for example a sanitiser applied to a password.
- **Ask "what happens when…"** for each path:
  - the input is empty, malformed, huge or hostile
  - the DB is locked or missing, or a network call fails
  - it's midnight, a month or year boundary, or a DST change
  - the user isn't the admin
  - the page is cached, or left open for an hour
  - the screen is a phone
- **Look for lies the system tells:**
  - 200 on failure
  - success messages when nothing happened
  - empty pages instead of errors
  - stale "today" from a long cache
  - buttons that lead to "forbidden"
- **Check before you claim.** Before you report something, run a one-line test in the scratchpad (exit codes, trailing newlines, time-zone math, regexes, SQL modifiers), or read the exact code path. If you couldn't check it, say so in the item. A confident wrong finding costs more than a missing one.
- **Don't pad.** No style nits, no "consider adding types", no refactors for taste. Every item needs a concrete scenario: *input or state X → wrong result Y*. If you can't write that sentence, drop the item.

## Before anything: load what's already decided

Read the project's `CLAUDE.md`, its README philosophy or design notes, and its auto-memory: philosophy, by-design behaviours, minimal-fix preferences, access-control rules, branch rules. Never raise what they settle. Judge the code against **its own stated philosophy**; for example, under "code is config" or "simplicity first", hard-coded config and plain code are not findings.

## Phase 1: review (read-only)

1. Read the code yourself; don't fan out to agents unless asked. Cover the entry points, the shared helpers, the auth and session code, the data writes, the rendering, the client scripts and styles, and the build/deploy scripts. Run `git status` to find uncommitted work-in-progress you must not touch.
2. Write the review as a file and present it for approval (in plan mode, the plan file). The format is fixed:
   - Sections, most severe first: `## 1. Fix first` (security, data loss, crashes), `## 2. Logic bugs`, `## 3. UI / UX`, `## 4. Architecture` (only problems that cause or invite real bugs).
   - **Every item gets a stable number, `N.M`**, in bold at the start of its paragraph (for example `**2.4 Invalid searches fail silently.**`). The user replies by number, for example "2.8 expected, 4.6 yes, 3.4 skip".
   - Each item gives: `file:line`, the failure scenario, how you confirmed it (or "not verified"), and the smallest fix.
   - Anything that changes who can access what is only listed, and marked *(access-control decision, yours)*.
   - End with a suggested order and a verification list.
3. Stop and wait for the triage.

## Triage handling

- **"expected" / "by design":** drop the item, and save the lasting decision to a project memory such as `review-expected-items`. Add it to the README if the user says to.
- **"skip for now":** drop it, and note it as deferred in that memory.
- **A philosophy statement:** save it as a project memory, and to the README "Philosophy" section when the user asks.
- **"yes" on an item with more than one possible fix:** ask which fix, with AskUserQuestion, first. This always applies to access control.
- **"expand on N.M":** rewrite that item with the full mechanism, its real impact, the options, and your default.
- Keep the numbering stable across revisions. Mark dropped items as dropped; don't renumber.

## Phase 2: fix (approved items only)

1. **Protect WIP:** save `git diff -- <files with prior uncommitted changes>` to the scratchpad.
2. Run the tests once for a **baseline**, and write down the failures that already exist.
3. Fix each item in place, as small as possible: no new structures, layers or persisted state unless approved. New UI strings go into every locale file.
4. Update the tests the intended behaviour change breaks, and add one regression test per fix that would have caught the bug.
5. Run the project's formatter, linters and tests (see `CLAUDE.md` or the `Makefile`). Done means: the same failures as the baseline, and nothing new.
6. Update the docs wherever the documented behaviour changed.

## Commit

- Commit on the current branch; never create a branch unless asked.
- Stage only your changes. For a file that also holds earlier WIP:
  - try `git apply --cached -R <wip.patch>` first
  - if the hunks overlap, build the file as `git show HEAD:<path>` plus your edits, then `git hash-object -w` and `git update-index --cacheinfo 100644,<blob>,<path>`
  - check that the unstaged diff equals the original WIP exactly
- Write one commit message that lists the fixes, ending with the attribution line from the system reminder.

## Report

Give a short summary per item number. Then:
- the test result, with the baseline failures named as already there
- what you didn't verify
- any action the user has to take

If the user asked for something at the end, such as suspending the machine, run it last. If it needs a terminal and fails from the Bash tool, ask the user to type `! <command>`.
