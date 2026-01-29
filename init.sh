#!/usr/bin/env bash
set -euo pipefail

# -------- Copy bashrc to home folder --------

cp -f config/.bashrc "$HOME/.bashrc"
source "$HOME/.bashrc"

# -------- Import GPG keys from ~/.gpg --------

GPG_SRC="$HOME/.gpg"
GPG_DST="$HOME/.gnupg"

if [[ -d "$GPG_SRC" ]]; then
    mkdir -p "$GPG_DST"
    chmod 700 "$GPG_DST"

    for key in "$GPG_SRC"/*; do
        [[ -f "$key" ]] || continue
        gpg --batch --import "$key" >/dev/null 2>&1 || true
    done

    # Fix permissions (GPG is strict)
    chmod 700 "$GPG_DST"
    find "$GPG_DST" -type f -exec chmod 600 {} \; || true
fi

# -------- Auto-configure Git to use GPG signing --------

__git_gpg_key() {
    gpg --list-secret-keys --keyid-format=long 2>/dev/null \
        | grep '^sec' \
        | head -n1 \
        | awk '{print $2}' \
        | cut -d'/' -f2
}

__configure_git_gpg() {
    local key
    key=$(__git_gpg_key)

    if [[ -n "$key" ]]; then
        git config --global user.signingkey "$key"
        git config --global commit.gpgsign true
        git config --global gpg.program gpg

        echo "Git GPG signing enabled with key: $key"
    fi
}

__configure_git_gpg

# -------- SSH agent init --------

if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null
fi

if ! ssh-add -l >/dev/null 2>&1; then
    for key in "$HOME"/.ssh/id_*; do
        [[ -f "$key" && "$key" != *.pub ]] || continue
        ssh-add "$key" >/dev/null 2>&1 || true
        echo "ssh key ($key) added to ssh-agent"
    done
fi
