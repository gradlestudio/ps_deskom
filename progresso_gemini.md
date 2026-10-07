# PS DesKom - Snapshot de Memória & Contexto Operacional (Gemini App)

## 1. Diretriz de Sincronização Obrigatória (Agente Local)
- **Leitura Inicial:** O agente deve ler prioritariamente o `progresso.md` para seguir as regras de execução técnica (Silent Mode, UTF-8 BOM, caminhos longos).
- **Atualização Dupla:** Todo prompt executado DEVE, obrigatoriamente, ser finalizado com a atualização de:
  1. `progresso.md` (detalhes técnicos, ficheiros tocados e backlog).
  2. `progresso_gemini.md` (snapshot de memória e estado consolidado).

## 2. Ambiente, Stack & Ferramentas
- **Projeto:** PS DesKom (`com.gradlestudio.ps_deskom`)
- **Plataforma Alvo:** Windows Desktop nativo (x64 Release)
- **Framework & State:** Flutter Desktop (Windows SDK / C++ Runner) + Riverpod (`commanderProvider`)
- **Agente de Código Local:** Gemini Code Assistant 3.6 Flash (AI Pro) no Android Studio
- **Empacotamento & Distribuição:** Gradle Studio Setup Engine (GSSE v1.0) - Motor de Instalação Proprietário (`GsseManifest` + `GssePackagerService` + Stub C++ `tools/gsse_stub/` com `resource.rc` Win32 e `app_icon.ico` + Footer `GSSE_V10` + View `GsseCompilerView` + Gerador NSIS `.nsi` Multilíngue)
- **Engine de Automação:** `PowerShellService` executando scripts temporários `.ps1` com codificação UTF-8 com BOM e decodificação resiliente de bytes.
- **Backend de IA Local (Exclusivo da Edição Dev e Master):** LM Studio Local Server (`LocalAiRepository` + `LmStudioRepositoryImpl` REST API `http://127.0.0.1:1234/v1` / `qwen2.5-coder-3b-instruct` com timeout de 45s e streaming SSE + View `LocalAiView` + Dropdown de seleção de modelos). Injeção condicional por Riverpod (`localAiRepositoryProvider`).
- **Licenciamento:** `LicenseService` offline baseado em HWID + SWID (`DESK-[SWID]-[HWID]`) via PowerShell + Dual-Master Key vitalícia (`GRADLE-STUDIO-DEV-2026-MASTER` e `GRADLE-STUDIO-SERVER-2026-MASTER`). Utilitários CLI em `tools/gerar_licenca.dart` e `tools/gerar_licenca.ps1`. Bot WhatsApp extraído para o projeto independente `Grad Bot Manager`.
- **Internacionalização (l10n - Etapa 5 Concluída):** `app_pt.arb`, `app_en.arb`, `app_de.arb`, `app_es.arb`, `app_fr.arb` e `app_it.arb` com `localeProvider`, exibição de GIF animado das bandeiras (`assets/flags/br.gif`, `assets/flags/uk.gif`, `assets/flags/de.gif`, `assets/flags/es.gif`, `assets/flags/fr.gif` e `assets/flags/it.gif`), injeção de tag `[LANG:XX]` na solicitação via WhatsApp e seletor rápido na TopBar. `WelcomeView` com hierarquia limpa. Re-renderização reativa do console terminal (`LogEntry`).

