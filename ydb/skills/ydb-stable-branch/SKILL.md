---
name: ydb-stable-branch
description: Ports commits from main into a Nebius stable branch (stream-nb-YY-N) and resolves cherry-pick conflicts, writing a conflicts description into the commit message
disable-model-invocation: true
argument-hint: "[revision ...] (empty = resolve the cherry-pick that is in progress)"
---

# YDB Nebius stable branch

Arguments: `$ARGUMENTS`

## YDB branches

- `main`: the upstream development branch. Every change lands here first. Port from `main` whenever you can, not from another stable branch.
- `stable-YY-N`: an upstream branch cut from `main` and then stabilized. `YY` is the year and `N` is the sequence number, so `stable-24-4` is older than `stable-25-1`.
- `stream-nb-YY-N`: a Nebius branch. It is made from the last stable tag of `stable-YY-N`, plus Nebius-specific commits ported from `main`. Rarely, it also gets commits that are not in `main` but are still needed.

The same change exists as several git commits: the one in `main` (the **main commit**) and the cherry-picked copy in an nb-branch (the **branch commit**). They have the same title and the same purpose, but their diffs can differ slightly. A branch commit usually ends with `(cherry picked from commit <main-sha>)`, which links it to its main commit.

These branches go to production clusters. Correctness matters more than speed.

## Modes

The user has normally already switched to the target `stream-nb-*` branch. Do not switch branches unless asked.

1. **Port**: `$ARGUMENTS` holds one or more revisions. Process them one by one, in the given order.
2. **Resolve**: `$ARGUMENTS` is empty and a cherry-pick is in progress (`.git/CHERRY_PICK_HEAD` exists). Resolve that cherry-pick's conflicts.

If neither case applies, ask the user what to do.

## Porting a revision

1. Check the working tree. If it is dirty, or a cherry-pick, merge or rebase is already in progress, stop and tell the user.
2. Make sure the revision is the main commit. If it is a branch commit, find its main commit: use the `(cherry picked from commit ...)` trailer, or search `main` for the same title. If you find it, port the main commit and tell the user you did. If you can't find it, or the match is uncertain, ask the user.
3. Skip the revision if it is already in the target branch. Look for a commit that has the same title, or that carries a `cherry picked from` trailer pointing at the same main commit. Report the skip.
4. Run exactly:
   ```sh
   git cherry-pick -X ignore-space-at-eol -x <revision>
   ```
5. If it applies cleanly, the commit is done. Go to the next revision.
6. If there are conflicts, follow **Resolving conflicts** below. Then **stop**: leave the remaining revisions unprocessed and list them in the report.

## Resolving conflicts

The user runs `git cherry-pick --continue` themselves. Never commit, continue, abort, reset, stash or push.

You know git well. Use whatever commands you need. Two habits matter most here:

- Look at each conflict with its base: `git checkout --conflict=zdiff3 -- <file>`. Without the base you cannot tell which side changed what.
- Find out *why* the hunk conflicts. Usually the target branch lacks an earlier main commit that touched the same lines. Compare the history of the file in `main` before the ported commit with its history in the target branch.

For each conflict, compare these sources:
- the ported commit's own diff;
- the target branch version;
- when the right answer isn't obvious, the current `main` version of the file. For example, use it to decide the order of entries in a list.

Change only conflicting hunks. Do not "improve" surrounding code. When a file is fully resolved, `git add` it. When everything is resolved, check that no conflict markers remain.

### Conflict classes

| Class | What to do | In commit message? |
|---|---|---|
| **Context-only.** Lines next to the change differ, and both sides' intent is clearly compatible. | Keep both sides. | No |
| **Ordering.** Both sides add entries to the same list: `ya.make` `SRCS`/`PEERDIR`, enums, switch cases, includes, config lists. | Keep both, in the order `main` uses. | No, unless the order was not obvious |
| **Adapted.** The code differs between branches (renamed symbol, changed signature, moved code), so the change must be rewritten to apply here. | Apply the same logic to the branch's code. | **Yes**: explain what was adapted and why |
| **Missing prerequisite.** The change depends on an earlier `main` commit that is not in the branch. | **Stop and ask.** Name the prerequisite commit(s). Do not port them partially by hand. | n/a |
| **Modify/delete or rename.** The file was deleted or moved on one side. | **Ask.** | n/a |
| **Wire/format identifiers.** Field numbers in `.proto` files, config field ids, enum values persisted anywhere, schema or migration ids. | Must be **identical to `main`**. If the branch already uses that number for something else, **stop and ask**. | **Yes** |
| **Generated or canonical data.** Canondata, generated files. | Take the version that matches the code. If unsure, ask. Never hand-merge. | Yes |
| **Anything else, or any doubt.** | **Ask.** Do not guess. | — |

### Commit message

While a cherry-pick is stopped, git keeps the future commit message in `.git/MERGE_MSG`. `git cherry-pick --continue` uses it as the message. If that file has conflict classes marked "Yes" in the table above, edit it as follows:

- Keep the original title and body unchanged.
- Add a section **above** the `(cherry picked from commit ...)` line. Do not remove that line.
  ```
  Conflicts resolution:
  - path/to/file.cpp: <what conflicted and how it was resolved, briefly>
  ```
- List only the non-obvious conflicts. Context-only conflicts, and ordering conflicts where the order was obvious, stay out.
- List only the conflicts you resolved yourself. In **Resolve** mode, some conflicts may already have been resolved before you started, for example by the user. Leave those out: you don't know how or why they were resolved, so the user should describe them.
- Remove git's auto-generated `# Conflicts:` comment block, if present. Commented lines are stripped anyway, but it is noise.

If every conflict was obvious, leave `.git/MERGE_MSG` unchanged.

## Report to the user

At the end, print:
- revisions ported cleanly, skipped (with the reason), and not processed yet;
- for the conflicting revision, one line per file: class, decision, confidence (high/medium/low);
- open questions, if any;
- the next step, e.g. "review `git diff --cached`, then run `git cherry-pick --continue`".

## Creating a new nb-branch (background)

When Nebius moves from an old nb-branch (e.g. `stream-nb-25-2`) to a new one (`stream-nb-25-3`):

1. Take the last stable tag of the new upstream branch (`stable-25-3`).
2. Create the new nb-branch from that tag.
3. Find the commits that are in the old nb-branch but not in the new one.
4. Port each one that is still relevant. Use its main commit if there is one; otherwise use the branch commit.

Steps 3–4 produce the list of revisions that is then passed to this skill in **Port** mode.
