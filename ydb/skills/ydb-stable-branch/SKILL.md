---
name: ydb-stable-branch
description: Resolves conflicts appearing while porting commits from main branch into new Nebius stable branch
disable-model-invocation: true
---

# YDB Nebius stable branch

The `ydb-stable-branch` skill resolves the conflicts between changes.

## Terminology of YDB branches

### main

This is the `main` branch. All main changes are committed to this branch.
There can be changes that are committed only in stable branches, but mainly just to handle their differences from main.
It is always preferable to port commits anywhere from main branch, not from anyother stable branch.

### stable-YY-N

It is an upstream branch that was splitted from `main` and later stabilized.
`YY` here is for year of the branch, `N` is a sequencial order.
So, for example, `stable-24-4` is older than `stable-25-1`.

### stream-nb-YY-N

It is a Nebius branch made from last known tag from corresponding upstream branch.
For example, `stream-nb-25-3` is splitted from the upstream stable branch `stable-25-3`: it's stable tag.

## How Nebius branches are made

Nebius branch `stream-nb-YY-N` consists of some stable base revision from `stable-YY-N` plus Nebius specific commits ported from `main` (or, rarely, commits that are not in `main` for some reasons but are still needed in Nebius branches).

Commits must be ported with a specification of their revision `$REVISION` with the following command:

```sh
git cherry-pick -X ignore-space-at-eol -x $REVISION
```

Both commits are logically the same: they deliver the same functionality, have same names etc, but can differ as they are made in slightly different branches.

Let's name them correspondingly: the branch commit and the main commit. Formally they are different commits from the git point, but we know that logically they present the same functionality.

### Which commits are ported

1. Commits that have been ported to the previous `stream-nb-*` branches, but not yet in the current branch.

    If the commit was in the previous `stream-nb-*` branch, it must be ported again to the next `stream-nb-*` branch too. It is always preferred to port it from the `main` branch as there can be some functionality that appeared in the corresponding `stable-*` branch and is missing in the previous `stable-*`/`stream-nb-*`.

2. New commits that have been committed to the `main` branch and are needed in `stream-nb-*` branch.

    These are new commits that are ported from `main` as they are needed in Nebius.

### Porting commits that have been in previous branches, to the next branches

This is the description of a process of creation of a new branch. For example, Nebius runs now in the branch `stream-nb-25-2` and wants to migrate to the new branch `stream-nb-25-3`.
Let's name `stream-nb-25-2` old nb-branch, `stream-nb-25-3` new nb-branch, and the corresponding branches `stable-25-2` as old upstream branch and `stable-25-3` as new upstream branch.

1. Find the last stable tag of the new upstream branch.
2. Make the new nb-branch from this tag.
3. Find all commits that were made in the old nb-branch and still not present in the new nb-branch.
4. Port all commits, if they are still relevant for the new nb-branch, from the old nb-branch to the new nb-branch. If commit has a `main` version, it must be ported. If no, branch version.

### Conflicts resolution

If we face with the conflicts, we must resolve them.
If it is not obvious, we must look at the commit in `main`, at the commit in nb-branch, and, sometimes, at current main version of the file (for example to define which of the conflicting parameters must be listed first).
All the conflicts must be resolved very carefully (as it is stable branch that goes to production clusters). If there are any doubts, don't make any decision, just ask how to resolve.
Any not obvious conflicts and their way of resolution must be descriped in the commit message.