#!/usr/bin/env bash
set -euo pipefail

CODE_DIR="$HOME/code"

REPOS=(
  "easyconfigs,git@github.com:zerefwayne/easybuild-easyconfigs.git,true,git@github.com:easybuilders/easybuild-easyconfigs.git"
  "mytool,git@github.com:zerefwayne/mytool.git,false,"
)

clear
echo ">> Recreating $CODE_DIR"
rm -rf "$CODE_DIR"
mkdir -p "$CODE_DIR"
cd "$CODE_DIR"

for entry in "${REPOS[@]}"; do
    IFS=',' read -r name repo_link is_forked upstream_link <<< "$entry"

    # clear
    echo "========================================"
    echo "Repository : $name"
    echo "Origin     : $repo_link"
    echo "Forked     : $is_forked"
    [[ "$is_forked" == "true" ]] && echo "Upstream   : $upstream_link"
    echo "========================================"

    echo ">> Cloning $name"
    git clone "$repo_link" "$name" > /dev/null

    cd "$name"

    if [[ "$is_forked" == "true" ]]; then
        echo ">> Adding upstream remote"
        git remote add upstream "$upstream_link" > /dev/null

        current_branch="$(git symbolic-ref --short HEAD)"

        echo ">> Fetching upstream"
        git fetch upstream > /dev/null

        echo ">> Setting branch '$current_branch' to track upstream/$current_branch"
        git branch --set-upstream-to="upstream/$current_branch" "$current_branch" > /dev/null
    fi

    cd ..

    echo ">> Finished $name"
    sleep 1
done

clear
echo ">> All repositories cloned into $CODE_DIR"
