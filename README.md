# Script de backup com Rsync: Projeto final de Administração de Sistemas da UFPR

*Autores: Lucas Garzuze Cordeiro, Thiago Cesar Magalhães e Yohan Brancalhão Cys*

*Licença: MIT*

## Índice
1. [Visão Geral](#visão-geral)
2. [Requisitos](#requisitos)
3. [Instalação](#instalação)
4. [Uso](#uso)
   * [Modo Interativo](#modo-interativo)
   * [Modo não‑interativo (via argumentos)](#modo-não‑interativo-via-argumentos)
5. [Agendamento](#agendamento)

   * [Usando cron](#usando-cron)
6. [Personalização](#personalização)

   * [Cores e Formatação](#cores-e-formatação)
   * [Excluindo pastas adicionais](#excluindo-pastas-adicionais)
7. [Como Funciona (resumo do fluxo)](#como-funciona-resumo-do-fluxo)
8. [Tratamento de Erros](#tratamento-de-erros)
9. [Licença](#licença)
10. [Referências](#referências)

---

## Visão Geral
Este script automatiza a criação de **backups incrementais** usando o `rsync`.
- Gera pastas de backup nomeadas por data e hora (`YYYY-MM-DD_HH‑MM‑SS`).
- Mantém um link simbólico `latest` apontando para o backup mais recente.
- Suporta **modo interativo** (menu + prompts) ou **modo não‑interativo** (passando origem e destino como argumentos).
- Possibilita agendamento utilizando o `cron` através do modo interativo e não-interativo.
- Formatação colorida para facilitar a leitura no terminal.

---

## Requisitos

- Shell compatível POSIX (`bash` recomendado).
- `rsync` instalado.
- Permissão de leitura sobre o diretório de origem e de escrita sobre o diretório de destino.
- Opcional: cron

---
## Instalação

1. Clone o repositório GitHub:
   ```bash
   git clone https://github.com/garzuze/file_backup.git
   cd file_backup/src
   ```
2. Torne o script de backup executável:
   ```bash
   chmod +x backup_script.bash
   ```
---

## Uso

### Modo Interativo

Basta executar o script sem argumentos. Ele exibirá um menu:

```bash
./backup_script.bash
```

1. Escolha **1** para “Iniciar backup”.
2. Informe o **caminho de origem**.
3. Informe o **caminho de destino** (o subdiretório `backups` será criado automaticamente).
4. Confirme a execução.
5. Acompanhe o progresso via `rsync`.
6. Escolha ou não agendamento via cron.
7. Pressione **Enter** ao final para voltar ao menu.

### Modo não‑interativo (via argumentos)

Permite chamar diretamente com origem e destino — ideal para agendamento:

```bash
./backup_script.bash /home/usuario/Documentos /media/hd_externo/backups
```

* **\$1**: caminho completo da **origem**
* **\$2**: caminho completo do **diretório-base de destino**

O script:

- pula o menu e prompts de confirmação;
- cria `backups/YYYY‑MM‑DD_HH‑MM‑SS`;
- atualiza o link simbólico `backups/latest`;
- encerra automaticamente com código `0`.

---

## Agendamento

### Usando cron

- Modo interativo: Digite **1** quando o script perguntar se deseja agendar a execução. Em seguida, selecione as opções de frequências disponíveis para agendamento.

- Modo não-interativo: Edite seu crontab com `crontab -e` e adicione, por exemplo, para rodar todo dia às 2 h:

```cron
0 2 * * * /caminho/para/backup_script.bash /home/usuario/Documentos /media/hd_externo/backups
```

---

## Personalização

### Cores e Formatação

As variáveis de cor definidas no topo permitem destacar mensagens:

```bash
RESET='\e[0m'
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
CYAN='\e[1;36m'
BLUE='\e[1;34m'
```

Você pode ajustar ou remover escapes de cor conforme sua preferência.

### Excluindo pastas adicionais

Por padrão, o script exclui `.cache`. Para ignorar outras pastas, edite a linha do `rsync`:

```bash
rsync -ah --info=progress2 --delete \
    "${SOURCE_DIR}/" \
    --link-dest="${LATEST_LINK}" \
    --exclude=".cache" \
    "${BACKUP_PATH}"
```

---

## Como Funciona (resumo do fluxo)

1. **Entrada**

   - Se chamado com 2 args → modo não‑interativo.
   - Senão → menu interativo.
2. **Leitura de diretórios** (origem, destino).
3. **Criação de estruturas**

   - `$DEST_DIR/backups`
   - Subpasta com timestamp.
4. **Execução do rsync**

   - Flags: `-a` (archive), `-h` (human), `--info=progress2`, `--delete`, `--link-dest`.
5. **Atualização do link** `latest`.
6. **Configuração ou não de agendamento via cron.**

   - Seleção de frequências disponíveis para agendamento.
7. **Finalização**

   - Modo interativo → pausa e volta ao menu.
   - Modo não‑interativo → encerra o script.

---

## Tratamento de Erros

- `set -euo pipefail` encerra o script em qualquer falha de comando ou uso de variável não definida.
- Validações de existência e permissão de diretórios antes de prosseguir.
- Mensagens de erro claras, com destaque em amarelo.

---
## Licença
Este projeto está licenciado sob a **MIT License**. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## Referências

1. Script usado como referência: 
- https://linuxconfig.org/how-to-create-incremental-backups-using-rsync-on-linux
2. Materiais de referência na configuração do Rsync:
- https://www.hostinger.com/br/tutoriais/comando-rsync-linux
- https://wiki.archlinux.org/title/Rsync
- https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-pt
3. Desenvolvimento do script e lógica de execução:
- https://aurelio.net/shell/canivete/
4. Personalização de cores e formatação da saída do terminal:
- https://wiki.archlinux.org/title/Bash/Prompt_customization
