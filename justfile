# https://just.systems
# Tools come from mise.toml; run `mise install` first

set default-list := true
set shell := ["bash", "-euo", "pipefail", "-c"]

# Check the script and completions
lint:
    shellcheck --shell bash bin/git-amend completions/git-amend.bash
    zsh --no-exec completions/_git-amend

# Build the man page from its AsciiDoc source
build:
    asciidoctor --backend manpage --failure-level WARN man/git-amend.adoc

# Tag HEAD as vVERSION and push the tag, which starts the release workflow
release version: lint build
    #!/usr/bin/env bash
    set -euo pipefail
    die() { echo "release: $*" >&2; exit 1; }

    version="{{ version }}"
    tag="v$version"

    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "expected a version like 1.2.3, got $version"
    [ -z "$(git status --porcelain --untracked-files=no)" ] || die "commit or stash your changes first"
    # The workflow takes the release notes from the committed CHANGELOG.md
    git show HEAD:CHANGELOG.md 2>/dev/null | grep -qE "^## \[${version//./\\.}\]" \
        || die "no CHANGELOG.md entry for $version in HEAD"
    ! git rev-parse --quiet --verify "refs/tags/$tag" >/dev/null || die "tag $tag already exists"

    # Only tag commits the branch has already published
    git fetch --quiet origin
    upstream="$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)" || die "the current branch has no upstream"
    git merge-base --is-ancestor HEAD "$upstream" || die "HEAD is not on $upstream; push it first"

    git tag --annotate "$tag" --message "git-amend $version"
    git push origin "$tag"
