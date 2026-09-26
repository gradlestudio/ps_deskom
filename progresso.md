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
- **Engine de Automação Nativa:** Execução de scripts PowerShell via `PowerShellService` com arquivos temporários `.ps1` codificados em UTF-8 com BOM (suporte completo a caminhos de rede e sem limites da Win32 API)
- **Backend de IA Local (Exclusivo da Edição Dev):** LM Studio Local Server (REST API `http://127.0.0.1:1234` / `qwen2.5-coder-3b-instruct` / `gemma`). A integração de IA é um subsistema exclusivo de engenharia e automação avançada, não sendo requisito de execução para as versões Básica e Pro.

## 3. Estrutura de Edições Comerciais
- **Versão Básica:** Gestão essencial de arquivos (Descompactação em lote, Cópias seguras, Movimentação com regras de colisão, Organização automática por categorias e Localização básica de arquivos por filtros).
- **Versão Pro / Full:** Recursos comerciais avançados (Auditoria profunda de duplicados por hash SHA-256, comparador visual lado a lado, tocador de áudio integrado, galeria de imagens com zoom e navegação, busca em múltiplos diretórios/redes e integração com Google Drive Desktop).
- **Versão Dev:** Recursos completos Pro + Console de Automação IA, gerador de scripts PowerShell via LLM local (LM Studio / Qwen / Gemma) e ferramentas de diagnóstico de engenharia.

## 4. Histórico de Implementações Concluídas
- [x] Diagnóstico de gargalo de performance no Desktop Commander MCP (overhead de 11.600+ tokens de ferramentas saturando a CPU do notebook).
- [x] Validação da arquitetura alternativa: chamada REST direta da IA local gerando código PowerShell limpo + execução nativa no sistema operacional.
- [x] Inicialização do projeto Flutter Desktop no Android Studio (`com.gradlestudio.ps_deskom`).
- [x] Criação da diretriz e memória operacional do projeto (`progresso.md`).
- [x] Configuração do `pubspec.yaml` com dependências (`http`, `flutter_riverpod`, `file_picker`, `path`, `audioplayers`, `url_launcher`, `shared_preferences`, `crypto`, `window_manager`) e declaração da pasta `assets/images/`.
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
- [x] Modernização e expansão do Módulo 5 (Procurar): suporte a Múltiplas Pastas (`searchPaths`), opção de busca recursiva/não-recursiva (`includeSubfolders`), modos alternáveis via SegmentedButton (`Duplicados SHA-256` e `Localizar Arquivos`), filtros por termo de nome e faixa de tamanho, e tabela de resultados com ações de abertura nativa, localização no Explorer e cópia de caminho.
- [x] Adição da dependência `window_manager: ^0.3.9` no `pubspec.yaml`, inicialização com janela maximizada e limite mínimo (1024x700) no `main()`, alinhamento exato de parâmetros de `searchPaths` em `commander_provider.dart` e ajuste responsivo na linha de filtros do Módulo 5 em `lib/main.dart` zerando overflows.
- [x] Refatoração da execução de scripts PowerShell em `PowerShellService` (`lib/services/powershell_service.dart`) para utilizar arquivos `.ps1` temporários com UTF-8 BOM, eliminando o erro de limite de tamanho de linha de comando da Win32 API (`Linha de comando muito longa / exitCode 1`) e garantindo suporte total a múltiplos caminhos longos de rede.
- [x] Resolução de overflow na barra de filtros horizontais do Módulo 5 (`lib/main.dart`) via `Flexible`/`Expanded` responsivo e implementação do modal de galeria/zoom de imagens (`ImageZoomDialog`) com ícone de lupa, suporte a pinch-to-zoom (`InteractiveViewer`) e setas de navegação lateral entre arquivos do mesmo grupo.
- [x] Consolidação da arquitetura comercial (Básica, Pro/Full, Dev) e limpeza completa de resquícios de testes legados no `progresso.md`.

## 5. Backlog Operacional (Próximos Marcos)
- [ ] Preparação dos metadados de build, versão e ícones do executável Windows.
- [ ] Compilação de produção (`flutter build windows --release`) das edições do PS DesKom.
- [ ] Estruturação do instalador modular do Windows (Inno Setup / MSI).
- [ ] Planejamento e desacoplamento do módulo de IA Local para a Versão Dev.
