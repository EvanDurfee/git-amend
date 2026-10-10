# bash completion for git-amend                            -*- shell-script -*-
#
# Completes both `git amend ...` and `git-amend ...`. Install as
# ~/.local/share/bash-completion/completions/git-amend: git's completion lazy-loads
# it the first time `git amend` is completed, and bash-completion loads it for
# `git-amend` by name. Sourcing it from .bashrc also works.

_git_amend() {
	case "$prev" in
		-o | --only)
			__git_complete_index_file "--committable"
			return
			;;
	esac

	case "$cur" in
		--only=*)
			# Bash only replaces the part after the =, so complete just the file
			local cur="${cur#--only=}"
			__git_complete_index_file "--committable"
			return
			;;
		--rebase-merges=*)
			__gitcomp "rebase-cousins no-rebase-cousins" "" "${cur#--rebase-merges=}"
			return
			;;
		-*)
			__gitcomp "--all --patch --only= --edit --no-edit --rebase-merges --rebase-merges= --update-refs --no-update-refs --help"
			return
			;;
	esac

	# Only one COMMIT_REF; skip options and the file after a separate -o/--only
	local i
	for ((i = __git_cmd_idx + 1; i < cword; i++)); do
		case "${words[i]}" in
			-o | --only)
				((i++))
				;;
			-*)
				;;
			*)
				COMPREPLY=()
				return
				;;
		esac
	done

	__git_complete_refs
}

# Completing `git-amend` directly needs git's completion helpers loaded first
if ! declare -F __git_complete >/dev/null; then
	if declare -F _comp_load >/dev/null; then
		_comp_load git
	elif declare -F __load_completion >/dev/null; then
		__load_completion git
	fi
fi
if declare -F __git_complete >/dev/null; then
	__git_complete git-amend _git_amend
fi