## 3. Decisões Arquiteturais e Lógicas Consolidadas
- **Módulo 1 (Descompactar):** Sobrescrita direta de ficheiros idênticos sem duplicar pastas. Botão "X" para limpar destino (`setDiretorioDestino('')`).
- **Módulo 1B (Compactar):** Geração de arquivo `.zip` otimizado via PowerShell `Compress-Archive` com relatório em tempo real.
- **Módulos 2 e 3 (Copiar / Mover):** Rótulos "ORIGEM" e "DESTINO", auditoria SHA-256 (`[SHA-256 OK]`), integração avançada com Google Drive Desktop (picker nativo iniciando em `Meu Drive` permitindo navegar em subpastas) e botão "X" para limpar destino (`setDestinoCopiar('')` / `setDestinoMover('')`).
- **Módulo 4 (Organizar):** Categorização automática por extensão com regras personalizadas desmarcadas por padrão (`false`), suporte recursivo e botão "X" para limpar diretório raiz (`setDiretorioOrganizar('')`).
- **Módulo 5 (Procurar / Duplicados):** SHA-256, pré-visualização de áudio/vídeo/imagem e **Exclusão Segura** enviando para a Lixeira do Windows via API .NET (`[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile` com `SendToRecycleBin`). Checkboxes visíveis de categorias de filtro.
- **Etapa 8 (Instalador Proprietário GSSE v1.0 Concluída):** Formato binário autônomo com footer de 32 bytes (`GSSE_V10`), ícone `.ico` oficial e bloco de metadados Win32 (`VS_VERSION_INFO`), extração de manifesto JSON, descompactação de payload ZIP em tempo de execução via Stub C++ Win32 (`tools/gsse_stub/`), gerador `.nsi` multilíngue e painel gerador `GsseCompilerView`.
- **Módulo de IA Local (Desacoplado & UI Pronta):** Repositório abstrato `LocalAiRepository`, implementação REST `LmStudioRepositoryImpl` com SSE stream e POST chat completions, restrito às edições `MASTER` e `DEV-*`, exibido na view `LocalAiView` e atalho "IA LOCAL" na barra de navigation superior. Dropdown de modelos dinâmico via `getAvailableModels()`. Zero hardcoded strings (100% l10n).
- **Console Terminal Reativo:** Lista `logEntries` com resolução por chave `AppLocalizations` re-renderizada automaticamente ao mudar o idioma na TopBar + suporte a streaming nativo de linhas do PowerShell (`onLog`).
- **Conectar IA (Cloud BYOK):** Modal `ConnectAiDialog` para cadastro de chaves API (Gemini clouds, Claude, ChatGPT, Custom REST API) salvas via `SharedPreferences`.
- **Login com Google (OAuth2 Desktop Loopback):** `GoogleAuthService` com servidor HTTP local na porta 8088 (`127.0.0.1:8088`), parâmetro obrigatório `response_type=code`, `access_type=offline`, captura e troca de código e persistência de perfil real (`name`, `email`, `picture`) exibido dinamicamente em `GoogleLoginDialog`.
- **Páginas Institucionais (GitHub Pages):** Documentos `docs/index.html`, `docs/privacy.html` e `docs/terms.html`.
- **Boas-Vindas Obrigatórias:** O aplicativo inicia incondicionalmente na `WelcomeView` no arrasto inicial de todas as edições.
- **Desacoplamento do Grad Bot:** Projeto do bot completamente desindexado do PS DesKom e migrado para `Grad Bot Manager`.
- **ProgressStatusCard na GSSE View:** Substituição do console bruto por card visual com estados (Ocioso, Processando, Sucesso, Falha).
- **Console Global Condicional & Fallback MASTER:** Ocultação do console de rodapé e botão "Limpar Console" nas abas Compilador e IA Local, e fallback nativo para `MASTER` em `APP_EDITION`.
- **Layout Responsivo e UI Compilador:** Wraps nos cabeçalhos de Origem e Destino zerando overflows, campos do compilador iniciados vazios com obrigatoriedade e validação reativa do botão de compilar.
- **Auditoria Estrutural de Ponta a Ponta:** Proteção de inicialização `windowManager`, eliminação de `listSync` da thread principal do compilador e desacoplamento com `ListenableBuilder`.
- **GSSE Packager Portability:** Neutralização total de `Directory.current`, resolução dinâmica de diretórios via `Platform.resolvedExecutable`, busca portátil do NSIS e extração segura de ícone para `%TEMP%`.
- **Win32 WindowManager Initialization:** Inicialização síncrona com `backgroundColor: Color(0xFF1E1E1E)` e encadeamento sequencial prevenindo erros de DWM.
- **FilePicker Win32 Hardening:** Substituição do FilePicker por `FolderBrowserDialog` isolado via PowerShell nativo em `lib/views/gsse_compiler_view.dart`, zerando falhas de memória e crashes.

