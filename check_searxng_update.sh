#!/bin/bash

# Nastavení cest
LOCAL_GIT_REF="/usr/local/searxng/searxng-src/.git/refs/heads/master"
REPO_API="https://api.github.com/repos/searxng/searxng/commits/master"

# Načti lokální commit hash
if [[ ! -f "$LOCAL_GIT_REF" ]]; then
    #echo "Lokální git ref nenalezen: $LOCAL_GIT_REF" >&2
    exit 1
fi

LOCAL_COMMIT=$(cat "$LOCAL_GIT_REF")

# Získej poslední commit z GitHubu přes GitHub API
REMOTE_COMMIT=$(curl -s "$REPO_API" | jq -r '.sha')

if [[ -z "$LOCAL_COMMIT" || -z "$REMOTE_COMMIT" ]]; then
    #echo "Chyba: LOCAL_COMMIT nebo REMOTE_COMMIT je prázdný." >&2
    #echo "LOCAL_COMMIT='$LOCAL_COMMIT'"
    #echo "REMOTE_COMMIT='$REMOTE_COMMIT'"
    exit 1
fi

# Kontrola a případné spuštění aktualizace
if [[ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]]; then
    BASH_ENV=/root/shell-env /opt/update-searxng.sh
fi
