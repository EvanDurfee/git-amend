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
