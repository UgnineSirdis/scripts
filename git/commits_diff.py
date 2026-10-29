#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import helpers


main_branch = "main"

# Existing Nebius branch to which we have ported changes
nebius_branch = "stream-nb-25-2"

# Stable branch/tag from which we want to make a new Nebius branch
upstream_stable_branch = "25.3.1.27"


def print_commits(branch_name, commits):
    print(f"\n\nBranch {branch_name}:")
    for commit in commits:
        print(f"{commit.commit_hash} - \"{commit.commit_title}\" (~\"{commit.commit_normalized_title}\")")


def test_commit_parsing_case(src_str, hash, title, normalized_title):
    commit = helpers.GitLogItem(src_str)
    assert commit.commit_hash == hash, f"Expected hash: {hash}, got: {commit.commit_hash}"
    assert commit.commit_title == title, f"Expected title: {title}, got: {commit.commit_title}"
    assert commit.commit_normalized_title == normalized_title, f"Expected normalized title: {normalized_title}, got: {commit.commit_normalized_title}"


def test_commit_parsing():
    test_commit_parsing_case(
        "1234567\nFix ydb read rows timeout after ds tablets restart (#17925) (#17947)",
        "1234567",
        "Fix ydb read rows timeout after ds tablets restart (#17925) (#17947)",
        "Fix ydb read rows timeout after ds tablets restart")


def make_commits_map(commits):
    commits_map = {}
    for commit in commits:
        commits_map[commit.commit_normalized_title] = commit
    return commits_map


class CommitsSet:
    def __init__(self, commits):
        self.commits = commits
        self.by_title = {}
        self.by_pr = {}
        for commit in commits:
            self.by_title[commit.commit_normalized_title] = commit
            for pr in commit.prs:
                self.by_pr[pr] = commit

    def find_commit(self, commit):
        by_title = self.by_title.get(commit.commit_normalized_title)
        if by_title:
            return by_title
        for pr in commit.prs:
            by_pr = self.by_pr.get(pr)
            if by_pr:
                return by_pr
        return None


def is_one_of_branches_ancestor(commit_hash, branches):
    """
    Check if the commit is an ancestor of any of the given branches.
    """
    for branch in branches:
        if helpers.is_ancestor(commit_hash, branch):
            return True
    return False


