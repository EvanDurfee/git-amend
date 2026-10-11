# Git Amend

`git commit --amend` for any commit in history, not just the last one.

`git amend <commit>` folds the staged changes into `<commit>` and opens its
message for rewording. Under the hood it creates a fixup commit and runs an
autosquash rebase without opening the todo list, so there's no interactive
rebase to drive by hand.

```console
$ git add src/parser.c
$ git amend HEAD~2
```

## Usage

```
git amend [-a | -p | -o <file>...] [-e | --no-edit]
          [--rebase-merges[=<mode>]] [--[no-]update-refs] <commit>
```

| Option                     | Effect                                                                        |
|----------------------------|-------------------------------------------------------------------------------|
| `-a`, `--all`              | Stage all modified and deleted tracked files first                            |
| `-p`, `--patch`            | Choose the hunks to include interactively                                     |
| `-o`, `--only <file>`      | Include only `<file>`, ignoring anything else staged; may be repeated         |
| `-e`, `--edit`             | Reword the commit message (default)                                           |
| `--no-edit`                | Keep the commit message as is                                                 |
| `--rebase-merges[=<mode>]` | Recreate merge commits instead of refusing to amend across them               |
| `--[no-]update-refs`       | Move (or don't move) other branches pointing at the rewritten commits         |

With nothing staged, the commit is only reworded. Changes left unstaged, for
example by `-p` or `-o`, are stashed during the rebase and restored afterwards.

### Examples

Only reword a commit:

```console
$ git amend 3f2a9c1
```

Add some of the current changes to a commit, keeping its message:

```console
$ git amend -p --no-edit feature~3
```

Amend a commit that has a merge after it, keeping the merge:

```console
$ git amend --rebase-merges HEAD~4
```

### Editing the message

The editor opens on an `amend!` commit:

```
amend! Add parser

Add parser
```

Leave the first line alone and edit the message below it; that becomes the
new message of the commit. The first line is how the rebase finds the commit
to squash into, so changing it leaves the fixup commit in history as a
separate commit. Saving an empty message aborts without changing anything.

### Conflicts

If a later commit conflicts with the amended one, the rebase stops as usual.
Resolve the conflict and `git rebase --continue`, or `git rebase --abort` to
return to the branch as it was, with the fixup commit on top.

### Caveats

Like any rebase, this rewrites `<commit>` and everything after it:

- `<commit>` must be an ancestor of `HEAD`.
- Without `--rebase-merges`, there must be no merge commits between `<commit>`
  and `HEAD`, since a plain rebase would flatten them.
- Branches that were already pushed need a force push.
- Other branches pointing at the rewritten commits only move with
  `--update-refs` or `rebase.updateRefs`.

See `man git-amend` for the full details.

## Installation

### Requirements

- Git 2.32 or later (2.38 or later for `--update-refs`)
- Bash
- GNU enhanced `getopt` from util-linux. On macOS, install it with
  `brew install gnu-getopt` and put it ahead of the system `getopt` on `PATH`.

### From a release

Download `git-amend-X.Y.Z.tar.gz` from the
[releases page](https://github.com/EvanDurfee/git-amend/releases), extract it,
and copy the files into place, for example under `~/.local`:

```sh
cd git-amend-X.Y.Z
install -Dm755 bin/git-amend ~/.local/bin/git-amend
install -Dm644 man/git-amend.1 ~/.local/share/man/man1/git-amend.1
install -Dm644 completions/git-amend.bash ~/.local/share/bash-completion/completions/git-amend
install -Dm644 completions/_git-amend ~/.local/share/zsh/site-functions/_git-amend
```

Git picks up `git-amend` as the `git amend` subcommand as long as it's on
`PATH`. For zsh, make sure the completion directory is in `fpath` before
`compinit` runs.

### From source

Clone the repository and install `bin/git-amend` and the completions as above.
The man page is built from AsciiDoc with `just build`, which writes
`man/git-amend.1`.

## Development

Tools are managed with [mise](https://mise.jdx.dev) and tasks with
[just](https://just.systems):

```sh
mise install      # asciidoctor and shellcheck
just lint         # shellcheck the script and completions
just build        # build the man page
```

### Releasing

Add a section for the new version to `CHANGELOG.md`, commit and push it, then:

```sh
just release X.Y.Z
```

This tags `HEAD` as `vX.Y.Z` and pushes the tag, which triggers the GitHub
workflow that builds the man page and publishes the release tarball, using the
changelog section as the release notes.

## License

[Mozilla Public License 2.0](LICENSE.md)
