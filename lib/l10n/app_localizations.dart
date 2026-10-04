import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'PS DesKom'**
  String get appTitle;

  /// No description provided for @descompactar.
  ///
  /// In pt, this message translates to:
  /// **'DESCOMPACTAR'**
  String get descompactar;

  /// No description provided for @copiar.
  ///
  /// In pt, this message translates to:
  /// **'COPIAR'**
  String get copiar;

  /// No description provided for @mover.
  ///
  /// In pt, this message translates to:
  /// **'MOVER'**
  String get mover;

  /// No description provided for @organizar.
  ///
  /// In pt, this message translates to:
  /// **'ORGANIZAR'**
  String get organizar;

  /// No description provided for @procurar.
  ///
  /// In pt, this message translates to:
  /// **'PROCURAR'**
  String get procurar;

  /// No description provided for @origem.
  ///
  /// In pt, this message translates to:
  /// **'ORIGEM'**
  String get origem;

  /// No description provided for @destino.
  ///
  /// In pt, this message translates to:
  /// **'DESTINO'**
  String get destino;

  /// No description provided for @adicionarArquivos.
  ///
  /// In pt, this message translates to:
  /// **'(+) Adicionar Arquivos'**
  String get adicionarArquivos;

  /// No description provided for @adicionarPasta.
  ///
  /// In pt, this message translates to:
  /// **'(+) Pasta'**
  String get adicionarPasta;

  /// No description provided for @googleDrive.
  ///
  /// In pt, this message translates to:
  /// **'Google Drive'**
  String get googleDrive;

  /// No description provided for @adicionarGoogleDrive.
  ///
  /// In pt, this message translates to:
  /// **'(+) Google Drive'**
  String get adicionarGoogleDrive;

  /// No description provided for @selecionarPasta.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Pasta'**
  String get selecionarPasta;

  /// No description provided for @buscarPasta.
  ///
  /// In pt, this message translates to:
  /// **'Buscar Pasta'**
  String get buscarPasta;

  /// No description provided for @limparConsole.
  ///
  /// In pt, this message translates to:
  /// **'Limpar Console'**
  String get limparConsole;

  /// No description provided for @sobre.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get sobre;

  /// No description provided for @limparDestino.
  ///
  /// In pt, this message translates to:
  /// **'Limpar destino'**
  String get limparDestino;

  /// No description provided for @caminhoDestino.
  ///
  /// In pt, this message translates to:
  /// **'Caminho de Destino:'**
  String get caminhoDestino;

  /// No description provided for @diretorioRaiz.
  ///
  /// In pt, this message translates to:
  /// **'DIRETÓRIO RAIZ A ORGANIZAR:'**
  String get diretorioRaiz;

  /// No description provided for @nenhumDiretorioSelecionado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum diretório selecionado.'**
  String get nenhumDiretorioSelecionado;

  /// No description provided for @descompactarAgora.
  ///
  /// In pt, this message translates to:
  /// **'DESCOMPACTAR AGORA'**
  String get descompactarAgora;

  /// No description provided for @iniciarCopia.
  ///
  /// In pt, this message translates to:
  /// **'INICIAR CÓPIA'**
  String get iniciarCopia;

  /// No description provided for @moverArquivos.
  ///
  /// In pt, this message translates to:
  /// **'MOVER ARQUIVOS'**
  String get moverArquivos;

  /// No description provided for @organizarPasta.
  ///
  /// In pt, this message translates to:
  /// **'ORGANIZAR PASTA'**
  String get organizarPasta;

  /// No description provided for @escanearDuplicados.
  ///
  /// In pt, this message translates to:
  /// **'ESCANEAR DUPLICADOS'**
  String get escanearDuplicados;

  /// No description provided for @localizarArquivos.
  ///
  /// In pt, this message translates to:
  /// **'LOCALIZAR ARQUIVOS'**
  String get localizarArquivos;

  /// No description provided for @interromperBusca.
  ///
  /// In pt, this message translates to:
  /// **'INTERROMPER BUSCA'**
  String get interromperBusca;

  /// No description provided for @auditarSha256.
  ///
  /// In pt, this message translates to:
  /// **'Auditar integridade de transferência (Hash SHA-256)'**
  String get auditarSha256;

  /// No description provided for @organizarAposTransferir.
  ///
  /// In pt, this message translates to:
  /// **'Organizar automaticamente por categorias no destino'**
  String get organizarAposTransferir;

  /// No description provided for @sobrescreverExistentes.
  ///
  /// In pt, this message translates to:
  /// **'Sobrescrever arquivos se já existirem no destino'**
  String get sobrescreverExistentes;

  /// No description provided for @criarSubpastaExtracao.
  ///
  /// In pt, this message translates to:
  /// **'Criar pasta com o nome do arquivo para cada extração'**
  String get criarSubpastaExtracao;

  /// No description provided for @duplicadosSha256.
  ///
  /// In pt, this message translates to:
  /// **'Duplicados (SHA-256)'**
  String get duplicadosSha256;

  /// No description provided for @incluirSubpastas.
  ///
  /// In pt, this message translates to:
  /// **'Incluir subpastas (Recursivo)'**
  String get incluirSubpastas;

  /// No description provided for @atualizacaoDisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Atualização Disponível'**
  String get atualizacaoDisponivel;

  /// No description provided for @aguardandoAcao.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando ação do usuário...'**
  String get aguardandoAcao;

  /// No description provided for @terminalPronto.
  ///
  /// In pt, this message translates to:
  /// **'Terminal pronto. Módulo operacional pronto.'**
  String get terminalPronto;

  /// No description provided for @nenhumArquivoDescompactar.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum arquivo adicionado à fila.\nClique em \'(+) Adicionar Arquivos\' (.zip, .rar, .7z)'**
  String get nenhumArquivoDescompactar;

  /// No description provided for @nenhumItemCopiar.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item adicionado para cópia.\nUtilize \'(+) Arquivos\', \'(+) Pasta\' ou \'(+) Google Drive\'.'**
  String get nenhumItemCopiar;

  /// No description provided for @nenhumItemMover.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item adicionado para movimentação.\nUtilize \'(+) Arquivos\', \'(+) Pasta\' ou \'(+) Google Drive\'.'**
  String get nenhumItemMover;

  /// No description provided for @regraColisaoDuplicados.
  ///
  /// In pt, this message translates to:
  /// **'REGRA DE COLISÃO / DUPLICADOS:'**
  String get regraColisaoDuplicados;

  /// No description provided for @substituirExistentes.
  ///
  /// In pt, this message translates to:
  /// **'Substituir existentes (Sobrescrever)'**
  String get substituirExistentes;

  /// No description provided for @pularDuplicados.
  ///
  /// In pt, this message translates to:
  /// **'Pular duplicados (Ignorar se existir)'**
  String get pularDuplicados;

  /// No description provided for @manterAmbos.
  ///
  /// In pt, this message translates to:
  /// **'Manter ambos (Criar cópia renomeada)'**
  String get manterAmbos;

  /// No description provided for @categoriasEregras.
  ///
  /// In pt, this message translates to:
  /// **'CATEGORIAS E REGRAS DE ORGANIZAÇÃO'**
  String get categoriasEregras;

  /// No description provided for @documentosPdf.
  ///
  /// In pt, this message translates to:
  /// **'Documentos PDF'**
  String get documentosPdf;

  /// No description provided for @wordDoc.
  ///
  /// In pt, this message translates to:
  /// **'Word Doc'**
  String get wordDoc;

  /// No description provided for @planilhas.
  ///
  /// In pt, this message translates to:
  /// **'Planilhas'**
  String get planilhas;

  /// No description provided for @musicas.
  ///
  /// In pt, this message translates to:
  /// **'Músicas'**
  String get musicas;

  /// No description provided for @videos.
  ///
  /// In pt, this message translates to:
  /// **'Vídeos'**
  String get videos;

  /// No description provided for @imagens.
  ///
  /// In pt, this message translates to:
  /// **'Imagens'**
  String get imagens;

  /// No description provided for @arquivosCompactados.
  ///
  /// In pt, this message translates to:
  /// **'Arquivos Compactados'**
  String get arquivosCompactados;

  /// No description provided for @instaladores.
  ///
  /// In pt, this message translates to:
  /// **'Instaladores'**
  String get instaladores;

  /// No description provided for @regraPersonalizada.
  ///
  /// In pt, this message translates to:
  /// **'Regra Personalizada:'**
  String get regraPersonalizada;

  /// No description provided for @hintNomePasta.
  ///
  /// In pt, this message translates to:
  /// **'Nome da Pasta Ex: Texturas DDS'**
  String get hintNomePasta;

  /// No description provided for @adicionarPastaBusca.
  ///
  /// In pt, this message translates to:
  /// **'+ Adicionar Pasta'**
  String get adicionarPastaBusca;

  /// No description provided for @todasMidias.
  ///
  /// In pt, this message translates to:
  /// **'Todas Mídias'**
  String get todasMidias;

  /// No description provided for @qualquerTamanho.
  ///
  /// In pt, this message translates to:
  /// **'Qualquer Tamanho'**
  String get qualquerTamanho;

  /// No description provided for @hintBuscarNomeExtensao.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por nome ou extensão (ex: .log)...'**
  String get hintBuscarNomeExtensao;

  /// No description provided for @nenhumConflitoDetectado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum conflito ou arquivo duplicado detectado.'**
  String get nenhumConflitoDetectado;

  /// No description provided for @orientacaoEscaneanarDuplicados.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma ou mais pastas e clique em \'ESCANEAR DUPLICADOS\'.'**
  String get orientacaoEscaneanarDuplicados;

  /// No description provided for @nenhumArquivoLocalizado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum arquivo localizado.'**
  String get nenhumArquivoLocalizado;

  /// No description provided for @orientacaoLocalizarArquivos.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma ou mais pastas e clique em \'LOCALIZAR ARQUIVOS\'.'**
  String get orientacaoLocalizarArquivos;

  /// No description provided for @versao.
  ///
  /// In pt, this message translates to:
  /// **'Versão 1.0.0 (Build 2026)'**
  String get versao;

  /// No description provided for @desenvolvidoPor.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvido por Gradle Studio'**
  String get desenvolvidoPor;

  /// No description provided for @arquiteturaEngenharia.
  ///
  /// In pt, this message translates to:
  /// **'ARQUITETURA & ENGENHARIA DE SOFTWARE'**
  String get arquiteturaEngenharia;

  /// No description provided for @producaoDesign.
  ///
  /// In pt, this message translates to:
  /// **'PRODUÇÃO & DESIGN'**
  String get producaoDesign;

  /// No description provided for @tecnologiasNativas.
  ///
  /// In pt, this message translates to:
  /// **'TECNOLOGIAS NATIVAS'**
  String get tecnologiasNativas;

  /// No description provided for @avisoLegalEula.
  ///
  /// In pt, this message translates to:
  /// **'AVISO LEGAL & EULA'**
  String get avisoLegalEula;

  /// No description provided for @textoAvisoLegal.
  ///
  /// In pt, this message translates to:
  /// **'Este software é disponibilizado no estado em que se encontra (\"AS IS\"), sem garantias expressas ou implícitas. O usuário é inteiramente responsável por validar e confirmar exclusões e modificações em seus discos e partições.'**
  String get textoAvisoLegal;

  /// No description provided for @direitosReservados.
  ///
  /// In pt, this message translates to:
  /// **'Todos os direitos reservados © 2026 Gradle Studio.'**
  String get direitosReservados;

  /// No description provided for @verificarAtualizacoes.
  ///
  /// In pt, this message translates to:
  /// **'Verificar Atualizações'**
  String get verificarAtualizacoes;

  /// No description provided for @ativacaoLicenca.
  ///
  /// In pt, this message translates to:
  /// **'Ativação de Licença'**
  String get ativacaoLicenca;

  /// No description provided for @manualAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Manual / Ajuda'**
  String get manualAjuda;

  /// No description provided for @fechar.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get fechar;

  /// No description provided for @manualTitulo.
  ///
  /// In pt, this message translates to:
  /// **'PS DesKom — Manual & Guia Rápido'**
  String get manualTitulo;

  /// No description provided for @manualSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Instruções operacionais e boas práticas de gerenciamento de arquivos.'**
  String get manualSubtitulo;

  /// No description provided for @abaModulos.
  ///
  /// In pt, this message translates to:
  /// **'1. Módulos do Sistema'**
  String get abaModulos;

  /// No description provided for @abaDuplicados.
  ///
  /// In pt, this message translates to:
  /// **'2. Duplicados & Mídia'**
  String get abaDuplicados;

  /// No description provided for @abaNuvem.
  ///
  /// In pt, this message translates to:
  /// **'3. Dicas & Nuvem'**
  String get abaNuvem;

  /// No description provided for @abaSuporte.
  ///
  /// In pt, this message translates to:
  /// **'4. Suporte & Licença'**
  String get abaSuporte;

  /// No description provided for @fecharManual.
  ///
  /// In pt, this message translates to:
  /// **'Fechar Manual'**
  String get fecharManual;

  /// No description provided for @mod1Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Módulo 1: DESCOMPACTAR'**
  String get mod1Titulo;

  /// No description provided for @mod1Desc.
  ///
  /// In pt, this message translates to:
  /// **'Extrai arquivos compactados (.zip, .rar, .7z, .tar) em lote via PowerShell nativo. Ative a opção \"Criar pasta com o nome do arquivo\" para manter o destino limpo.'**
  String get mod1Desc;

  /// No description provided for @mod2Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Módulo 2: COPIAR'**
  String get mod2Titulo;

  /// No description provided for @mod2Desc.
  ///
  /// In pt, this message translates to:
  /// **'Copia arquivos ou pastas completas para o destino configurado com regras de colisão personalizáveis: Substituir, Pular duplicados ou Manter Ambos (renomear).'**
  String get mod2Desc;

  /// No description provided for @mod3Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Módulo 3: MOVER'**
  String get mod3Titulo;

  /// No description provided for @mod3Desc.
  ///
  /// In pt, this message translates to:
  /// **'Transfere itens no mesmo disco ou entre volumes. Suporta opção de sobrescrever arquivos existentes e tratamento de erros de permissão no Windows.'**
  String get mod3Desc;

  /// No description provided for @mod4Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Módulo 4: ORGANIZAR'**
  String get mod4Titulo;

  /// No description provided for @mod4Desc.
  ///
  /// In pt, this message translates to:
  /// **'Classifica automaticamente arquivos soltos em subpastas temáticas (Documentos PDF, Músicas, Imagens, Vídeos, Instaladores, etc.). Permite criar regras customizadas por extensão.'**
  String get mod4Desc;

  /// No description provided for @mod5Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Módulo 5: PROCURAR'**
  String get mod5Titulo;

  /// No description provided for @mod5Desc.
  ///
  /// In pt, this message translates to:
  /// **'Varre diretórios em busca de arquivos duplicados via hash binário SHA-256 e arquivos com mesmo nome. Oferece painel de comparação lado a lado.'**
  String get mod5Desc;

  /// No description provided for @sha256Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Análise Criptográfica SHA-256'**
  String get sha256Titulo;

  /// No description provided for @sha256Desc.
  ///
  /// In pt, this message translates to:
  /// **'A varredura realiza uma triagem prévia por tamanho de arquivo e em seguida calcula o hash SHA-256 dos conteúdos para garantir 100% de certeza ao identificar duplicados idênticos.'**
  String get sha256Desc;

  /// No description provided for @audioTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Reprodutor de Áudio Integrado'**
  String get audioTitulo;

  /// No description provided for @audioDesc.
  ///
  /// In pt, this message translates to:
  /// **'Arquivos de áudio (.mp3, .wav, .flac, .aac, .m4a) possuem pré-visualizador próprio nos cards de comparação com slider de progresso, botão play/pause e mute instantâneo.'**
  String get audioDesc;

  /// No description provided for @videoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Execução de Vídeos e Arquivos'**
  String get videoTitulo;

  /// No description provided for @videoDesc.
  ///
  /// In pt, this message translates to:
  /// **'Mídias de vídeo e executáveis contêm botão de ação rápida \"Abrir no Player Padrão\", permitindo visualizar a mídia no reprodutor nativo do Windows em 0ms.'**
  String get videoDesc;

  /// No description provided for @buscaSeguraTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Interrupción Segura de Búsqueda'**
  String get buscaSeguraTitulo;

  /// No description provided for @buscaSeguraDesc.
  ///
  /// In pt, this message translates to:
  /// **'A qualquer momento durante uma varredura longa, clique em \"INTERROMPER BUSCA\". O processo em segundo plano será encerrado com segurança via taskkill sem travar o app.'**
  String get buscaSeguraDesc;

  /// No description provided for @driveTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Integração com Google Drive Desktop'**
  String get driveTitulo;

  /// No description provided for @driveDesc.
  ///
  /// In pt, this message translates to:
  /// **'Se o aplicativo Google Drive Desktop estiver instalado no Windows, o PS DesKom detectará a unidade automaticamente e exibirá o botão \"Google Drive\" nos seletores de destino.'**
  String get driveDesc;

  /// No description provided for @pipelinesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Pipelines Combinados (Transferir + Organizar)'**
  String get pipelinesTitulo;

  /// No description provided for @pipelinesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Nos módulos Copiar e Mover, marque a caixa \"Organizar automaticamente por categorias no destino\". Os arquivos serão transferidos e imediatamente classificados nas subpastas adequadas.'**
  String get pipelinesDesc;

  /// No description provided for @otimizacaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Otimização para Discos e Redes'**
  String get otimizacaoTitulo;

  /// No description provided for @otimizacaoDesc.
  ///
  /// In pt, this message translates to:
  /// **'A engine opera diretamente sobre o Windows PowerShell Core codificado em UTF-16LE EncodedCommand, garantindo alta performance mesmo ao manipular grandes volumes em NAS ou HDs externos.'**
  String get otimizacaoDesc;

  /// No description provided for @licencaHwidTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Licença Offline por HWID'**
  String get licencaHwidTitulo;

  /// No description provided for @licencaHwidDesc.
  ///
  /// In pt, this message translates to:
  /// **'O PS DesKom é ativado utilizando o identificador único do seu computador (HWID). Uma vez ativada, a licença é permanente e não requer conexão constante com a internet.'**
  String get licencaHwidDesc;

  /// No description provided for @atualizacoesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Atualizações Vitalícias Incluidas'**
  String get atualizacoesTitulo;

  /// No description provided for @atualizacoesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Todas as novas versões e melhorias disponibilizadas pela Gradle Studio no repositório oficial estão inclusas gratuitamente para os clientes licenciados.'**
  String get atualizacoesDesc;

  /// No description provided for @canaisSuporteTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Canais Oficiais de Suporte'**
  String get canaisSuporteTitulo;

  /// No description provided for @ativacaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Ativação do PS DesKom'**
  String get ativacaoTitulo;

  /// No description provided for @identificadorComputador.
  ///
  /// In pt, this message translates to:
  /// **'IDENTIFICADOR DO COMPUTADOR (HWID):'**
  String get identificadorComputador;

  /// No description provided for @copiarHwid.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get copiarHwid;

  /// No description provided for @solicitarChaveWhats.
  ///
  /// In pt, this message translates to:
  /// **'Solicitar Chave via WhatsApp'**
  String get solicitarChaveWhats;

  /// No description provided for @chaveLicencaRotulo.
  ///
  /// In pt, this message translates to:
  /// **'CHAVE DE LICENÇA (LICENSE KEY):'**
  String get chaveLicencaRotulo;

  /// No description provided for @hintChaveLicenca.
  ///
  /// In pt, this message translates to:
  /// **'Insira sua chave (ex: KEY-XXXX-YYYY-ZZZZ)'**
  String get hintChaveLicenca;

  /// No description provided for @validarAtivarLicenca.
  ///
  /// In pt, this message translates to:
  /// **'Validar e Ativar Licença'**
  String get validarAtivarLicenca;

  /// No description provided for @bemVindoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao PS DesKom'**
  String get bemVindoTitulo;

  /// No description provided for @bemVindoSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o seu idioma de preferência para começar:'**
  String get bemVindoSubtitulo;

  /// No description provided for @iniciarSistema.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar PS DesKom'**
  String get iniciarSistema;

  /// No description provided for @edicaoMasterAtiva.
  ///
  /// In pt, this message translates to:
  /// **'Edição Master — Administrador Ativo'**
  String get edicaoMasterAtiva;

  /// No description provided for @abaCompilarInstalador.
  ///
  /// In pt, this message translates to:
  /// **'COMPILAR INSTALADOR'**
  String get abaCompilarInstalador;

  /// No description provided for @tituloCompiladorGsse.
  ///
  /// In pt, this message translates to:
  /// **'Compilador de Instaladores GSSE (Gradle Studio Setup Engine)'**
  String get tituloCompiladorGsse;

  /// No description provided for @labelNomeSoftware.
  ///
  /// In pt, this message translates to:
  /// **'Nome da Aplicação:'**
  String get labelNomeSoftware;

  /// No description provided for @labelVersaoSoftware.
  ///
  /// In pt, this message translates to:
  /// **'Versão da Aplicação:'**
  String get labelVersaoSoftware;

  /// No description provided for @labelDesenvolvedorSoftware.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvedor / Publisher:'**
  String get labelDesenvolvedorSoftware;

  /// No description provided for @labelPastaOrigem.
  ///
  /// In pt, this message translates to:
  /// **'Diretório de Origem dos Arquivos:'**
  String get labelPastaOrigem;

  /// No description provided for @btnSelecionarOrigem.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Origem'**
  String get btnSelecionarOrigem;

  /// No description provided for @hintOrigemVazia.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum diretório de origem selecionado...'**
  String get hintOrigemVazia;

  /// No description provided for @labelExecutavelPrincipal.
  ///
  /// In pt, this message translates to:
  /// **'Executável Principal da Aplicação (.exe):'**
  String get labelExecutavelPrincipal;

  /// No description provided for @hintSelecioneExecutavel.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o executável principal (.exe)'**
  String get hintSelecioneExecutavel;

  /// No description provided for @labelPastaSaida.
  ///
  /// In pt, this message translates to:
  /// **'Diretório de Saída do Instalador Gerado:'**
  String get labelPastaSaida;

  /// No description provided for @btnSelecionarSaida.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Saída'**
  String get btnSelecionarSaida;

  /// No description provided for @optAtalhoDesktop.
  ///
  /// In pt, this message translates to:
  /// **'Criar atalho na Área de Trabalho (Desktop)'**
  String get optAtalhoDesktop;

  /// No description provided for @optAtalhoMenuIniciar.
  ///
  /// In pt, this message translates to:
  /// **'Criar atalho no Menu Iniciar'**
  String get optAtalhoMenuIniciar;

  /// No description provided for @optExecutarAposInstalar.
  ///
  /// In pt, this message translates to:
  /// **'Executar aplicação imediatamente após a instalação'**
  String get optExecutarAposInstalar;

  /// No description provided for @btnCompilarAgora.
  ///
  /// In pt, this message translates to:
  /// **'COMPILAR INSTALADOR GSSE'**
  String get btnCompilarAgora;

  /// No description provided for @msgCompilandoInstalador.
  ///
  /// In pt, this message translates to:
  /// **'Compilando e empacotando instalador autônomo GSSE...'**
  String get msgCompilandoInstalador;

  /// No description provided for @msgInstaladorSucesso.
  ///
  /// In pt, this message translates to:
  /// **'Instalador GSSE gerado com sucesso!'**
  String get msgInstaladorSucesso;

  /// No description provided for @btnAbrirPasta.
  ///
  /// In pt, this message translates to:
  /// **'Abrir Pasta de Saída'**
  String get btnAbrirPasta;

  /// No description provided for @hintNomeSoftware.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Meu Software...'**
  String get hintNomeSoftware;

  /// No description provided for @hintVersaoSoftware.
  ///
  /// In pt, this message translates to:
  /// **'Ex: 1.0.0'**
  String get hintVersaoSoftware;

  /// No description provided for @hintDesenvolvedorSoftware.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Gradle Studio...'**
  String get hintDesenvolvedorSoftware;

  /// No description provided for @selecionarTodasEdicoes.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Todas'**
  String get selecionarTodasEdicoes;

  /// No description provided for @btnCompilarSelecionados.
  ///
  /// In pt, this message translates to:
  /// **'COMPILAR INSTALADORES SELECIONADOS'**
  String get btnCompilarSelecionados;

  /// No description provided for @iaLocal.
  ///
  /// In pt, this message translates to:
  /// **'IA LOCAL'**
  String get iaLocal;

  /// No description provided for @tituloIaLocal.
  ///
  /// In pt, this message translates to:
  /// **'Console de Automação & IA Local (LM Studio)'**
  String get tituloIaLocal;

  /// No description provided for @statusConectadoIa.
  ///
  /// In pt, this message translates to:
  /// **'Conectado ao LM Studio (127.0.0.1:1234)'**
  String get statusConectadoIa;

  /// No description provided for @statusDesconectadoIa.
  ///
  /// In pt, this message translates to:
  /// **'Desconectado (Verifique se o LM Studio está ativo)'**
  String get statusDesconectadoIa;

  /// No description provided for @btnTestarConexao.
  ///
  /// In pt, this message translates to:
  /// **'Testar Conexão'**
  String get btnTestarConexao;

  /// No description provided for @btnEnviarPrompt.
  ///
  /// In pt, this message translates to:
  /// **'ENVIAR PROMPT'**
  String get btnEnviarPrompt;

  /// No description provided for @hintDigitarPromptIa.
  ///
  /// In pt, this message translates to:
  /// **'Digite a instrução para a IA gerar a automação em PowerShell...'**
  String get hintDigitarPromptIa;

  /// No description provided for @modelosPredefinidos.
  ///
  /// In pt, this message translates to:
  /// **'Modelos de Automação Rápida:'**
  String get modelosPredefinidos;

  /// No description provided for @subtituloIaLocal.
  ///
  /// In pt, this message translates to:
  /// **'Motor local Qwen2.5-Coder para geração autônoma de scripts PowerShell'**
  String get subtituloIaLocal;

  /// No description provided for @presetIaMaiorArquivo.
  ///
  /// In pt, this message translates to:
  /// **'Listar os 10 maiores arquivos do disco C:'**
  String get presetIaMaiorArquivo;

  /// No description provided for @presetIaLimparTemp.
  ///
  /// In pt, this message translates to:
  /// **'Limpar arquivos temporários e cache do sistema (%TEMP%)'**
  String get presetIaLimparTemp;

  /// No description provided for @presetIaAuditarRede.
  ///
  /// In pt, this message translates to:
  /// **'Auditar pastas compartilhadas e permissões de rede'**
  String get presetIaAuditarRede;

  /// No description provided for @presetIaBackupZip.
  ///
  /// In pt, this message translates to:
  /// **'Criar rotina de backup compactado (.zip) com data no nome'**
  String get presetIaBackupZip;

  /// No description provided for @labelCodigoGeradoIa.
  ///
  /// In pt, this message translates to:
  /// **'Código PowerShell Gerado:'**
  String get labelCodigoGeradoIa;

  /// No description provided for @hintRespostaIa.
  ///
  /// In pt, this message translates to:
  /// **'A resposta do modelo aparecerá aqui...'**
  String get hintRespostaIa;

  /// No description provided for @btnInterromperIa.
  ///
  /// In pt, this message translates to:
  /// **'INTERROMPER'**
  String get btnInterromperIa;

  /// No description provided for @tooltipCopiarCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Copiar Código'**
  String get tooltipCopiarCodigo;

  /// No description provided for @tooltipExecutarPs.
  ///
  /// In pt, this message translates to:
  /// **'Executar no PowerShell Nativo'**
  String get tooltipExecutarPs;

  /// No description provided for @msgCodigoCopiado.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado para a Área de Transferência!'**
  String get msgCodigoCopiado;

  /// No description provided for @statusLicencaLog.
  ///
  /// In pt, this message translates to:
  /// **'Status da Licença: {status} (HWID: {hwid})'**
  String statusLicencaLog(String status, String hwid);

  /// No description provided for @googleDriveDetectadoConsole.
  ///
  /// In pt, this message translates to:
  /// **'Google Drive Desktop detectado no caminho: {path}'**
  String googleDriveDetectadoConsole(String path);

  /// No description provided for @googleDriveNaoEncontradoConsole.
  ///
  /// In pt, this message translates to:
  /// **'Google Drive Desktop não localizado nos volumes do sistema.'**
  String get googleDriveNaoEncontradoConsole;

  /// No description provided for @aguardandoAcaoUsuario.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando ação do usuário...'**
  String get aguardandoAcaoUsuario;

  /// No description provided for @limpandoConsole.
  ///
  /// In pt, this message translates to:
  /// **'Limpando console...'**
  String get limpandoConsole;

  /// No description provided for @console_copy_running.
  ///
  /// In pt, this message translates to:
  /// **'Executando cópia em lote no Windows...'**
  String get console_copy_running;

  /// No description provided for @console_copy_start.
  ///
  /// In pt, this message translates to:
  /// **'Iniciando cópia em lote de {count} item(ns)...'**
  String console_copy_start(int count);

  /// No description provided for @console_copy_dest.
  ///
  /// In pt, this message translates to:
  /// **'Diretório Destino: {dir}'**
  String console_copy_dest(String dir);

  /// No description provided for @console_copy_collision.
  ///
  /// In pt, this message translates to:
  /// **'Regra de Colisão: {rule}'**
  String console_copy_collision(String rule);

  /// No description provided for @console_copy_organize.
  ///
  /// In pt, this message translates to:
  /// **'Organizar no Destino: {value}'**
  String console_copy_organize(String value);

  /// No description provided for @console_copy_audit.
  ///
  /// In pt, this message translates to:
  /// **'Auditoria SHA-256: {value}'**
  String console_copy_audit(String value);

  /// No description provided for @console_copy_success.
  ///
  /// In pt, this message translates to:
  /// **'Todas as cópias foram finalizadas.'**
  String get console_copy_success;

  /// No description provided for @console_ai_title.
  ///
  /// In pt, this message translates to:
  /// **'SOLICITAÇÃO DE AUTOMAÇÃO IA LOCAL (LM STUDIO)'**
  String get console_ai_title;

  /// No description provided for @console_ai_model.
  ///
  /// In pt, this message translates to:
  /// **'Modelo: {model}'**
  String console_ai_model(String model);

  /// No description provided for @console_ai_prompt.
  ///
  /// In pt, this message translates to:
  /// **'Prompt: {prompt}'**
  String console_ai_prompt(String prompt);

  /// No description provided for @console_ai_success.
  ///
  /// In pt, this message translates to:
  /// **'[SUCESSO] Código gerado com sucesso via LM Studio.'**
  String get console_ai_success;

  /// No description provided for @console_ai_timeout.
  ///
  /// In pt, this message translates to:
  /// **'[ERRO IA] Timeout de conexão com o LM Studio.'**
  String get console_ai_timeout;

  /// No description provided for @console_copy_batch_finished.
  ///
  /// In pt, this message translates to:
  /// **'Lote de cópia finalizado com sucesso!'**
  String get console_copy_batch_finished;

  /// No description provided for @compactar.
  ///
  /// In pt, this message translates to:
  /// **'COMPACTAR'**
  String get compactar;

  /// No description provided for @tituloModuloCompactar.
  ///
  /// In pt, this message translates to:
  /// **'Módulo 1B: Compactação de Arquivos em Lote (.zip)'**
  String get tituloModuloCompactar;

  /// No description provided for @labelNomeArquivoZip.
  ///
  /// In pt, this message translates to:
  /// **'Nome do Arquivo Compactado (.zip):'**
  String get labelNomeArquivoZip;

  /// No description provided for @btnCompactarAgora.
  ///
  /// In pt, this message translates to:
  /// **'COMPACTAR ARQUIVOS EM LOTE'**
  String get btnCompactarAgora;

  /// No description provided for @modalConectarIa.
  ///
  /// In pt, this message translates to:
  /// **'Conectar IA'**
  String get modalConectarIa;

  /// No description provided for @provedorIa.
  ///
  /// In pt, this message translates to:
  /// **'Provedor de IA:'**
  String get provedorIa;

  /// No description provided for @chaveApiKey.
  ///
  /// In pt, this message translates to:
  /// **'Chave API (API Key):'**
  String get chaveApiKey;

  /// No description provided for @btnValidarChave.
  ///
  /// In pt, this message translates to:
  /// **'Validar e Salvar Chave'**
  String get btnValidarChave;

  /// No description provided for @entrarComGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get entrarComGoogle;

  /// No description provided for @desconectarConta.
  ///
  /// In pt, this message translates to:
  /// **'Desconectar Conta'**
  String get desconectarConta;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
