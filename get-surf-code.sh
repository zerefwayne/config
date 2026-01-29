#!/usr/bin/env bash
set -euo pipefail

# -------- Config --------

CODE_DIR="$HOME/code"

# Format:
# name,repo_link,is_forked,upstream_link
REPOS=(
  "easyconfigs,git@github.com:zerefwayne/easybuild-easyconfigs.git,true,git@github.com:easybuilders/easybuild-easyconfigs.git"
)

# -------- Setup --------

rm -rf "$CODE_DIR"
mkdir -p "$CODE_DIR"
cd "$CODE_DIR"

# -------- Clone logic --------

for entry in "${REPOS[@]}"; do
    IFS=',' read -r name repo_link is_forked upstream_link <<< "$entry"

    echo "==> Cloning $name"
    git clone "$repo_link" "$name"
    cd "$name"

    if [[ "$is_forked" == "true" ]]; then
        echo "    Adding upstream remote"
        git remote add upstream "$upstream_link"

        # Get current branch name (usually main/develop)
        current_branch="$(git symbolic-ref --short HEAD)"

        echo "    Setting $current_branch to track upstream/$current_branch"
        git fetch upstream
        git branch --set-upstream-to="upstream/$current_branch" "$current_branch"
    fi

    cd ..
done

echo "All repositories cloned into $CODE_DIR"
