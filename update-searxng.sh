#!/bin/bash
#set -euo pipefail

SEARXNG_SRC="/usr/local/searxng/searxng-src"
VENV_PATH="/usr/local/searxng/searx-pyenv"
GIT_BRANCH="master"
SERVICE_NAME="uwsgi.service"
LOCKFILE="/tmp/searxng-update.lock"

if [ -e "$LOCKFILE" ]; then
    echo "Lockfile exists: $LOCKFILE. Update already running?"
    exit 1
fi
touch "$LOCKFILE"

echo "=== Updating SearXNG instance ==="
echo "Git branch: $GIT_BRANCH"
echo "Source path: $SEARXNG_SRC"
echo "Virtualenv path: $VENV_PATH"
echo

# Step 1: Git update
cd "$SEARXNG_SRC"
git pull
echo "--- Git: fetching and resetting ---"
git fetch origin "$GIT_BRANCH"
git reset --hard "origin/$GIT_BRANCH"

# Step 2: Activate virtualenv
echo "--- Activating virtualenv ---"
source "$VENV_PATH/bin/activate"

# Step 3: Upgrade dependencies and install SearXNG
echo "--- Upgrading pip/setuptools/wheel/pyyaml ---"
pip install -U pip
pip install -U setuptools
pip install -U wheel
pip install -U pyyaml

echo "--- Installing SearXNG in editable mode ---"
pip install -U --use-pep517 --no-build-isolation -e .
# step 4: Restart service
echo "--- Restarting systemd service: $SERVICE_NAME ---"
sudo systemctl restart "$SERVICE_NAME"

rm -f "$LOCKFILE"

echo "=== SearXNG update complete ==="