def main():
    test_commit_parsing()

    upstream_stable_branches = [
        upstream_stable_branch,
        # "remotes/upstream/stable-24-3",
        # "remotes/upstream/stable-24-3-10-analytics",
        # "remotes/upstream/stable-24-3-10-hotfix",
        # "remotes/upstream/stable-24-3-11-hotfix",
        # "remotes/upstream/stable-24-3-13-enterprise",
        # "remotes/upstream/stable-24-3-13-hotfix",
        # "remotes/upstream/stable-24-3-13-hotfix-yasubd",
        # "remotes/upstream/stable-24-3-14-cs",
        # "remotes/upstream/stable-24-3-15-hotfix",
        # "remotes/upstream/stable-24-3-6-logbroker",
        # "remotes/upstream/stable-24-3-7-hotfix",
        # "remotes/upstream/stable-24-3-8-analytics",
        # "remotes/upstream/stable-24-3-8-analytics-misha",
        # "remotes/upstream/stable-24-3-9-cs",
        # "remotes/upstream/stable-24-3-9-hotfix",
        # "remotes/upstream/stable-24-3-enterprise",
        # "remotes/upstream/stable-24-4",
        # "remotes/upstream/stable-24-4-1-hotfix",
        # "remotes/upstream/stable-24-4-2-hotfix",
        # "remotes/upstream/stable-24-4-2-hotfix-backport/1",
        # "remotes/upstream/stable-24-4-3-hotfix",
        # "remotes/upstream/stable-24-4-4-hotfix",
        # "remotes/upstream/stable-24-4-analytics",
        # "remotes/upstream/stable-24-4-compatibility-patch",
        # "remotes/upstream/stable-24-4-enterprise",
        # "remotes/upstream/stable-24-4-version-definition",
        # "remotes/upstream/stable-25-1",
        # "remotes/upstream/stable-25-1-1",
        # "remotes/upstream/stable-25-1-1-13-hotfix",
        # "remotes/upstream/stable-25-1-1-17-hotfix",
        # "remotes/upstream/stable-25-1-1-18-hotfix",
        # "remotes/upstream/stable-25-1-1-19",
        # "remotes/upstream/stable-25-1-1-19-hotfix",
        # "remotes/upstream/stable-25-1-1-9-hotfix",
        # "remotes/upstream/stable-25-1-2",
        # "remotes/upstream/stable-25-1-2-4-hotfix",
        # "remotes/upstream/stable-25-1-2-7-rc",
        # "remotes/upstream/stable-25-1-3",
        # "remotes/upstream/stable-25-1-4",
        # "remotes/upstream/stable-25-1-4-17-hotfix",
        # "remotes/upstream/stable-25-1-4-7-hotfix",
        # "remotes/upstream/stable-25-1-analytics",
        # "remotes/upstream/stable-25-3",
        # "remotes/upstream/stable-25-3-1",
        "25.2.1.26",
        "25.1.4.18",
    ]

    exclude_files = [
        "CHANGELOG.md",
    ]

    exclude_dirs = [
        "ydb/docs",
        ".github",
    ]

    dont_merge_exceptions = {
        "30604fb9465810000643673f54ad890c919ffb94",
        "72fdd1483ff8c2c08b28d5589e9eeb0a42e9a247",
        "53ce17f7ad4a139621cc172f38238562c37eacb4",
        "f510f6f3e859e70228abbe046b1e2d907562745a",
        "601c23f2db34407f3f5f54abcf7597575c5d3cf4",
        "68d3b5a645c2e39fae74eb380aad79da53fa9ae6",
    }

    diverge_commit = helpers.get_diverge_commit(upstream_stable_branch, nebius_branch)
    print(f"Diverge commit between {nebius_branch} and {upstream_stable_branch}: {diverge_commit}")

    diverge_main_commit = helpers.get_diverge_commit(main_branch, nebius_branch)
    print(f"Diverge commit between {nebius_branch} and {main_branch}: {diverge_main_commit}")

    commits_nebius = helpers.get_log(nebius_branch, diverge_commit)
    print_commits(nebius_branch, commits_nebius)

    commits_stable = helpers.get_log(upstream_stable_branch, diverge_commit)
    print_commits(upstream_stable_branch, commits_stable)

    commits_main = helpers.get_log(main_branch, diverge_main_commit)
    print_commits(main_branch, commits_main)

    upstream_commits_set = CommitsSet(commits_stable)
    main_commits_set = CommitsSet(commits_main)

    commits_to_merge = []

    for commit in commits_nebius:
        upstream_commit = upstream_commits_set.find_commit(commit)
        if upstream_commit is None:
            if commit.commit_hash in dont_merge_exceptions:
                print(f"Skipping commit {commit.commit_hash} - {commit.commit_title} due to exception")
                continue
            if is_one_of_branches_ancestor(commit.commit_hash, upstream_stable_branches):
                continue
            if helpers.changes_only(commit.commit_hash, exclude_dirs, exclude_files):
                print(f"Skipping commit {commit.commit_hash} - {commit.commit_title}: changes only excluded files/dirs")
                continue

            print(f"Found absent commit in {upstream_stable_branch}: {commit.commit_hash} - {commit.commit_title}")
            commits_to_merge.append(commit)

            main_commit = main_commits_set.find_commit(commit)
            if main_commit is None:
                print(f"Commit is absent even in main branch")
        else:
            if upstream_commit.commit_hash != commit.commit_hash:
                print(f"Equal commits:\n\tNebius: {commit.commit_hash} - {commit.commit_title}\n\tUpstream: {upstream_commit.commit_hash}: {upstream_commit.commit_title}")

    commits_to_merge.reverse()

    # List all links
    print("Commits to merge:")
    for commit in commits_to_merge:
        msg = "\n" + commit.commit_title
        msg += f"\nhttps://github.com/ydb-platform/ydb/commit/{commit.commit_hash}"
        main_commit = main_commits_set.find_commit(commit)
        if main_commit:
            msg += f" main branch commit: https://github.com/ydb-platform/ydb/commit/{main_commit.commit_hash}"
        else:
            msg += " no main branch commit!"
        print(msg)

    cherry_pick_command_start = "git cherry-pick -X ignore-space-at-eol -x"
    cherry_pick_command = cherry_pick_command_start
    commits_count_in_command = 10
    for commit in commits_to_merge:
        if commits_count_in_command == 0:
            cherry_pick_command += "\n"
            cherry_pick_command += cherry_pick_command_start
            commits_count_in_command = 10
        commits_count_in_command -= 1
        cherry_pick_command += f" {commit.commit_hash}"
    print(f"\nCherry-pick commands:\n{cherry_pick_command}")
    print(f"\n\nThere are {len(commits_to_merge)} commits to merge")

if __name__ == "__main__":
    main()
