# PS DesKom - Memória de Desenvolvimento & Status Operacional

## 1. Regras Operacionais de Prompting
- **MODO SILENCIOSO ESTRITO (SILENT MODE):** Proibido gerar respostas prolixas, resumos ou explicações teóricas no chat.
- **AÇÃO DIRETA:** Modificar/criar arquivos diretamente no disco utilizando as ferramentas de edição.
- **ATUALIZAÇÃO DE MEMÓRIA (OBRIGATÓRIO A CADA PROMPT):** Todo prompt executado DEVE, obrigatoriamente, ser finalizado com a atualização deste arquivo `progresso.md` (marcando itens concluídos, atualizando arquivos tocados e mantendo o backlog em dia).
- **RESPOSTA EXCLUSIVA:** A resposta final no chat deve conter APENAS a lista dos caminhos de arquivos modificados/criados (incluindo o próprio `progresso.md`).

## 2. Stack & Arquitetura
- **Plataforma Alvo:** Windows Desktop (`.exe` nativo)
- **Organization / Package:** `com.gradlestudio.ps_deskom`
- **Framework:** Flutter (Windows SDK / C++ Runner)
- **Gerenciamento de Estado:** Riverpod (`commanderProvider`)
- **Design System:** Fluent UI / Windows Modern Dark Theme (`#1E1E1E` background, `#252526` cards/containers, `#0078D4` Windows Blue de destaque, texto de alto contraste)
- **Backend de IA Local:** LM Studio Local Server (REST API `http://127.0.0.1:1234`)
- **Modelo LLM Padrão:** `qwen2.5-coder-3b-instruct` (inferência rápida sem overhead)
- **Engine de Automação:** Execução nativa de processos via `dart:io` chamando `powershell.exe` (`-NoProfile`, `-ExecutionPolicy Bypass`, `-EncodedCommand`)
- **Estratégia de Prompting:** System Prompt cirúrgico (zero MCP, resposta restrita a scripts PowerShell puros sem markdown)

