#! /usr/bin/env bash
set -e

# $1 branch to merge
# $2 commit to merge
BRANCH=$1
COMMIT=$2
MERGE_BRANCH=$BRANCH-merge-$COMMIT

git switch $BRANCH
git pull
git checkout -b $MERGE_BRANCH $BRANCH
git cherry-pick -X ignore-space-at-eol -x $COMMIT
git push --set-upstream origin $MERGE_BRANCH
