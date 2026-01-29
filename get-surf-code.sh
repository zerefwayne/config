#!/usr/bin/env bash

# -------- Config --------

CODE_DIR="$HOME/code"

# Format:
# name,repo_link,is_forked,upstream_link
REPOS=(
  "easybuild-easyblocks,git@github.com:zerefwayne/easybuild-easyblocks.git,true,git@github.com:easybuilders/easybuild-easyblocks.git"
  "easybuild-easyconfigs,git@github.com:zerefwayne/easybuild-easyconfigs.git,true,git@github.com:easybuilders/easybuild-easyconfigs.git"
  "easybuild-framework,git@github.com:zerefwayne/easybuild-framework.git,true,git@github.com:easybuilders/easybuild-framework.git"
  "software-layer,git@github.com:zerefwayne/software-layer.git,true,git@github.com:EESSI/software-layer.git"
  "software-layer-scripts,git@github.com:zerefwayne/software-layer-scripts.git,true,git@github.com:EESSI/software-layer-scripts.git"
  "compatibility-layer,git@github.com:zerefwayne/compatibility-layer.git,true,git@github.com:EESSI/compatibility-layer.git"
  "filesystem-layer,git@github.com:zerefwayne/filesystem-layer.git,true,git@github.com:EESSI/filesystem-layer.git"
)

# -------- Setup --------

echo ">> Recreating $CODE_DIR"
rm -rf "$CODE_DIR"
mkdir -p "$CODE_DIR"
cd "$CODE_DIR" || exit 1

# -------- Clone logic --------

for entry in "${REPOS[@]}"; do
    IFS=',' read -r name repo_link is_forked upstream_link <<< "$entry"

    echo
    echo "========================================"
    echo "Repository : $name"
    echo "Origin     : $repo_link"
    echo "Forked     : $is_forked"
    [ "$is_forked" = "true" ] && echo "Upstream   : $upstream_link"
    echo "========================================"

    echo ">> Cloning $name"
    git clone "$repo_link" "$name" || {
        echo "!! Failed to clone $name"
        continue
    }

    cd "$name" || continue

    echo ">> Fetching all branches from origin"
    git fetch origin

    if [ "$is_forked" = "true" ]; then
        echo ">> Adding upstream remote"
        git remote add upstream "$upstream_link"

        current_branch="$(git symbolic-ref --short HEAD 2>/dev/null)"

        if [ -n "$current_branch" ]; then
            echo ">> Fetching upstream"
            git fetch upstream

            echo ">> Setting branch '$current_branch' to track upstream/$current_branch"
            git branch --set-upstream-to="upstream/$current_branch" "$current_branch"
        fi
    fi

    cd ..
done

echo
echo ">> Done. Repositories cloned into $CODE_DIR"
