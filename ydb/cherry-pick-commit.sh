#! /usr/bin/env bash
set -e

# $1 branch to merge
# $2 commit to merge
# $3 --continue
BRANCH=$1
COMMIT=$2
MERGE_BRANCH=$BRANCH-merge-$COMMIT

if [[ "$3" == "--continue" ]]; then
    CONTINUE=1
elif [[ -z "$3" ]]; then
    CONTINUE=0
else
    echo "Error: Invalid third argument. Use '--continue' or leave empty."
    exit 1
fi

if [[ "$CONTINUE" == "0" ]]; then
    git switch $BRANCH
    git pull
    git checkout -b $MERGE_BRANCH $BRANCH
    git cherry-pick -X ignore-space-at-eol -x $COMMIT
fi
git push --set-upstream origin $MERGE_BRANCH

echo "Make PR: https://github.com/ydb-platform/ydb/compare/$BRANCH...UgnineSirdis:ydb:$MERGE_BRANCH?expand=1"
