#!/bin/bash

# ----------------------------------------------
# Use `backup_example_script` como referência.
# ----------------------------------------------

# ======================================================
# Autores: Lucas Garzuze, Thiago Magalhães e Yohan Cys.
# Licença: MIT.
# Descrição: Cria backups usando o rsync.
# ======================================================

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
# set -o pipefail
set -euo pipefail

menu() {
    option=""
    printf "== Menu ==\n"
    printf "1. Iniciar backup\n"
    printf "2. Sair\n\n"
    printf "Digite uma opção: "
    read -r option

    # O return encerra a execução da função atual para evitar empilhamento de funções.
    # Desse modo, a pausa de execução em segundo plano não ocorre.
    case "$option" in
        "1")
            clear; runBackup; return;;
        "2")
            clear; printf "Script encerrado. Saindo...\n\n"; exit;;
        "")
            clear;
            # Verifica se a entrada está vazia.
            printf "${YELLOW}*${RESET} Nenhuma opção foi digitada. Tente novamente.\n\n";
            menu;
            return
            ;;
        *)
            clear;
            printf "${YELLOW}*${RESET} Foi digitado: ${YELLOW}%s${RESET}. Opção inválida.\n\n" "$option";
            menu;
            return
            ;;
    esac
}

runBackup() {
    BACKUP_SUBDIR_NAME="backups"
    # Se SOURCE_DIR já estiver definido (via args), pula leitura interativa:
    if [[ -z "${SOURCE_DIR:-}" ]]; then
        # Seleção do diretório de origem.
        while true; do
            printf "[${CYAN}ORIGEM${RESET}] Informe o caminho completo (desde a raiz) do diretório desejado para backup.\n"
            printf "Ex.: ${CYAN}/home/usuario/Documentos/${RESET}.\n\n"
            printf "Digite o caminho de origem ou [${CYAN}2${RESET}] para voltar ao menu: "
            read -r SOURCE_DIR
            clear

            # Verifica se a entrada está vazia (usuário não digitou nada).
            if [[ -z "${SOURCE_DIR}" ]]; then
                printf "${YELLOW}*${RESET} Nenhum caminho de origem foi digitado. Tente novamente.\n\n"
                # Pula para a próxima iteração do laço.
                continue
            fi

            # Verifica se foi digitado `2` para retornar ao main.
            if [[ "${SOURCE_DIR}" == "2" ]]; then
                main
                return
            fi

            if [[ -d "$SOURCE_DIR" ]]; then
                # Se for um diretório válido, exibe o caminho completo desde a raiz.
                printf "${GREEN}*${RESET} Diretório de origem localizado em: ${GREEN}%s${RESET}.\n\n" "$SOURCE_DIR"
                # Encerra o laço atual (diretório de origem).
                break
            else
                printf "${YELLOW}*${RESET} O caminho de origem informado não existe ou não é um diretório.\n"
                printf "${YELLOW}*${RESET} Foi digitado: ${YELLOW}%s${RESET}.\n\n" "$SOURCE_DIR"
            fi
        done

        # Seleção do diretório de destino.
        while true; do
            printf "[${CYAN}DESTINO${RESET}] Informe o caminho completo (desde a raiz) do diretório de armazenamento do backup.\n"
            printf "Ex.: ${CYAN}/media/hd_externo/backups${RESET}.\n\n"
            printf "Digite o caminho de destino ou [${CYAN}2${RESET}] para alterar o diretório de ORIGEM: "
            read -r DEST_DIR
            clear

            # Verifica se a entrada está vazia (usuário não digitou nada).
            if [[ -z "${DEST_DIR}" ]]; then
                printf "${YELLOW}*${RESET} Nenhum caminho de destino foi digitado. Tente novamente.\n\n"
                continue
            fi

            # Verifica se foi digitado `2` para alterar diretório de origem.
            if [[ "${DEST_DIR}" == "2" ]]; then
                runBackup
                return
            fi

            # Combina o caminho do usuário com o nome da subpasta automática.
            # O '%/' remove a barra final, se houver, para evitar '//'
            BACKUP_DIR="${DEST_DIR%/}/${BACKUP_SUBDIR_NAME}"

            # Tenta criar o diretório de destino, incluindo seu subdiretório. O '-p' evita erros se já existir.
            mkdir -p "${BACKUP_DIR}"

            # Verifica se o diretório existe e se é possível escrever nele.
            if [[ -d "${BACKUP_DIR}" && -w "${BACKUP_DIR}" ]]; then
                printf "${GREEN}*${RESET} O backup será salvo em: ${GREEN}%s${RESET}.\n\n" "$BACKUP_DIR"

                # Encerra o laço atual (diretório de destino).
                break
            else
                printf "${YELLOW}*${RESET} O caminho de destino é inválido ou não há permissão de escrita.\n"
                printf "${YELLOW}*${RESET} Foi digitado: ${YELLOW}%s${RESET}.\n\n" "$DEST_DIR"
            fi
        done
    fi
    BACKUP_DIR="${DEST_DIR%/}/${BACKUP_SUBDIR_NAME}"
    mkdir -p "${BACKUP_DIR}"

    # --- Definições dinâmica dos caminhos ---
    # As variáveis de backup agora são definidas com base na entrada do usuário.
    # Captura data e hora atuais no formato 'YYYY-MM-DD_HH:MM:SS'.
    DATETIME="$(date '+%Y-%m-%d_%H-%M-%S')"
    # Monta o caminho completo do novo backup usando data e hora.
    BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
    # Caminho simbólico que sempre apontará para o backup mais recente.
    LATEST_LINK="${BACKUP_DIR}/latest"

    # Se veio com args, INTERACTIVE=false
    if [[ "${INTERACTIVE:-true}" == "true" ]]; then
        # só faz essa parte em modo interativo
        printf "Deseja iniciar o backup de '%s' para '%s'?\n" "$SOURCE_DIR" "$BACKUP_DIR"
        printf "Digite [1] para confirmar ou qualquer outra tecla para cancelar: "
        read -r option
        clear
        if [[ "$option" != "1" ]]; then
            printf "Operação cancelada.\n\n"
            main
            return
        fi
    fi

    printf "${BLUE}Iniciando backup...${RESET}\n\n"

    # --- Execução do RSYNC ---
    # O Rsync executa a sincronização de arquivos de forma incremental:
    #     * a: Preserva todos os atributos dos arquivos, como permissões, datas, etc.
    #     * h: Exibe os tamanhos dos arquivos em formatos como KB, MB, GB.
    #     * --info=progress2: Exibe uma barra de progresso geral
    #     * --delete: Remove no backup arquivos que foram apagados na origem.
    #     * --link-dest: utiliza hard links para não repetir arquivos não alterados,
    #                  apontando para o backup mais recente (economiza espaço).
    #     --exclude: ignora a pasta '.cache' durante a cópia.
    rsync -ah --info=progress2 --delete \
        "${SOURCE_DIR}/" \
        --link-dest="${LATEST_LINK}" \
        --exclude=".cache" \
        "${BACKUP_PATH}"

    # Remove, sem gerar erro se não existir, o link simbólico 'latest'.
    rm -rf "${LATEST_LINK}"
    # Cria um novo link simbólico 'latest' apontando para o backup recém-criado.
    ln -s "${BACKUP_PATH}" "${LATEST_LINK}"

    # Mensagem de finalização do backup.
    printf "\n${GREEN}* Backup finalizado sem erros${RESET}.\n\n"
    printf "O backup está localizado no diretório: ${CYAN}%s${RESET}\n\n" "${BACKUP_PATH}"

    if [[ "${INTERACTIVE:-true}" == "true" ]]; then
        # Aguarda o usuário pressionar [Enter] antes de continuar a execução.
        printf "Pressione [Enter] para continuar."
        read -r
        clear
        # Direciona o usuário para o menu.
        main
    else
        exit 0
    fi
}
# Ponto de inicialização do script.
main() {
    printf "${BLUE}Autores: L. Garzuze e T. Magalhães e Yohan Cys.${RESET}\n"
    printf "${BLUE}=== Script de Backup com Rsync ===${RESET}\n\n"
    menu
}

# Se vierem exatamente 2 parâmetros, usá‑los e pular menu:
if [[ $# -eq 2 ]]; then
    INTERACTIVE=false
    SOURCE_DIR="$1"
    DEST_DIR="$2"
    runBackup
    exit 0
else
    INTERACTIVE=true
    main
fi
