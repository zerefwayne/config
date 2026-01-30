# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

############## Custom setup

# --- Git branch helper (fast) ---
__git_branch() {
    git symbolic-ref --quiet --short HEAD 2>/dev/null
}

# --- Path shortening: /home/user/projects/foo/bar -> ~/p/f/bar ---

# --- Git branch helper ---
__git_branch() {
    git symbolic-ref --quiet --short HEAD 2>/dev/null
}

# --- Path shortening ---
__short_pwd() {
    local path="${PWD/#$HOME/~}"
    IFS='/' read -ra parts <<< "$path"

    local out=""
    local last=$((${#parts[@]} - 1))

    for i in "${!parts[@]}"; do
        if [[ $i -eq $last || "${parts[i]}" == "~" ]]; then
            out+="${parts[i]}"
        else
            out+="${parts[i]:0:1}"
        fi
        [[ $i -lt $last ]] && out+="/"
    done
    echo "$out"
}

# --- Prompt command ---
__prompt() {
    local branch="$(__git_branch)"
    PS1="\[\e[1;32m\]\u@\h\[\e[0m\] \
\[\e[1;34m\]$(__short_pwd)\[\e[0m\]"
    [[ -n $branch ]] && PS1+=" \[\e[33m\]($branch)\[\e[0m\]"
    PS1+=" \$ "
}

PROMPT_COMMAND=__prompt

export GPG_TTY=$(tty)

alias getgpu="salloc -p gpu_a100 -n 1 -c 16 -t 4:00:00 --gpus-per-node=1"
alias loadeessi="source /cvmfs/software.eessi.io/versions/2023.06/init/bash"
alias letsgo='tmux attach -t work'
alias allocamd='salloc -w j14n2 --gres=gpu:mi210:1 -c 72 -t 04:00:00'
alias getnodes='sinfo -N -o "%N %G %t"'

alias liza='ssh aayushj@liza.surf.nl'
alias snellius='ssh aayushj@int5-pub.snellius.surf.nl'
alias src='ssh ajoglekar@145.38.186.81'

alias get-surf-code='cd ~/config && git pull --rebase && bash get-surf-code.sh'
