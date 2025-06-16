#!/bin/bash

# ----------------------------------------------
# Use `backup_example_script` como referência.
# ----------------------------------------------

# ==============================================
# Autores: Lucas Garzuze e Thiago Magalhães.
# Licença: MIT.
# Descrição: Cria backups usando o rsync.
# ==============================================

# --- Definições de cores para formatação de saída no terminal ---
# Finaliza a aplicação da formatação de cor.
RESET='\e[0m'
# Inicia a formatação de cor no texto.
BLACK='\e[1;30m' 
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
# Ex.: ${BLUE}Olá, Mundo!${RESET}

# Faz o script sair imediatamente se qualquer comando retornar erro (código != 0).
set -o errexit
# Faz o script sair se tentar usar variável não definida.
set -o nounset
# Faz o script considerar erro em pipelines quando qualquer parte falhar.
set -o pipefail

# Define onde os backups serão armazenados (neste caso, em /mnt/data/backups).
readonly BACKUP_DIR="${HOME}/backups"
# Captura data e hora atuais no formato 'YYYY-MM-DD_HH:MM:SS'.
readonly DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"
# Monta o caminho completo do novo backup usando data e hora.
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
# Caminho simbólico que sempre apontará para o backup mais recente.
readonly LATEST_LINK="${BACKUP_DIR}/latest"

# Cria o diretório de backups, caso já não exista.
mkdir -p "${BACKUP_DIR}"

# Ponto de inicialização do script.
menu() {
    printf "=== Menu ===\n\n"
    printf "1. Iniciar backup\n"
    printf "2. Sair\n\n"
    printf "Digite uma opção: "
    read opcao
    
    case "$opcao" in
        "1") clear; runBackup;;
        "2") clear; exit;;
        # O menu chama a si mesmo por recursividade.
        *) clear; printf "${YELLOW}*${RESET} Foi digitado: ${YELLOW}%s${RESET}. Opção inválida.\n\n" "$opcao"; menu;;
    esac
}

runBackup() {
    printf "Para realizar o backup do diretório desejado, informe seu caminho desde a raiz.\n"
    printf "Ex.: ${CYAN}/home/usuario/Documentos${RESET}.\n\n"
    printf "Digite o caminho absoluto (completo): "
    # Armazena o diretório de origem dos arquivos a serem salvos.
    read SOURCE_DIR

    # Verifica se o usuário realmente digitou algo.
    if [ -z "$SOURCE_DIR" ]; then
        clear
        printf "${YELLOW}*${RESET} Nenhum caminho foi digitado.\n\n"
        # Direciona o usuário para o menu.
        menu
    fi

    # Verifica se o caminho informado é um diretório
    if [ -d "$SOURCE_DIR" ]; then
        clear
        printf "\n${GREEN}*${RESET} O diretório ${GREEN}%s${RESET} foi encontrado.\n\n" "$SOURCE_DIR"
        # Executa o rsync para copiar arquivos de forma incremental:
        #     - a: modo 'archive' preserva permissões, datas, etc.
        #     - v: modo 'verbose' exibe detalhes da cópia.
        #     --delete: remove no backup arquivos que foram apagados na origem.
        #     --link-dest: utiliza hard links para não repetir arquivos não alterados,
        #                  apontando para o backup mais recente (economiza espaço).
        #     --exclude: ignora a pasta '.cache' durante a cópia.
        rsync -av --delete \
            "${SOURCE_DIR}/" \
            --link-dest="${LATEST_LINK}" \
            --exclude=".cache" \
            "${BACKUP_PATH}"
        # Remove, sem gerar erro se não existir, o link simbólico 'latest'
        rm -rf "${LATEST_LINK}"
        # Cria um novo link simbólico 'latest' apontando para o backup recém-criado
        ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
        # Mensagem de finalização do backup.
        printf "\n${GREEN}* Backup finalizado sem erros${RESET}.\n\n"
        printf "O backup está localizado no diretório: ${CYAN}%s${RESET}\n\n" "${BACKUP_PATH}"
        # Direciona o usuário para o menu.
        menu
    else
        clear
        printf "${YELLOW}*${RESET} O diretório ${YELLOW}%s${RESET} não existe ou não é um diretório.\n\n" "$SOURCE_DIR"
        # Direciona o usuário para o menu.
        menu
    fi
}

menu
