#!/bin/bash

# Definir diretórios de origem e de destino
SOURCE="/home/user/bin/"
DEST="/home/user/bin/dest"

# Configura RSYNC
RSYNC_OPTIONS="-avz --delete"

# Cria o diretório de destino, caso não exista
mkdir -p "$DEST_DIR"

# Fax o backup
rsync $RSYNC_OPTIONS "$SOURCE" "$DEST"

# Confirmar que o backup deu certo
echo "Backup completo com sucesso."
