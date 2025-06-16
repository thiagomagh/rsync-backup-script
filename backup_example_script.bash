#!/bin/bash

# -------------------------------------------------------
# Use este script como referência para o `backup.bash`.
# -------------------------------------------------------

# Script para realizar backups incrementais usando o rsync.

# Faz o script sair imediatamente se qualquer comando retornar erro (código != 0).
set -o errexit
# Faz o script sair se tentar usar variável não definida.
set -o nounset
# Faz o script considerar erro em pipelines quando qualquer parte falhar.
set -o pipefail

# Define o diretório de origem dos arquivos a serem salvos (pasta home do usuário).
readonly SOURCE_DIR="${HOME}"

# Define onde os backups serão armazenados (neste caso, em /mnt/data/backups).
readonly BACKUP_DIR="/mnt/data/backups"

# Captura data e hora atuais no formato 'YYYY-MM-DD_HH:MM:SS'.
readonly DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"

# Monta o caminho completo do novo backup usando data e hora.
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"

# Caminho simbólico que sempre apontará para o backup mais recente.
readonly LATEST_LINK="${BACKUP_DIR}/latest"

# Cria o diretório de backups, caso já não exista.
mkdir -p "${BACKUP_DIR}"

# Executa o rsync para copiar arquivos de forma incremental:
#     - a: modo 'archive' preserva permissões, datas, etc.
#     - v: modo 'verbose' exibe detalhes da cópia
#     --delete: remove no backup arquivos que foram apagados na origem
#     --link-dest: utiliza hard links para não repetir arquivos não alterados,
#                  apontando para o backup mais recente (economiza espaço)
#     --exclude: ignora a pasta '.cache' durante a cópia
rsync -av --delete \
    "${SOURCE_DIR}/" \
    --link-dest="${LATEST_LINK}" \
    --exclude=".cache" \
    "${BACKUP_PATH}"

# Remove, sem gerar erro se não existir, o link simbólico 'latest'
rm -rf "${LATEST_LINK}"

# Cria um novo link simbólico 'latest' apontando para o backup recém-criado
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