## 4. Estado Atual & Backlog Imediato
- [x] Correção de codificação UTF-8 no arquivo `eula.txt`.
- [x] Implementação de exclusão segura para a Lixeira do Windows no Módulo 5 (Procurar).
- [x] Configuração dos metadados oficiais de produção do executável Windows (`windows/runner/Runner.rc`).
- [x] Implementação de gerador/validador de Chaves de Licença (License Key Generator) para clientes comerciais vinculadas ao HWID (`tools/gerar_licenca.dart` e `tools/gerar_licenca.ps1`).
- [x] Integração de solicitação de chave via WhatsApp Business (+55 85 99642-1006) no `ActivationDialog`.
- [x] Atualização UX do Bot de Licenciamento WhatsApp em Node.js (`tools/whatsapp_bot/bot.js` com envio de bloco monospaçado).
- [x] Ajustes de UI/UX (Rótulos ORIGEM/DESTINO, categorias desmarcadas por padrão no Módulo 4, botão "X" para limpar destino).
- [x] Correção de reatividade no botão "X" de limpeza de caminho de destino nos Módulos Descompactar, Copiar, Mover e Organizar.
- [x] Refinamento da navegação e seleção de subpastas/criação de diretórios no Google Drive Desktop.
- [x] Atualização de formato `DESK-[SWID]-[HWID]` no Flutter e Licença Master Admin no Bot WhatsApp em Node.js.
- [x] Configuração da infraestrutura de Internacionalização (l10n - pt, en, de, es, fr, it) e exibição de GIFs das bandeiras no seletor rápido (🇧🇷 PT / 🇺🇸 EN / 🇩🇪 DE / 🇪🇸 ES / 🇫🇷 FR / 🇮🇹 IT).
- [x] Alinhamento e resolução de dependências no `pubspec.yaml` (`flutter_riverpod`, `file_picker`).
- [x] Varredura e substituição de strings hardcoded no `main.dart` por getters reativos de `AppLocalizations`.
- [x] Limpeza de `l10n.yaml` e tradução completa dos Empty States e Categorias de Organização.
- [x] Internacionalização integral e irrestrita (Zero Hardcoded Strings) no `AboutDialogWidget`, Console e Módulos.
- [x] Internacionalização abrangente do Modal do Manual (`ManualHelpDialog` em `lib/widgets/manual_help_dialog.dart` - 4 abas).
- [x] Vinculação reativa de l10n para Empty States do Módulo Procurar.
- [x] Internacionalização do Diálogo de Ativação de Licença (`ActivationDialog`) em PT, EN, DE, ES, FR e IT.
- [x] Injeção dinâmica de tag `[LANG:XX]` no link do WhatsApp e conclusão total da Etapa 5 (l10n).
- [x] Refatoração multilíngue do Bot de Licenciamento WhatsApp em Node.js (`tools/whatsapp_bot/bot.js` com tag `[LANG:XX]` e DDI).
- [x] Compilação Release da edição Master/Admin gerada em `dist/PS_DesKom_Master/` (Etapa 6.1).
- [x] Criação da tela de Boas-Vindas/Onboarding (`WelcomeView`) com hierarquia limpa (logo do produto no topo, desenvolvedora no rodapé).
- [x] Implementação da máquina de estados do Atendente Virtual Grad Bot (`fluxoAtendimento.js` e `gerenciadorAtendimento.js`) integrada ao `bot.js` (Etapa 7).
- [x] Calibração da primeira interação no Grad Bot sem aviso de opção inválida no acolhimento (`gerenciadorAtendimento.js`).
- [x] Fixação e calibração textual da persona Grad no atendente comercial em PT-BR (`fluxoAtendimento.js`).
- [x] Remoção do cabeçalho estático do Grad Bot com início direto na saudação humana (`fluxoAtendimento.js`).
- [x] Painel de Gerenciador do Grad Bot no Flutter (`BotControlDialog` / `bot_manager_service.dart`) restrito à Edição Master (Etapa 6.3).
- [x] Sanitização de sequências ANSI e fixação UTF-8 nos comandos PM2 do `BotManagerService`.
- [x] Ampliação do `BotControlDialog` (880px) com scroll horizontal sem quebra de tabela (`bot_control_dialog.dart`).
- [x] Compilação em lote de todas as 8 edições comerciais e dev do PS DesKom em `dist/` concluída.
- [x] Modelagem do `GsseManifest` e implementação do `GssePackagerService` (Etapa 8.1).
- [x] Código-fonte C++ Win32 do Stub Nativo GSSE e script `build_stub.ps1` criados e testados (`tools/gsse_stub/` e `assets/tools/gs_stub.exe`) (Etapa 8.2).
- [x] Implementação da `GsseCompilerView` e aba "COMPILAR INSTALADOR" com 100% l10n nos 6 idiomas (Etapa 8.3).
- [x] Conclusão e validação da Etapa 8: Gradle Studio Setup Engine (GSSE v1.0 com ícone `.ico` oficial e metadados Win32) (Etapa 8.4).
- [x] Tratativa defensiva e atenuação assíncrona na `GsseCompilerView` para prevenir crash do seletor Win32 (`gsse_compiler_view.dart`).
- [x] Polimento de UI (zero scroll) na `GsseCompilerView` e atualização Unicode `MessageBoxW` no stub GSSE (`main.cpp`).
- [x] Refinamento de UX com placeholders dinâmicos, auto-preenchimento de origem e alinhamento de checkboxes na `GsseCompilerView`.
- [x] Correção do comando de inicialização PM2 no `BotManagerService` apontando para `tools/whatsapp_bot/bot.js`.
- [x] Deteção de DDI com fallback padrão em Português (`bot.js`) e notificação de leads para múltiplos JIDs do admin com expansão do menu setor para 7 opções (`gerenciadorAtendimento.js` e `fluxoAtendimento.js`) (Etapa 7.4).
- [x] Compilação real MSVC x64 do Stub GSSE (`cl.exe` + `rc.exe`) gerando binário final em `assets/tools/gs_stub.exe`.
- [x] Suporte multilíngue no gerador NSIS (.nsi) com `MUI_LANGDLL_DISPLAY` e gravação de chave no registro HKCU (`gsse_packager_service.dart`).
- [x] Varredura prévia com taskkill preventivo e sobrescrita limpa na `GsseCompilerView` (`gsse_compiler_view.dart`).
- [x] Remoção do taskkill sobre o executável principal `ps_deskom.exe` na `GsseCompilerView`.
- [x] Desacoplamento da IA Local (`LocalAiRepository` + `LmStudioRepositoryImpl` + `localAiRepositoryProvider`) restrita às edições MASTER e DEV-*.
- [x] Implementação da `LocalAiView` (`local_ai_view.dart`) e botão "IA LOCAL" no header do `main.dart` para edições Master e Dev.
- [x] Regra de i18n estrito no `progresso.md` e homologação multilíngue completa da `LocalAiView`.
- [x] Stream de saída nativa de processos PowerShell, checkboxes no Módulo Procurar e extração de número limpo no Grad Bot.
- [x] Implementação completa da Versão 1.1: Módulo Compactar (.zip), Modal Conectar IA (BYOK) e Login Google.
- [x] Correção do parâmetro `response_type=code` e servidor loopback local no `GoogleAuthService` (`google_auth_service.dart`).
- [x] Criação de `docs/index.html`, `docs/privacy.html` e `docs/terms.html` para hospedagem de termos legais via GitHub Pages.
- [x] Captura e exibição de perfil real do Google (`name`, `email`, `picture`) no `GoogleAuthService` e `GoogleLoginDialog`.
- [x] Inicialização obrigatória na tela de boas-vindas (`WelcomeView`) configurada no `main.dart`.
- [x] Fase B de desacoplamento do Grad Bot e limpeza de resíduos no PS DesKom concluída.
- [x] Compilador GSSE evoluído para suporte duplo (Modo Universal Single App e Modo Lote PS DesKom).
- [x] Substituição do console bruto pelo ProgressStatusCard na visão do compilador GSSE.
- [x] Ocultação condicional do console de rodapé e fallback nativo para edição MASTER configurados.
- [x] Refinamento de UI/UX, cabeçalhos responsivos com Wrap e validação de botões no compilador GSSE.
- [x] Auditoria estrutural de ponta a ponta e estabilização do core concluída.
- [x] Extração dinâmica de ícone do instalador para %TEMP% no GSSE Packager concluída.
- [x] Correção estrutural da inicialização Win32 e WindowManager no main.dart concluída.
- [x] Substituição do FilePicker por FolderBrowserDialog isolado via PowerShell nativo concluída.
- [ ] Planejamento e execução de testes de integração com LM Studio ativo e validação do fluxo de automação PowerShell.
