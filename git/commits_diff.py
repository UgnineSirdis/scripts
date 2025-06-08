#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import helpers


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
        "remotes/upstream/stable-24-3",
        "remotes/upstream/stable-24-3-10-analytics",
        "remotes/upstream/stable-24-3-10-hotfix",
        "remotes/upstream/stable-24-3-11-hotfix",
        "remotes/upstream/stable-24-3-13-enterprise",
        "remotes/upstream/stable-24-3-13-hotfix",
        "remotes/upstream/stable-24-3-13-hotfix-yasubd",
        "remotes/upstream/stable-24-3-14-cs",
        "remotes/upstream/stable-24-3-15-hotfix",
        "remotes/upstream/stable-24-3-6-logbroker",
        "remotes/upstream/stable-24-3-7-hotfix",
        "remotes/upstream/stable-24-3-8-analytics",
        "remotes/upstream/stable-24-3-8-analytics-misha",
        "remotes/upstream/stable-24-3-9-cs",
        "remotes/upstream/stable-24-3-9-hotfix",
        "remotes/upstream/stable-24-3-enterprise",
        "remotes/upstream/stable-24-4",
        "remotes/upstream/stable-24-4-1-hotfix",
        "remotes/upstream/stable-24-4-2-hotfix",
        "remotes/upstream/stable-24-4-2-hotfix-backport/1",
        "remotes/upstream/stable-24-4-3-hotfix",
        "remotes/upstream/stable-24-4-4-hotfix",
        "remotes/upstream/stable-24-4-analytics",
        "remotes/upstream/stable-24-4-compatibility-patch",
        "remotes/upstream/stable-24-4-enterprise",
        "remotes/upstream/stable-24-4-version-definition",
    ]
    nebius_branch = "stream-nb-24-4"
    upstream_stable_branch = "stable-25-1"
    main_branch = "main"

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

    dont_merge_exceptions = {
        "30604fb9465810000643673f54ad890c919ffb94",
    }

    for commit in commits_nebius:
        upstream_commit = upstream_commits_set.find_commit(commit)
        if upstream_commit is None:
            if is_one_of_branches_ancestor(commit.commit_hash, upstream_stable_branches):
                continue
            if commit.commit_hash in dont_merge_exceptions:
                print(f"Skipping commit {commit.commit_hash} - {commit.commit_title} due to exception")
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
        print(msg)

    cherry_pick_command = "git cherry-pick -x"
    for commit in commits_to_merge:
        cherry_pick_command += f" {commit.commit_hash}"
    print(f"\nCherry-pick command:\n{cherry_pick_command}")

if __name__ == "__main__":
    main()
