# -------- Copy bashrc to home folder --------

cp -f config/.bashrc ./.bashrc
source ~/.bashrc

# -------- Auto-configure Git to use GPG signing --------

# Function to get the long GPG key ID from secret keys
__git_gpg_key() {
    # extract just the long key ID (not subkey, not fingerprint)
    gpg --list-secret-keys --keyid-format=long 2>/dev/null \
        | grep '^sec' \
        | head -n1 \
        | awk '{print $2}' \
        | cut -d'/' -f2
}

# Export the key and set Git config
__configure_git_gpg() {
    local key
    key=$(__git_gpg_key)

    if [[ -n "$key" ]]; then
        git config --global user.signingkey "$key"
        git config --global commit.gpgsign true
        git config --global gpg.program gpg

        # Print status once
        echo "Git GPG signing enabled with key: $key"
    fi
}

# Run it once at shell startup
__configure_git_gpg