## 3. Mapeamento de Recursos & Endpoints
- **LM Studio Server:** `http://127.0.0.1:1234/api/v0/chat/completions` (ou endpoint v1 compatível)
- **Diretório de Testes Operacionais:** `D:\GRADLE STUDIO\Avulso DEV\TESTES\`
- **Pastas de Trabalho do Caso BeamNG:**
    - Origem dos zips: `D:\GRADLE STUDIO\Avulso DEV\TESTES\BRASILEIROS`
    - Destino das pastas: `D:\GRADLE STUDIO\Avulso DEV\TESTES\CARROS BEAMNG`

## 4. Histórico de Implementações Concluídas
- [x] Diagnóstico de gargalo de performance no Desktop Commander MCP (overhead de 11.600+ tokens de ferramentas saturando a CPU do notebook).
- [x] Validação da arquitetura alternativa: chamada REST direta da IA local gerando código PowerShell limpo + execução nativa no sistema operacional.
- [x] Inicialização do projeto Flutter Desktop no Android Studio (`com.gradlestudio.ps_deskom`).
- [x] Criação da diretriz e memória operacional do projeto (`progresso.md`).
- [x] Configuração do `pubspec.yaml` com dependências (`http`, `flutter_riverpod`, `file_picker`, `path`, `audioplayers`, `url_launcher`, `shared_preferences`, `crypto`) e declaração da pasta `assets/images/`.
- [x] Implementação da camada de serviço (`lib/services/lmstudio_service.dart`, `lib/services/powershell_service.dart`, `lib/services/license_service.dart` e `lib/services/update_service.dart`).
- [x] Implementação do gerenciador de estado Riverpod (`lib/providers/commander_provider.dart`).
- [x] Construção da interface gráfica Fluent Design Dark Mode em `lib/main.dart` com visualizador/editor de scripts e console terminal integrado.
- [x] Implementação completa do Módulo 1 (DESCOMPACTAR) com seleção de arquivos/pasta, extração em lote por PowerShell e barra de progresso.
- [x] Implementação do Módulo 2 (COPIAR) no `PowerShellService`, `CommanderNotifier` e `main.dart` com seleção de arquivos/pastas, regras de colisão e execução nativa em lote.
- [x] Implementação do Módulo 3 (MOVER) no `PowerShellService`, `CommanderNotifier` e `main.dart` com movimentação em lote, tratamento de sobrescrita/erros e barra de progresso.
- [x] Implementação do Módulo 4 (ORGANIZAR) no `PowerShellService`, `CommanderNotifier` e `main.dart` com categorização automática por extensão, suporte a regras customizadas e opção recursiva.
- [x] Implementação da arquitetura base do Módulo 5 (PROCURAR / Duplicados com SHA-256 e Comparação Visual Lado a Lado) no `PowerShellService`, `CommanderNotifier` e `main.dart` com deleção e renomeação seguras.
- [x] Suporte universal a tipos de arquivo no Módulo 5 (Procurar) com seletores de categoria ('todos', 'imagens', 'videos', 'audios', 'textos', 'instaladores'), extração de metadados de versão de executáveis via PowerShell e leitores/pré-visualizadores dinâmicos no frontend.
- [x] Correção de alinhamento de parâmetros no `commander_provider.dart`, atualização do widget test para `PSDesKomApp` em `widget_test.dart` e resolução completa dos overflows visuais (28px no topo e 237px no painel de comparação) no `main.dart`.
- [x] Implementação do mecanismo de cancelamento de processos assíncronos no Módulo 5 (Procurar) via `Process.start` e `cancelarOperacaoAtiva()` no `PowerShellService`, controle de estado `isEscaneando` no Riverpod e botão dinâmico "INTERROMPER BUSCA" na UI do `main.dart`.
- [x] Ajuste de codificação de saída PowerShell (`[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`) e decodificação resiliente de bytes (`utf8.decode(..., allowMalformed: true)`) no `PowerShellService` para suporte completo a nomes de arquivos/diretórios com caracteres especiais e acentuação no Windows.
- [x] Adição da dependência `audioplayers: ^6.0.0` no `pubspec.yaml`, criação do componente `AudioPreviewCard` (`lib/widgets/audio_preview_card.dart`) com controles de play/pause, slider de progresso, formatação mm:ss e mute/volume, e integração no Módulo 5 (Procurar) do `lib/main.dart` com descarte e liberação segura do player ao alternar de grupo.
- [x] Implementação de deteção automática do caminho local do Google Drive Desktop (`detectarCaminhoGoogleDrive()`), suporte a pipelines combinados (Copiar+Organizar e Mover+Organizar no `PowerShellService`) com checkbox de classificação automática no destino e ação "Mover e Organizar Não Duplicados" no Módulo 5 (Procurar).
- [x] Configuração da dependência `url_launcher: ^6.3.0` e declaração de assets em `pubspec.yaml`, criação do modal comercial `AboutDialogWidget` (`lib/widgets/about_dialog_widget.dart`) com logo da Gradle Studio, animação de créditos estilo cinema em rolagem contínua, ações rápidas (Verificar Atualizações, Ativação de Licença HWID, Manual/Ajuda) e links de contato (Instagram, WhatsApp, E-mail).
- [x] Otimização da rolagem contínua em loop infinito suave sem barra de rolagem visível no `AboutDialogWidget` (`lib/widgets/about_dialog_widget.dart`) e adição de banner com ação de reprodução nativa instantânea via `explorer.exe` para mídias de vídeo no Módulo 5 de `lib/main.dart`.
- [x] Remoção do badge legado LM Studio da TopBar de `lib/main.dart` com simplificação do título para "PS DesKom", e ajuste fino da animação de créditos em ping-pong contínuo suave no `AboutDialogWidget` (`lib/widgets/about_dialog_widget.dart`).
- [x] Implementação do serviço de licenças `LicenseService` (`lib/services/license_service.dart`) com geração de HWID criptográfico por PowerShell, validação offline por algoritmo determinístico, bypass via Master Key (`GRADLE-STUDIO-DEV-2026-MASTER`), suporte a SharedPreferences (`pubspec.yaml`), componente `ActivationDialog` (`lib/widgets/activation_dialog.dart`) e integração com badges de status no `AboutDialogWidget`.
- [x] Implementação do serviço de atualizações `UpdateService` (`lib/services/update_service.dart`) integrado ao endpoint da Gradle Studio no GitHub, modal `UpdateDialog` (`lib/widgets/update_dialog.dart`) com changelog e botão de download, checagem silenciosa na inicialização e verificação manual com SnackBar em `about_dialog_widget.dart` e TopBar em `main.dart`.
- [x] Criação do componente `ManualHelpDialog` (`lib/widgets/manual_help_dialog.dart`) com navegação por 4 abas interativas (Módulos do Sistema, Duplicados & Mídia, Dicas & Nuvem, Suporte & Licença) e conexão direta ao botão "Manual / Ajuda" do `AboutDialogWidget`.

## 5. Backlog Imediato
- [x] Manual e Guia de Ajuda Rápida Integrado.
- [ ] Testes operacionais nos diretórios de teste (`D:\GRADLE STUDIO\Avulso DEV\TESTES\`).
- [ ] Validação do fluxo de descompactação do caso BeamNG (`D:\GRADLE STUDIO\Avulso DEV\TESTES\BRASILEIROS` -> `D:\GRADLE STUDIO\Avulso DEV\TESTES\CARROS BEAMNG`).
- [ ] Teste de geração de comandos IA via LM Studio REST API (`127.0.0.1:1234`).
