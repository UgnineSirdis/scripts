#! /usr/bin/env bash
set -e

# $1 commit to merge
COMMIT=$1
BRANCH=$2
DESCRIPTION=$3

git switch main
git checkout -b $BRANCH
git cherry-pick $COMMIT
git push --set-upstream origin $BRANCH
gh pr create --repo "ydb-platform/ydb" --head "UgnineSirdis:$BRANCH" --base main --fill --body "$DESCRIPTION"
