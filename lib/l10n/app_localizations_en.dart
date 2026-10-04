// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PS DesKom';

  @override
  String get descompactar => 'UNPACK';

  @override
  String get copiar => 'COPY';

  @override
  String get mover => 'MOVE';

  @override
  String get organizar => 'ORGANIZE';

  @override
  String get procurar => 'SEARCH';

  @override
  String get origem => 'SOURCE';

  @override
  String get destino => 'DESTINATION';

  @override
  String get adicionarArquivos => '(+) Add Files';

  @override
  String get adicionarPasta => '(+) Folder';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get adicionarGoogleDrive => '(+) Google Drive';

  @override
  String get selecionarPasta => 'Select Folder';

  @override
  String get buscarPasta => 'Browse Folder';

  @override
  String get limparConsole => 'Clear Console';

  @override
  String get sobre => 'About';

  @override
  String get limparDestino => 'Clear destination';

  @override
  String get caminhoDestino => 'Destination Path:';

  @override
  String get diretorioRaiz => 'ROOT DIRECTORY TO ORGANIZE:';

  @override
  String get nenhumDiretorioSelecionado => 'No directory selected.';

  @override
  String get descompactarAgora => 'EXTRACT NOW';

  @override
  String get iniciarCopia => 'START COPY';

  @override
  String get moverArquivos => 'MOVE FILES';

  @override
  String get organizarPasta => 'ORGANIZE FOLDER';

  @override
  String get escanearDuplicados => 'SCAN DUPLICATES';

  @override
  String get localizarArquivos => 'LOCATE FILES';

  @override
  String get interromperBusca => 'STOP SEARCH';

  @override
  String get auditarSha256 => 'Audit transfer integrity (SHA-256 Hash)';

  @override
  String get organizarAposTransferir =>
      'Automatically organize by categories at destination';

  @override
  String get sobrescreverExistentes =>
      'Overwrite files if they already exist at destination';

  @override
  String get criarSubpastaExtracao =>
      'Create a folder with file name for each extraction';

  @override
  String get duplicadosSha256 => 'Duplicates (SHA-256)';

  @override
  String get incluirSubpastas => 'Include subfolders (Recursive)';

  @override
  String get atualizacaoDisponivel => 'Update Available';

  @override
  String get aguardandoAcao => 'Awaiting user action...';

  @override
  String get terminalPronto => 'Terminal ready. Operational module ready.';

  @override
  String get nenhumArquivoDescompactar =>
      'No files added to queue.\nClick \'(+) Add Files\' (.zip, .rar, .7z)';

  @override
  String get nenhumItemCopiar =>
      'No items added for copy.\nUse \'(+) Files\', \'(+) Folder\' or \'(+) Google Drive\'.';

  @override
  String get nenhumItemMover =>
      'No items added for move.\nUse \'(+) Files\', \'(+) Folder\' or \'(+) Google Drive\'.';

  @override
  String get regraColisaoDuplicados => 'COLLISION / DUPLICATES RULE:';

  @override
  String get substituirExistentes => 'Replace existing (Overwrite)';

  @override
  String get pularDuplicados => 'Skip duplicates (Ignore if exists)';

  @override
  String get manterAmbos => 'Keep both (Create renamed copy)';

  @override
  String get categoriasEregras => 'ORGANIZATION CATEGORIES AND RULES';

  @override
  String get documentosPdf => 'PDF Documents';

  @override
  String get wordDoc => 'Word Doc';

  @override
  String get planilhas => 'Spreadsheets';

  @override
  String get musicas => 'Music';

  @override
  String get videos => 'Videos';

  @override
  String get imagens => 'Images';

  @override
  String get arquivosCompactados => 'Compressed Files';

  @override
  String get instaladores => 'Installers';

  @override
  String get regraPersonalizada => 'Custom Rule:';

  @override
  String get hintNomePasta => 'Folder Name Ex: Textures DDS';

  @override
  String get adicionarPastaBusca => '+ Add Folder';

  @override
  String get todasMidias => 'All Media';

  @override
  String get qualquerTamanho => 'Any Size';

  @override
  String get hintBuscarNomeExtensao =>
      'Search by name or extension (e.g. .log)...';

  @override
  String get nenhumConflitoDetectado =>
      'No duplicate files or conflicts detected.';

  @override
  String get orientacaoEscaneanarDuplicados =>
      'Add one or more folders and click \'SCAN DUPLICATES\'.';

  @override
  String get nenhumArquivoLocalizado => 'No files found.';

  @override
  String get orientacaoLocalizarArquivos =>
      'Add one or more folders and click \'LOCATE FILES\'.';

  @override
  String get versao => 'Version 1.0.0 (Build 2026)';

  @override
  String get desenvolvidoPor => 'Developed by Gradle Studio';

  @override
  String get arquiteturaEngenharia => 'SOFTWARE ARCHITECTURE & ENGINEERING';

  @override
  String get producaoDesign => 'PRODUCTION & DESIGN';

  @override
  String get tecnologiasNativas => 'NATIVE TECHNOLOGIES';

  @override
  String get avisoLegalEula => 'LEGAL NOTICE & EULA';

  @override
  String get textoAvisoLegal =>
      'This software is provided \"AS IS\", without express or implied warranties. The user is solely responsible for validating and confirming deletions and modifications to their disks and partitions.';

  @override
  String get direitosReservados => 'All rights reserved © 2026 Gradle Studio.';

  @override
  String get verificarAtualizacoes => 'Check for Updates';

  @override
  String get ativacaoLicenca => 'License Activation';

  @override
  String get manualAjuda => 'Manual / Help';

  @override
  String get fechar => 'Close';

  @override
  String get manualTitulo => 'PS DesKom — Manual & Quick Guide';

  @override
  String get manualSubtitulo =>
      'Operational instructions and file management best practices.';

  @override
  String get abaModulos => '1. System Modules';

  @override
  String get abaDuplicados => '2. Duplicates & Media';

  @override
  String get abaNuvem => '3. Tips & Cloud';

  @override
  String get abaSuporte => '4. Support & License';

  @override
  String get fecharManual => 'Close Manual';

  @override
  String get mod1Titulo => 'Module 1: UNPACK';

  @override
  String get mod1Desc =>
      'Batch extracts compressed files (.zip, .rar, .7z, .tar) via native PowerShell. Enable \"Create folder with archive name\" to keep the destination organized.';

  @override
  String get mod2Titulo => 'Module 2: COPY';

  @override
  String get mod2Desc =>
      'Copies files or entire folders to the configured destination with customizable collision rules: Overwrite, Skip duplicates, or Keep Both (rename).';

  @override
  String get mod3Titulo => 'Module 3: MOVE';

  @override
  String get mod3Desc =>
      'Transfers items across the same drive or between volumes. Supports overwriting existing files and handles Windows permission errors.';

  @override
  String get mod4Titulo => 'Module 4: ORGANIZE';

  @override
  String get mod4Desc =>
      'Automatically sorts loose files into thematic subfolders (PDF Documents, Music, Images, Videos, Installers, etc.). Allows creating custom extension-based rules.';

  @override
  String get mod5Titulo => 'Module 5: SEARCH';

  @override
  String get mod5Desc =>
      'Scans directories for duplicate files using SHA-256 binary hash and identical file names. Provides side-by-side comparison.';

  @override
  String get sha256Titulo => 'SHA-256 Cryptographic Analysis';

  @override
  String get sha256Desc =>
      'The scan performs a preliminary triage by file size and then computes the SHA-256 hash of the contents to guarantee 100% certainty when identifying identical duplicates.';

  @override
  String get audioTitulo => 'Integrated Audio Player';

  @override
  String get audioDesc =>
      'Audio files (.mp3, .wav, .flac, .aac, .m4a) have their own previewer in comparison cards with a progress slider, play/pause button, and instant mute.';

  @override
  String get videoTitulo => 'Video and File Playback';

  @override
  String get videoDesc =>
      'Video media and executables feature a quick-action \"Open in Default Player\" button, allowing media playback in Windows\' native player in 0ms.';

  @override
  String get buscaSeguraTitulo => 'Safe Search Interruption';

  @override
  String get buscaSeguraDesc =>
      'At any time during a long scan, click \"STOP SEARCH\". The background process will be safely terminated via taskkill without freezing the app.';

  @override
  String get driveTitulo => 'Google Drive Desktop Integration';

  @override
  String get driveDesc =>
      'If the Google Drive Desktop application is installed on Windows, PS DesKom will automatically detect the drive and display the \"Google Drive\" button in destination selectors.';

  @override
  String get pipelinesTitulo => 'Combined Pipelines (Transfer + Organize)';

  @override
  String get pipelinesDesc =>
      'In Copy and Move modules, check \"Automatically organize by categories at destination\". Files will be transferred and immediately sorted into appropriate subfolders.';

  @override
  String get otimizacaoTitulo => 'Disk and Network Optimization';

  @override
  String get otimizacaoDesc =>
      'The engine operates directly on Windows PowerShell Core encoded in UTF-16LE EncodedCommand, ensuring high performance even when handling large volumes on NAS or external HDDs.';

  @override
  String get licencaHwidTitulo => 'Offline HWID Licensing';

  @override
  String get licencaHwidDesc =>
      'PS DesKom is activated using your computer\'s unique hardware identifier (HWID). Once activated, the license is permanent and does not require a constant internet connection.';

  @override
  String get atualizacoesTitulo => 'Lifetime Updates Included';

  @override
  String get atualizacoesDesc =>
      'All new versions and improvements released by Gradle Studio on the official repository are included free of charge for licensed customers.';

  @override
  String get canaisSuporteTitulo => 'Official Support Channels';

  @override
  String get ativacaoTitulo => 'PS DesKom Activation';

  @override
  String get identificadorComputador => 'COMPUTER IDENTIFIER (HWID):';

  @override
  String get copiarHwid => 'Copy';

  @override
  String get solicitarChaveWhats => 'Request Key via WhatsApp';

  @override
  String get chaveLicencaRotulo => 'LICENSE KEY:';

  @override
  String get hintChaveLicenca => 'Enter your key (e.g. KEY-XXXX-YYYY-ZZZZ)';

  @override
  String get validarAtivarLicenca => 'Validate and Activate License';

  @override
  String get bemVindoTitulo => 'Welcome to PS DesKom';

  @override
  String get bemVindoSubtitulo => 'Select your preferred language to begin:';

  @override
  String get iniciarSistema => 'Launch PS DesKom';

  @override
  String get edicaoMasterAtiva => 'Master Edition — Active Administrator';

  @override
  String get abaCompilarInstalador => 'BUILD INSTALLER';

  @override
  String get tituloCompiladorGsse =>
      'GSSE Installer Compiler (Gradle Studio Setup Engine)';

  @override
  String get labelNomeSoftware => 'Application Name:';

  @override
  String get labelVersaoSoftware => 'Application Version:';

  @override
  String get labelDesenvolvedorSoftware => 'Developer / Publisher:';

  @override
  String get labelPastaOrigem => 'Source Directory of Files:';

  @override
  String get btnSelecionarOrigem => 'Select Source';

  @override
  String get hintOrigemVazia => 'No source directory selected...';

  @override
  String get labelExecutavelPrincipal => 'Main Application Executable (.exe):';

  @override
  String get hintSelecioneExecutavel => 'Select main executable (.exe)';

  @override
  String get labelPastaSaida => 'Output Directory for Generated Installer:';

  @override
  String get btnSelecionarSaida => 'Select Output';

  @override
  String get optAtalhoDesktop => 'Create Desktop shortcut';

  @override
  String get optAtalhoMenuIniciar => 'Create Start Menu shortcut';

  @override
  String get optExecutarAposInstalar =>
      'Launch application immediately after installation';

  @override
  String get btnCompilarAgora => 'BUILD GSSE INSTALLER';

  @override
  String get msgCompilandoInstalador =>
      'Compiling and packaging standalone GSSE installer...';

  @override
  String get msgInstaladorSucesso => 'GSSE Installer built successfully!';

  @override
  String get btnAbrirPasta => 'Open Output Folder';

  @override
  String get hintNomeSoftware => 'e.g. My Software...';

  @override
  String get hintVersaoSoftware => 'e.g. 1.0.0';

  @override
  String get hintDesenvolvedorSoftware => 'e.g. Gradle Studio...';

  @override
  String get selecionarTodasEdicoes => 'Select All';

  @override
  String get btnCompilarSelecionados => 'BUILD SELECTED INSTALLERS';

  @override
  String get iaLocal => 'LOCAL AI';

  @override
  String get tituloIaLocal => 'Local AI & Automation Console (LM Studio)';

  @override
  String get statusConectadoIa => 'Connected to LM Studio (127.0.0.1:1234)';

  @override
  String get statusDesconectadoIa =>
      'Disconnected (Ensure LM Studio is running)';

  @override
  String get btnTestarConexao => 'Test Connection';

  @override
  String get btnEnviarPrompt => 'SEND PROMPT';

  @override
  String get hintDigitarPromptIa =>
      'Enter instructions for AI to generate PowerShell automation...';

  @override
  String get modelosPredefinidos => 'Quick Automation Presets:';

  @override
  String get subtituloIaLocal =>
      'Local Qwen2.5-Coder engine for autonomous PowerShell script generation';

  @override
  String get presetIaMaiorArquivo => 'List the 10 largest files on drive C:';

  @override
  String get presetIaLimparTemp =>
      'Clean temporary files and system cache (%TEMP%)';

  @override
  String get presetIaAuditarRede =>
      'Audit shared folders and network permissions';

  @override
  String get presetIaBackupZip =>
      'Create compressed backup routine (.zip) with date in name';

  @override
  String get labelCodigoGeradoIa => 'Generated PowerShell Code:';

  @override
  String get hintRespostaIa => 'Model response will appear here...';

  @override
  String get btnInterromperIa => 'INTERRUPT';

  @override
  String get tooltipCopiarCodigo => 'Copy Code';

  @override
  String get tooltipExecutarPs => 'Execute in Native PowerShell';

  @override
  String get msgCodigoCopiado => 'Code copied to Clipboard!';

  @override
  String statusLicencaLog(String status, String hwid) {
    return 'License Status: $status (HWID: $hwid)';
  }

  @override
  String googleDriveDetectadoConsole(String path) {
    return 'Google Drive Desktop detected at path: $path';
  }

  @override
  String get googleDriveNaoEncontradoConsole =>
      'Google Drive Desktop not found on system volumes.';

  @override
  String get aguardandoAcaoUsuario => 'Awaiting user action...';

  @override
  String get limpandoConsole => 'Clearing console...';

  @override
  String get console_copy_running => 'Executing Windows batch copy...';

  @override
  String console_copy_start(int count) {
    return 'Starting batch copy of $count item(s)...';
  }

  @override
  String console_copy_dest(String dir) {
    return 'Destination Directory: $dir';
  }

  @override
  String console_copy_collision(String rule) {
    return 'Collision Rule: $rule';
  }

  @override
  String console_copy_organize(String value) {
    return 'Organize at Destination: $value';
  }

  @override
  String console_copy_audit(String value) {
    return 'SHA-256 Audit: $value';
  }

  @override
  String get console_copy_success => 'All copies completed.';

  @override
  String get console_ai_title => 'LOCAL AI AUTOMATION REQUEST (LM STUDIO)';

  @override
  String console_ai_model(String model) {
    return 'Model: $model';
  }

  @override
  String console_ai_prompt(String prompt) {
    return 'Prompt: $prompt';
  }

  @override
  String get console_ai_success =>
      '[SUCCESS] Code generated successfully via LM Studio.';

  @override
  String get console_ai_timeout =>
      '[AI ERROR] Connection timeout with LM Studio.';

  @override
  String get console_copy_batch_finished =>
      'Batch copy completed successfully!';

  @override
  String get compactar => 'COMPRESS';

  @override
  String get tituloModuloCompactar =>
      'Module 1B: Batch File Compression (.zip)';

  @override
  String get labelNomeArquivoZip => 'Archive Name (.zip):';

  @override
  String get btnCompactarAgora => 'COMPRESS BATCH FILES';

  @override
  String get modalConectarIa => 'Connect AI';

  @override
  String get provedorIa => 'AI Provider:';

  @override
  String get chaveApiKey => 'API Key:';

  @override
  String get btnValidarChave => 'Validate & Save Key';

  @override
  String get entrarComGoogle => 'Sign in with Google';

  @override
  String get desconectarConta => 'Sign Out';
}
