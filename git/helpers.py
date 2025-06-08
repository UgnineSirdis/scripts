import subprocess
import re


debug_log = False  # Set to True to enable debug logging


def run_capture_output(args):
    result = subprocess.run(args, text=True, capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(f"Command failed with error: {result.stderr.strip()}")
    return result.stdout


def run_git(args):
    run_args = ["git"]
    run_args.extend(args)
    if debug_log:
        print(f"Running git command: {' '.join(run_args)}")
    output = run_capture_output(run_args)
    if debug_log:
        print(f"Command output: {output}")
    return output


def get_git_exit_code(args):
    run_args = ["git"]
    run_args.extend(args)
    if debug_log:
        print(f"Running git command: {' '.join(run_args)}")
    result = subprocess.run(run_args, text=True)
    return result.returncode


def is_ancestor(commit_hash, branch):
    code = get_git_exit_code(["merge-base", "--is-ancestor", commit_hash, branch])
    if code == 0:
        return True
    elif code == 1:
        return False
    else:
        raise RuntimeError(f"Unexpected exit code {code} for command: {' '.join(['git'] + ['merge-base', '--is-ancestor', commit_hash, branch])}")


def get_diverge_commit(branch1, branch2, branch3=None, branch4=None):
    """
    Get the commit where two branches diverge.
    """
    args = ["merge-base", branch1, branch2]
    if branch3:
        args.append(branch3)
    if branch4:
        args.append(branch4)
    return run_git(args).strip()


class GitLogItem:
    def __init__(self, output):
        if debug_log:
            print(f"Parsing log item: {output}")
        newline_index = output.find("\n")
        if newline_index == -1:
            raise ValueError("Empty log item output")
        self.commit_hash = output[:newline_index]
        self.commit_title = output[newline_index + 1:].strip()
        self.commit_normalized_title = self.commit_title
        self.normalize_title()
        self.parse_prs()

        if debug_log:
            print(f"Parse result: {self.__str__()}")

    def __str__(self):
        return f"{self.commit_hash} - \"{self.commit_normalized_title}\""

    def __repr__(self):
        return self.__str__()

    def remove_prs_from_title(self):
        prev_title = self.commit_normalized_title
        title = self.commit_normalized_title.strip()
        title = re.sub(r'\s*\(#\d+\)$', '', title)
        self.commit_normalized_title = title.strip()
        return self.commit_normalized_title != prev_title

    def remove_stable_branch_from_title(self):
        merge_into_regexp = r'^([mM]erge\s*((to)|(into)\s*)?)?'
        branch_name_regexp = r'(([Ss]table-)|([Ss]tream-nb-)|([Nn]ebius[-\s]))?'
        branch_number_regexp = r'\d+[-.\s]\d+([-.\s]\d+)?([-.\s](\d+)|(hotfix))?([-.\s]\d+)?'
        regexp = merge_into_regexp + r'\[?' + branch_name_regexp + branch_number_regexp + r'\]?([:.\s])?'
        return self.remove_regexp(regexp)

    def remove_stable_branch_from_title_end(self):
        branch_name_regexp = r'(([Ss]table-)|([Ss]tream-nb-)|([Nn]ebius[-\s]))?'
        branch_number_regexp = r'\d+[-.\s]\d+([-.\s]\d+)?([-.\s](\d+)|(hotfix))?([-.\s]\d+)?'
        regexp = r'\s*\(?' + branch_name_regexp + branch_number_regexp + r'\)?\s*$'
        return self.remove_regexp(regexp)

    def remove_ticket_from_begin(self):
        regexp = r'^\(?\[?[A-Z]+\-\d+\]?\)?:?'
        return self.remove_regexp(regexp)

    def remove_ticket_from_end(self):
        regexp = r'\(?\[?[A-Z]+\-\d+\]?\)?\s*$'
        return self.remove_regexp(regexp)

    def remove_github_dots_sign(self):
        prev_title = self.commit_normalized_title
        title = self.commit_normalized_title.strip()
        pos = title.find("…")
        if pos != -1:
            title = title[:pos]
            # It also coulb be part of a PR number
            while len(title) and title[len(title) - 1].isdigit():
                title = title[:-1]
            if len(title) and title[len(title) - 1] == "#":
                title = title[:-1]
            if len(title) and title[len(title) - 1] == "(":
                title = title[:-1]
        self.commit_normalized_title = title.strip()
        return self.commit_normalized_title != prev_title

    def remove_regexp(self, regexp):
        prev_title = self.commit_normalized_title
        title = self.commit_normalized_title.strip()
        title = re.sub(regexp, '', title)
        self.commit_normalized_title = title.strip()
        return self.commit_normalized_title != prev_title

    def remove_brackets(self):
        prev_title = self.commit_normalized_title
        title = self.commit_normalized_title.strip()
        if title.startswith("[]"):
            title = title[2:]
        if title.startswith("[ ]"):
            title = title[3:]
        self.commit_normalized_title = title.strip()
        return self.commit_normalized_title != prev_title

    def remove_something(self):
        return self.remove_prs_from_title() or \
               self.remove_stable_branch_from_title() or \
               self.remove_stable_branch_from_title_end() or \
               self.remove_ticket_from_begin() or \
               self.remove_ticket_from_end() or \
               self.remove_github_dots_sign() or \
               self.remove_brackets()

    def normalize_title(self):
        while self.remove_something():
            pass

    def parse_prs(self):
        full_title = self.commit_title
        self.prs = []
        # Find all occurrences of #<id> where <id> is one or more digits
        matches = re.findall(r'#(\d+)', full_title)
        self.prs = [int(pr_id) for pr_id in matches]



def get_log(branch, from_commit=None):
    """
    Get the commit log for a branch, optionally starting from a specific commit.
    """
    args = ["log", branch, "--no-merges", "--pretty=format:commit-hash:%H%n%s"]
    if from_commit:
        args.append(f"{from_commit}..{branch}")
    output = run_git(args).strip()
    items = output.split("commit-hash:")
    result = []
    for i in items:
        if i:
            result.append(GitLogItem(i))
    return result
