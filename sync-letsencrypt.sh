#!/bin/bash
set -e

REMOTE_HOST="vps4"
REMOTE_ARCHIVE="/srv/letsencrypt.tar.gz"
REMOTE_CHECKSUM_FILE="/srv/letsencrypt.sha512"
REMOTE_LOCKFILE="/srv/letsencrypt.busy"

LOCAL_ARCHIVE="/srv/letsencrypt.tar.gz"
LOCAL_CHECKSUM_FILE="/srv/letsencrypt.sha512"

# Zkontroluj, zda hlavní server právě neprovádí aktualizaci
if ssh "$REMOTE_HOST" "[ -e '$REMOTE_LOCKFILE' ]"; then
    echo "Hlavní server je zaneprázdněn, zkus to později."
    exit 1
fi

# Získej vzdálený SHA512 součet
REMOTE_SUM=$(ssh "$REMOTE_HOST" "cat '$REMOTE_CHECKSUM_FILE' | cut -d ' ' -f1")

# Získej lokální SHA512 součet
if [ -f "$LOCAL_CHECKSUM_FILE" ]; then
    LOCAL_SUM=$(cut -d ' ' -f1 "$LOCAL_CHECKSUM_FILE")
else
    LOCAL_SUM=""
fi

# Porovnej součty
if [ "$REMOTE_SUM" = "$LOCAL_SUM" ]; then
    echo "Let’s Encrypt archiv je aktuální, není třeba nic dělat."
    exit 0
fi

# Stáhni archiv
scp "$REMOTE_HOST:$REMOTE_ARCHIVE" "$LOCAL_ARCHIVE"
scp "$REMOTE_HOST:$REMOTE_CHECKSUM_FILE" "$LOCAL_CHECKSUM_FILE"

# Rozbal archiv
tar xzf "$LOCAL_ARCHIVE" -C /

# Restartni případné služby (např. nginx)
systemctl restart apache2

echo "Let’s Encrypt archiv byl úspěšně synchronizován a služby restartovány."
