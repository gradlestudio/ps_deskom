// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'PS DesKom';

  @override
  String get descompactar => 'DECOMPRIMI';

  @override
  String get copiar => 'COPIA';

  @override
  String get mover => 'SPOSTA';

  @override
  String get organizar => 'ORGANIZZA';

  @override
  String get procurar => 'CERCA';

  @override
  String get origem => 'ORIGINE';

  @override
  String get destino => 'DESTINAZIONE';

  @override
  String get adicionarArquivos => '(+) Aggiungi File';

  @override
  String get adicionarPasta => '(+) Cartella';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get adicionarGoogleDrive => '(+) Google Drive';

  @override
  String get selecionarPasta => 'Seleziona Cartella';

  @override
  String get buscarPasta => 'Sfoglia Cartella';

  @override
  String get limparConsole => 'Pulisci Console';

  @override
  String get sobre => 'Informazioni';

  @override
  String get limparDestino => 'Cancella destinazione';

  @override
  String get caminhoDestino => 'Percorso di Destinazione:';

  @override
  String get diretorioRaiz => 'DIRECTORY PRINCIPALE DA ORGANIZZARE:';

  @override
  String get nenhumDiretorioSelecionado => 'Nessuna directory selezionata.';

  @override
  String get descompactarAgora => 'DECOMPRIMI ORA';

  @override
  String get iniciarCopia => 'AVVIA COPIA';

  @override
  String get moverArquivos => 'SPOSTA FILE';

  @override
  String get organizarPasta => 'ORGANIZZA CARTELLA';

  @override
  String get escanearDuplicados => 'SCANSIONA DUPLICATI';

  @override
  String get localizarArquivos => 'TROVA FILE';

  @override
  String get interromperBusca => 'INTERROMPI RICERCA';

  @override
  String get auditarSha256 => 'Verifica integrità trasferimento (Hash SHA-256)';

  @override
  String get organizarAposTransferir =>
      'Organizza automaticamente per categorie a destinazione';

  @override
  String get sobrescreverExistentes =>
      'Sovrascrivi file se già esistenti a destinazione';

  @override
  String get criarSubpastaExtracao =>
      'Crea cartella con il nome dell\'archivio per ogni estrazione';

  @override
  String get duplicadosSha256 => 'Duplicati (SHA-256)';

  @override
  String get incluirSubpastas => 'Includi sottocartelle (Ricorsivo)';

  @override
  String get atualizacaoDisponivel => 'Aggiornamento Disponibile';

  @override
  String get taskIdle => 'Pronto per iniziare l\'operazione';

  @override
  String get taskRunning => 'Operazione in corso...';

  @override
  String get taskCompleted => 'Operazione completata con successo!';

  @override
  String get taskFailed => 'Operazione non riuscita.';

  @override
  String get aguardandoAcao => 'In attesa dell\'azione dell\'utente...';

  @override
  String get terminalPronto => 'Terminale pronto. Modulo operativo pronto.';

  @override
  String get nenhumArquivoDescompactar =>
      'Nessun file aggiunto alla coda.\nFai clic su \'(+) Aggiungi File\' (.zip, .rar, .7z)';

  @override
  String get nenhumItemCopiar =>
      'Nessun elemento aggiunto per la copia.\nUsa \'(+) File\', \'(+) Cartella\' o \'(+) Google Drive\'.';

  @override
  String get nenhumItemMover =>
      'Nessun elemento aggiunto per lo spostamento.\nUsa \'(+) File\', \'(+) Cartella\' o \'(+) Google Drive\'.';

  @override
  String get regraColisaoDuplicados => 'REGOLA DI COLLISIONE / DUPLICATI:';

  @override
  String get substituirExistentes => 'Sostituisci esistenti (Sovrascrivi)';

  @override
  String get pularDuplicados => 'Salta duplicati (Ignora se esistente)';

  @override
  String get manterAmbos => 'Mantieni entrambi (Crea copia rinominata)';

  @override
  String get categoriasEregras => 'CATEGORIE E REGOLE DI ORGANIZZAZIONE';

  @override
  String get documentosPdf => 'Documenti PDF';

  @override
  String get wordDoc => 'Documenti Word';

  @override
  String get planilhas => 'Fogli di Calcolo';

  @override
  String get musicas => 'Musica';

  @override
  String get videos => 'Video';

  @override
  String get imagens => 'Immagini';

  @override
  String get arquivosCompactados => 'File Compressi';

  @override
  String get instaladores => 'Installer';

  @override
  String get regraPersonalizada => 'Regola Personalizzata:';

  @override
  String get hintNomePasta => 'Nome Cartella Es: Texture DDS';

  @override
  String get adicionarPastaBusca => '+ Aggiungi Cartella';

  @override
  String get todasMidias => 'Tutti i Media';

  @override
  String get qualquerTamanho => 'Qualsiasi Dimensione';

  @override
  String get hintBuscarNomeExtensao =>
      'Cerca per nome o estensione (es: .log)...';

  @override
  String get nenhumConflitoDetectado =>
      'Nessun file duplicato o conflitto rilevato.';

  @override
  String get orientacaoEscaneanarDuplicados =>
      'Aggiungi una o più cartelle e fai clic su \'SCANSIONA DUPLICATI\'.';

  @override
  String get nenhumArquivoLocalizado => 'Nessun file trovato.';

  @override
  String get orientacaoLocalizarArquivos =>
      'Aggiungi una o più cartelle e fai clic su \'TROVA FILE\'.';

  @override
  String get versao => 'Versione 1.0.0 (Build 2026)';

  @override
  String get desenvolvidoPor => 'Sviluppato da Gradle Studio';

  @override
  String get arquiteturaEngenharia => 'ARCHITETTURA & INGEGNERIA DEL SOFTWARE';

  @override
  String get producaoDesign => 'PRODUZIONE & DESIGN';

  @override
  String get tecnologiasNativas => 'TECNOLOGIE NATIVE';

  @override
  String get avisoLegalEula => 'AVVISO LEGALE & EULA';

  @override
  String get textoAvisoLegal =>
      'Questo software viene fornito \"COSÌ COM\'È\" (\"AS IS\"), senza garanzie esplicite o implicite. L\'utente è l\'unico responsabile della convalida e della conferma di eliminazioni e modifiche nei propri dischi e partizioni.';

  @override
  String get direitosReservados =>
      'Tutti i diritti riservati © 2026 Gradle Studio.';

  @override
  String get verificarAtualizacoes => 'Verifica Aggiornamenti';

  @override
  String get ativacaoLicenca => 'Attivazione Licenza';

  @override
  String get manualAjuda => 'Manuale / Aiuto';

  @override
  String get fechar => 'Chiudi';

  @override
  String get manualTitulo => 'PS DesKom — Manuale & Guida Rapida';

  @override
  String get manualSubtitulo =>
      'Istruzioni operative e buone pratiche di gestione dei file.';

  @override
  String get abaModulos => '1. Moduli di Sistema';

  @override
  String get abaDuplicados => '2. Duplicati & Media';

  @override
  String get abaNuvem => '3. Suggerimenti & Cloud';

  @override
  String get abaSuporte => '4. Supporto & Licenza';

  @override
  String get fecharManual => 'Chiudi Manuale';

  @override
  String get mod1Titulo => 'Modulo 1: DECOMPRIMI';

  @override
  String get mod1Desc =>
      'Estrae archivi compressi (.zip, .rar, .7z, .tar) in batch tramite PowerShell nativo. Attiva l\'opzione \"Crea cartella con il nome dell\'archivio\" per mantenere ordinata la destinazione.';

  @override
  String get mod2Titulo => 'Modulo 2: COPIA';

  @override
  String get mod2Desc =>
      'Copia file o intere cartelle nella destinazione configurata con regole di collisione personalizzabili: Sovrascrivi, Salta duplicati o Mantieni entrambi (rinomina).';

  @override
  String get mod3Titulo => 'Modulo 3: SPOSTA';

  @override
  String get mod3Desc =>
      'Trasferisce elementi nello stesso disco o tra volumi. Supporta l\'opzione di sovrascrivere file esistenti e gestisce gli errori di autorizzazione di Windows.';

  @override
  String get mod4Titulo => 'Modulo 4: ORGANIZZA';

  @override
  String get mod4Desc =>
      'Classifica automaticamente i file sciolti in sottocartelle tematiche (Documenti PDF, Musica, Immagini, Video, Installer, ecc.). Consente di creare regole personalizzate in base all\'estensione.';

  @override
  String get mod5Titulo => 'Modulo 5: CERCA';

  @override
  String get mod5Desc =>
      'Esegue la scansione delle directory alla ricerca di file duplicati tramite hash binario SHA-256 e nomi file identici. Offre un pannello di confronto affiancato.';

  @override
  String get sha256Titulo => 'Analisi Crittografica SHA-256';

  @override
  String get sha256Desc =>
      'La scansione esegue una cernita preliminare per dimensione del file e calcola l\'hash SHA-256 dei contenuti per garantire la certezza al 100% nell\'identificazione dei duplicati identici.';

  @override
  String get audioTitulo => 'Riproduttore Audio Integrato';

  @override
  String get audioDesc =>
      'I file audio (.mp3, .wav, .flac, .aac, .m4a) dispongono di un\'anteprima dedicata nelle schede di confronto con barra di avanzamento, riproduzione/pausa e muto istantaneo.';

  @override
  String get videoTitulo => 'Riproduzione Video e File';

  @override
  String get videoDesc =>
      'I file video e gli eseguibili presentano un pulsante rapido \"Apri nel Riproduttore Predefinito\", consentendo l\'apertura nel lettore nativo di Windows a 0ms.';

  @override
  String get buscaSeguraTitulo => 'Interruzione Sicura della Ricerca';

  @override
  String get buscaSeguraDesc =>
      'In qualsiasi momento durante una scansione lunga, fai clic su \"INTERROMPI RICERCA\". Il processo in background verrà terminato in sicurezza tramite taskkill senza bloccare l\'app.';

  @override
  String get driveTitulo => 'Integrazione con Google Drive Desktop';

  @override
  String get driveDesc =>
      'Se l\'applicazione Google Drive Desktop è installata su Windows, PS DesKom rileverà automaticamente l\'unità e mostrerà il pulsante \"Google Drive\" nei selettori di destinazione.';

  @override
  String get pipelinesTitulo =>
      'Pipeline Combinate (Trasferimento + Organizzazione)';

  @override
  String get pipelinesDesc =>
      'Nei moduli Copia e Sposta, seleziona \"Organizza automaticamente per categorie a destinazione\". I file verranno trasferiti e immediatamente ordinati nelle sottocartelle appropriate.';

  @override
  String get otimizacaoTitulo => 'Ottimizzazione per Dischi e Reti';

  @override
  String get otimizacaoDesc =>
      'Il motore opera direttamente tramite Windows PowerShell Core codificado in UTF-16LE EncodedCommand, garantendo elevate prestazioni anche con grandi volumi su NAS o dischi rigidi esterni.';

  @override
  String get licencaHwidTitulo => 'Licenza Offline tramite HWID';

  @override
  String get licencaHwidDesc =>
      'PS DesKom si attiva utilizzando l\'identificatore hardware univoco del computer (HWID). Una volta attivata, la licenza è permanente e non richiede una connessione Internet costante.';

  @override
  String get atualizacoesTitulo => 'Aggiornamenti a Vita Inclusi';

  @override
  String get atualizacoesDesc =>
      'Tutte le nuove versioni e i miglioramenti rilasciati da Gradle Studio nel repository ufficiale sono inclusi gratuitamente per i clienti con licenza.';

  @override
  String get canaisSuporteTitulo => 'Canali Ufficiali di Supporto';

  @override
  String get ativacaoTitulo => 'Attivazione di PS DesKom';

  @override
  String get identificadorComputador => 'IDENTIFICATORE DEL COMPUTER (HWID):';

  @override
  String get copiarHwid => 'Copia';

  @override
  String get solicitarChaveWhats => 'Richiedi Chiave tramite WhatsApp';

  @override
  String get chaveLicencaRotulo => 'CHIAVE DI LICENZA (LICENSE KEY):';

  @override
  String get hintChaveLicenca =>
      'Inserisci la tua chiave (es: KEY-XXXX-YYYY-ZZZZ)';

  @override
  String get validarAtivarLicenca => 'Convalida e Attiva Licenza';

  @override
  String get bemVindoTitulo => 'Benvenuto in PS DesKom';

  @override
  String get bemVindoSubtitulo =>
      'Seleziona la tua lingua preferita per iniziare:';

  @override
  String get iniciarSistema => 'Avvia PS DesKom';

  @override
  String get edicaoMasterAtiva => 'Edizione Master — Amministratore Attivo';

  @override
  String get abaCompilarInstalador => 'COMPILATORE';

  @override
  String get tituloCompiladorGsse =>
      'Compilatore di Installatori GSSE (Gradle Studio Setup Engine)';

  @override
  String get labelNomeSoftware => 'Nome dell\'Applicazione:';

  @override
  String get labelVersaoSoftware => 'Versione dell\'Applicazione:';

  @override
  String get labelDesenvolvedorSoftware => 'Sviluppatore / Editore:';

  @override
  String get labelPastaOrigem => 'Directory di Origine dei File:';

  @override
  String get btnSelecionarOrigem => 'Seleziona Origine';

  @override
  String get hintOrigemVazia => 'Nessuna directory di origine selezionata...';

  @override
  String get labelExecutavelPrincipal =>
      'Eseguibile Principale dell\'Applicazione (.exe):';

  @override
  String get hintSelecioneExecutavel =>
      'Seleziona eseguibile principale (.exe)';

  @override
  String get labelPastaSaida =>
      'Directory di Uscita dell\'Installatore Generato:';

  @override
  String get btnSelecionarSaida => 'Seleziona Uscita';

  @override
  String get optAtalhoDesktop => 'Crea collegamento sul Desktop';

  @override
  String get optAtalhoMenuIniciar => 'Crea collegamento nel Menu Start';

  @override
  String get optExecutarAposInstalar =>
      'Esegui l\'applicazione immediatamente dopo l\'installazione';

  @override
  String get btnCompilarAgora => 'COMPILA INSTALLATORE GSSE';

  @override
  String get msgCompilandoInstalador =>
      'Compilazione e impacchettamento dell\'installatore autonomo GSSE...';

  @override
  String get msgInstaladorSucesso => 'Installatore GSSE generato con successo!';

  @override
  String get btnAbrirPasta => 'Apri Cartella di Uscita';

  @override
  String get hintNomeSoftware => 'Es: Il Mio Software...';

  @override
  String get hintVersaoSoftware => 'Es: 1.0.0';

  @override
  String get hintDesenvolvedorSoftware => 'Es: Gradle Studio...';

  @override
  String get selecionarTodasEdicoes => 'Seleziona Tutte';

  @override
  String get btnCompilarSelecionados => 'COMPILA';

  @override
  String get iaLocal => 'IA LOCALE';

  @override
  String get tituloIaLocal => 'Console di Automazione e IA Locale (LM Studio)';

  @override
  String get statusConectadoIa => 'Connesso a LM Studio (127.0.0.1:1234)';

  @override
  String get statusDesconectadoIa =>
      'Disconnesso (Assicurati che LM Studio sia attivo)';

  @override
  String get btnTestarConexao => 'Testa Connessione';

  @override
  String get btnEnviarPrompt => 'INVIA PROMPT';

  @override
  String get hintDigitarPromptIa =>
      'Inserisci le istruzioni per consentire all\'IA di generare l\'automazione PowerShell...';

  @override
  String get modelosPredefinidos => 'Modelli di Automazione Rapida:';

  @override
  String get subtituloIaLocal =>
      'Motore locale Qwen2.5-Coder per la generazione autonoma di script PowerShell';

  @override
  String get presetIaMaiorArquivo => 'Elenca i 10 file più grandi sul disco C:';

  @override
  String get presetIaLimparTemp =>
      'Pulisci i file temporanei e la cache di sistema (%TEMP%)';

  @override
  String get presetIaAuditarRede =>
      'Verifica cartelle condivise e autorizzazioni di rete';

  @override
  String get presetIaBackupZip =>
      'Crea routine di backup compresso (.zip) con data nel nome';

  @override
  String get labelCodigoGeradoIa => 'Codice PowerShell Generato:';

  @override
  String get hintRespostaIa => 'La risposta del modello apparirà qui...';

  @override
  String get btnInterromperIa => 'INTERROMPI';

  @override
  String get tooltipCopiarCodigo => 'Copia Codice';

  @override
  String get tooltipExecutarPs => 'Esegui in PowerShell Nativo';

  @override
  String get msgCodigoCopiado => 'Codice copiato negli Appunti!';

  @override
  String statusLicencaLog(String status, String hwid) {
    return 'Stato della Licenza: $status (HWID: $hwid)';
  }

  @override
  String googleDriveDetectadoConsole(String path) {
    return 'Google Drive Desktop rilevato nel percorso: $path';
  }

  @override
  String get googleDriveNaoEncontradoConsole =>
      'Google Drive Desktop non trovato sui volumi di sistema.';

  @override
  String get aguardandoAcaoUsuario => 'In attesa dell\'azione dell\'utente...';

  @override
  String get limpandoConsole => 'Pulizia della console...';

  @override
  String get console_copy_running =>
      'Esecuzione della copia batch su Windows...';

  @override
  String console_copy_start(int count) {
    return 'Avvio copia batch di $count elemento/i...';
  }

  @override
  String console_copy_dest(String dir) {
    return 'Cartella Destinazione: $dir';
  }

  @override
  String console_copy_collision(String rule) {
    return 'Regola di Collisione: $rule';
  }

  @override
  String console_copy_organize(String value) {
    return 'Organizza a Destinazione: $value';
  }

  @override
  String console_copy_audit(String value) {
    return 'Verifica SHA-256: $value';
  }

  @override
  String get console_copy_success => 'Tutte le copie sono state completate.';

  @override
  String get console_ai_title => 'RICHIESTA AUTOMAZIONE IA LOCALE (LM STUDIO)';

  @override
  String console_ai_model(String model) {
    return 'Modello: $model';
  }

  @override
  String console_ai_prompt(String prompt) {
    return 'Prompt: $prompt';
  }

  @override
  String get console_ai_success =>
      '[SUCCESSO] Codice generato con successo tramite LM Studio.';

  @override
  String get console_ai_timeout =>
      '[ERRORE IA] Timeout di connessione con LM Studio.';

  @override
  String get console_copy_batch_finished =>
      'Lotto di copia completato con successo!';

  @override
  String get compactar => 'COMPRIMERE';

  @override
  String get tituloModuloCompactar =>
      'Modulo 1B: Compressione File Batch (.zip)';

  @override
  String get labelNomeArquivoZip => 'Nome del File Compresso (.zip):';

  @override
  String get btnCompactarAgora => 'COMPRIMI FILE IN BATCH';

  @override
  String get modalConectarIa => 'Connetti IA';

  @override
  String get provedorIa => 'Provider IA:';

  @override
  String get chaveApiKey => 'Chiave API:';

  @override
  String get btnValidarChave => 'Convalida e Salva Chiave';

  @override
  String get entrarComGoogle => 'Accedi con Google';

  @override
  String get desconectarConta => 'Disconnetti Account';
}
