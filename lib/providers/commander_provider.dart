import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/license_service.dart';
import '../services/lmstudio_service.dart';
import '../services/powershell_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';

enum SearchMode { duplicates, fileSearch }

class FoundFileInfo {
  final String name;
  final String path;
  final int sizeBytes;
  final String extension;
  final DateTime lastModified;

  FoundFileInfo({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.extension,
    required this.lastModified,
  });

  factory FoundFileInfo.fromMap(Map<String, dynamic> map) {
    return FoundFileInfo(
      name: map['nome'] as String? ?? map['name'] as String? ?? '',
      path: map['caminho'] as String? ?? map['path'] as String? ?? '',
      sizeBytes: map['tamanho'] as int? ?? map['sizeBytes'] as int? ?? 0,
      extension: map['extensao'] as String? ?? map['extension'] as String? ?? '',
      lastModified: map['modificado'] != null
          ? DateTime.tryParse(map['modificado'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CommanderState {
  final bool isLoading;
  final String prompt;
  final String comandoGerado;
  final String logsTerminal;
  final List<Map<String, String>> historico;

  // Estado dos Módulos
  final int moduloSelecionado; // 0: Descompactar, 1: Copiar, 2: Mover, 3: Organizar, 4: Procurar

  // Módulo 0: Descompactar
  final List<String> arquivosOrigem;
  final String? diretorioDestino;
  final bool criarSubpastaPorArquivo;

  // Módulo 1: Copiar
  final List<String> itensCopiarOrigem;
  final String? destinoCopiar;
  final String regraColisaoCopiar; // 'substituir', 'pular', 'manter'

  // Módulo 2: Mover
  final List<String> itensMoverOrigem;
  final String? destinoMover;
  final bool sobrescreverMover;

  // Módulo 3: Organizar
  final String? diretorioOrganizar;
  final bool incluirSubpastasOrganizar;
  final Map<String, bool> categoriasSelecionadas;
  final String extensaoCustomizada;
  final String pastaCustomizada;

  // Módulo 4: Procurar / Duplicados & Busca Avançada
  final String? diretorioBusca;
  final List<String> searchPaths;
  final bool includeSubfolders;
  final SearchMode searchMode;
  final String categoriaFiltroBusca; // 'todos', 'imagens', 'videos', 'audios', 'textos', 'instaladores'
  final String searchFileNameQuery;
  final String searchSizeFilter; // "Todos", "< 10 MB", "10-100 MB", "100 MB - 1 GB", "> 1 GB"
  final bool isEscaneando;
  final List<Map<String, dynamic>> gruposConflito;
  final int grupoConflitoSelecionado;
  final List<FoundFileInfo> foundFiles;

  // Recursos Globais de Automação
  final bool organizarAposTransferir;
  final String? caminhoGoogleDriveDetectado;

  // Estado de Licença
  final String hwidAtual;
  final bool softwareAtivado;
  final String statusLicencaTexto;

  // Estado de Atualização
  final bool temAtualizacao;
  final Map<String, dynamic>? dadosNovaVersao;
  final bool verificandoAtualizacao;

  // Progresso Geral
  final double progressoExecucao;
  final String statusOperacao;

  static const Map<String, List<String>> categoriasDefinidas = {
    'Documentos PDF': ['.pdf'],
    'Word Doc': ['.doc', '.docx'],
    'Planilhas': ['.xlsx', '.xls', '.csv'],
    'Músicas': ['.mp3', '.wav', '.flac', '.m4a'],
    'Vídeos': ['.mp4', '.mkv', '.avi', '.mov'],
    'Imagens': ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
    'Arquivos Compactados': ['.zip', '.rar', '.7z', '.tar', '.gz'],
    'Instaladores': ['.exe', '.msi'],
  };

  CommanderState({
    this.isLoading = false,
    this.prompt = '',
    this.comandoGerado = '',
    this.logsTerminal = '',
    this.historico = const [],
    this.moduloSelecionado = 0,
    this.arquivosOrigem = const [],
    this.diretorioDestino,
    this.criarSubpastaPorArquivo = true,
    this.itensCopiarOrigem = const [],
    this.destinoCopiar,
    this.regraColisaoCopiar = 'substituir',
    this.itensMoverOrigem = const [],
    this.destinoMover,
    this.sobrescreverMover = true,
    this.diretorioOrganizar,
    this.incluirSubpastasOrganizar = false,
    Map<String, bool>? categoriasSelecionadas,
    this.extensaoCustomizada = '',
    this.pastaCustomizada = '',
    this.diretorioBusca,
    this.searchPaths = const [],
    this.includeSubfolders = true,
    this.searchMode = SearchMode.duplicates,
    this.categoriaFiltroBusca = 'todos',
    this.searchFileNameQuery = '',
    this.searchSizeFilter = 'Todos',
    this.isEscaneando = false,
    this.gruposConflito = const [],
    this.grupoConflitoSelecionado = 0,
    this.foundFiles = const [],
    this.organizarAposTransferir = false,
    this.caminhoGoogleDriveDetectado,
    this.hwidAtual = '',
    this.softwareAtivado = false,
    this.statusLicencaTexto = 'Não Ativado',
    this.temAtualizacao = false,
    this.dadosNovaVersao,
    this.verificandoAtualizacao = false,
    this.progressoExecucao = 0.0,
    this.statusOperacao = '',
  }) : categoriasSelecionadas = categoriasSelecionadas ??
            Map.fromEntries(
                categoriasDefinidas.keys.map((k) => MapEntry(k, true)));

  CommanderState copyWith({
    bool? isLoading,
    String? prompt,
    String? comandoGerado,
    String? logsTerminal,
    List<Map<String, String>>? historico,
    int? moduloSelecionado,
    List<String>? arquivosOrigem,
    String? diretorioDestino,
    bool? criarSubpastaPorArquivo,
    List<String>? itensCopiarOrigem,
    String? destinoCopiar,
    String? regraColisaoCopiar,
    List<String>? itensMoverOrigem,
    String? destinoMover,
    bool? sobrescreverMover,
    String? diretorioOrganizar,
    bool? incluirSubpastasOrganizar,
    Map<String, bool>? categoriasSelecionadas,
    String? extensaoCustomizada,
    String? pastaCustomizada,
    String? diretorioBusca,
    List<String>? searchPaths,
    bool? includeSubfolders,
    SearchMode? searchMode,
    String? categoriaFiltroBusca,
    String? searchFileNameQuery,
    String? searchSizeFilter,
    bool? isEscaneando,
    List<Map<String, dynamic>>? gruposConflito,
    int? grupoConflitoSelecionado,
    List<FoundFileInfo>? foundFiles,
    bool? organizarAposTransferir,
    String? caminhoGoogleDriveDetectado,
    String? hwidAtual,
    bool? softwareAtivado,
    String? statusLicencaTexto,
    bool? temAtualizacao,
    Map<String, dynamic>? dadosNovaVersao,
    bool? verificandoAtualizacao,
    double? progressoExecucao,
    String? statusOperacao,
  }) {
    return CommanderState(
      isLoading: isLoading ?? this.isLoading,
      prompt: prompt ?? this.prompt,
      comandoGerado: comandoGerado ?? this.comandoGerado,
      logsTerminal: logsTerminal ?? this.logsTerminal,
      historico: historico ?? this.historico,
      moduloSelecionado: moduloSelecionado ?? this.moduloSelecionado,
      arquivosOrigem: arquivosOrigem ?? this.arquivosOrigem,
      diretorioDestino: diretorioDestino ?? this.diretorioDestino,
      criarSubpastaPorArquivo:
          criarSubpastaPorArquivo ?? this.criarSubpastaPorArquivo,
      itensCopiarOrigem: itensCopiarOrigem ?? this.itensCopiarOrigem,
      destinoCopiar: destinoCopiar ?? this.destinoCopiar,
      regraColisaoCopiar: regraColisaoCopiar ?? this.regraColisaoCopiar,
      itensMoverOrigem: itensMoverOrigem ?? this.itensMoverOrigem,
      destinoMover: destinoMover ?? this.destinoMover,
      sobrescreverMover: sobrescreverMover ?? this.sobrescreverMover,
      diretorioOrganizar: diretorioOrganizar ?? this.diretorioOrganizar,
      incluirSubpastasOrganizar:
          incluirSubpastasOrganizar ?? this.incluirSubpastasOrganizar,
      categoriasSelecionadas:
          categoriasSelecionadas ?? this.categoriasSelecionadas,
      extensaoCustomizada: extensaoCustomizada ?? this.extensaoCustomizada,
      pastaCustomizada: pastaCustomizada ?? this.pastaCustomizada,
      diretorioBusca: diretorioBusca ?? this.diretorioBusca,
      searchPaths: searchPaths ?? this.searchPaths,
      includeSubfolders: includeSubfolders ?? this.includeSubfolders,
      searchMode: searchMode ?? this.searchMode,
      categoriaFiltroBusca: categoriaFiltroBusca ?? this.categoriaFiltroBusca,
      searchFileNameQuery: searchFileNameQuery ?? this.searchFileNameQuery,
      searchSizeFilter: searchSizeFilter ?? this.searchSizeFilter,
      isEscaneando: isEscaneando ?? this.isEscaneando,
      gruposConflito: gruposConflito ?? this.gruposConflito,
      grupoConflitoSelecionado:
          grupoConflitoSelecionado ?? this.grupoConflitoSelecionado,
      foundFiles: foundFiles ?? this.foundFiles,
      organizarAposTransferir:
          organizarAposTransferir ?? this.organizarAposTransferir,
      caminhoGoogleDriveDetectado:
          caminhoGoogleDriveDetectado ?? this.caminhoGoogleDriveDetectado,
      hwidAtual: hwidAtual ?? this.hwidAtual,
      softwareAtivado: softwareAtivado ?? this.softwareAtivado,
      statusLicencaTexto: statusLicencaTexto ?? this.statusLicencaTexto,
      temAtualizacao: temAtualizacao ?? this.temAtualizacao,
      dadosNovaVersao: dadosNovaVersao ?? this.dadosNovaVersao,
      verificandoAtualizacao:
          verificandoAtualizacao ?? this.verificandoAtualizacao,
      progressoExecucao: progressoExecucao ?? this.progressoExecucao,
      statusOperacao: statusOperacao ?? this.statusOperacao,
    );
  }
}

class CommanderNotifier extends StateNotifier<CommanderState> {
  final LMStudioService _lmStudioService;
  final PowerShellService _powerShellService;
  final LicenseService _licenseService;
  final UpdateService _updateService;

  CommanderNotifier({
    LMStudioService? lmStudioService,
    PowerShellService? powerShellService,
    LicenseService? licenseService,
    UpdateService? updateService,
  })  : _lmStudioService = lmStudioService ?? LMStudioService(),
        _powerShellService = powerShellService ?? PowerShellService(),
        _licenseService = licenseService ?? LicenseService(),
        _updateService = updateService ?? UpdateService(),
        super(CommanderState()) {
    _inicializar();
  }

  Future<void> _inicializar() async {
    await carregarStatusLicenca();
    await verificarGoogleDrive();
    await checarAtualizacaoSilenciosa();
  }

  Future<void> checarAtualizacaoSilenciosa() async {
    state = state.copyWith(verificandoAtualizacao: true);
    try {
      final dados = await _updateService.verificarAtualizacoes();
      if (dados != null) {
        state = state.copyWith(
          temAtualizacao: true,
          dadosNovaVersao: dados,
          verificandoAtualizacao: false,
          logsTerminal:
              '${state.logsTerminal}> Nova versão encontrada: v${dados['versao_recente']}\n',
        );
      } else {
        state = state.copyWith(verificandoAtualizacao: false);
      }
    } catch (_) {
      state = state.copyWith(verificandoAtualizacao: false);
    }
  }

  Future<void> checarAtualizacaoManual(BuildContext context) async {
    state = state.copyWith(verificandoAtualizacao: true);
    try {
      final dados = await _updateService.verificarAtualizacoes();
      state = state.copyWith(verificandoAtualizacao: false);

      if (dados != null) {
        state = state.copyWith(
          temAtualizacao: true,
          dadosNovaVersao: dados,
        );
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => UpdateDialog(dados: dados),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'O PS DesKom já está na versão mais recente (v1.0.0). Atualizações vitalícias incluídas.'),
              backgroundColor: Color(0xFF107C41),
            ),
          );
        }
      }
    } catch (e) {
      state = state.copyWith(verificandoAtualizacao: false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível verificar atualizações no momento.'),
          ),
        );
      }
    }
  }

  Future<void> carregarStatusLicenca() async {
    try {
      final hwid = await _licenseService.obterHwid();
      final status = await _licenseService.carregarStatusLicenca(hwid);

      state = state.copyWith(
        hwidAtual: hwid,
        softwareAtivado: status['ativado'] == true,
        statusLicencaTexto: status['tipo'] ?? 'Não Ativado',
        logsTerminal:
            '${state.logsTerminal}> Status da Licença: ${status['tipo']} (HWID: $hwid)\n',
      );
    } catch (e) {
      state = state.copyWith(
        statusLicencaTexto: 'Erro ao carregar licença',
      );
    }
  }

  Future<Map<String, dynamic>> validarChaveAtivacao(String chave) async {
    final resultado =
        await _licenseService.validarEAtivarChave(chave, state.hwidAtual);

    if (resultado['ativado'] == true) {
      state = state.copyWith(
        softwareAtivado: true,
        statusLicencaTexto: resultado['tipo'],
        logsTerminal:
            '${state.logsTerminal}> Licença validada e ativada: ${resultado['tipo']}\n',
      );
    }

    return resultado;
  }

  Future<void> verificarGoogleDrive() async {
    try {
      final caminhoDrive = await _powerShellService.detectarCaminhoGoogleDrive();
      if (caminhoDrive != null) {
        state = state.copyWith(
          caminhoGoogleDriveDetectado: caminhoDrive,
          logsTerminal:
              '${state.logsTerminal}> Google Drive Desktop detectado no caminho: $caminhoDrive\n',
        );
      }
    } catch (_) {}
  }

  void toggleOrganizarAposTransferir(bool valor) {
    state = state.copyWith(organizarAposTransferir: valor);
  }

  void setDestinoGoogleDrive() {
    if (state.caminhoGoogleDriveDetectado == null) return;
    final drive = state.caminhoGoogleDriveDetectado!;
    if (state.moduloSelecionado == 0) {
      state = state.copyWith(diretorioDestino: drive);
    } else if (state.moduloSelecionado == 1) {
      state = state.copyWith(destinoCopiar: drive);
    } else if (state.moduloSelecionado == 2) {
      state = state.copyWith(destinoMover: drive);
    } else if (state.moduloSelecionado == 3) {
      state = state.copyWith(diretorioOrganizar: drive);
    } else if (state.moduloSelecionado == 4) {
      adicionarSearchPath(drive);
    }
  }

  void setComando(String comando) {
    state = state.copyWith(comandoGerado: comando);
  }

  void limparTerminal() {
    state = state.copyWith(logsTerminal: '');
  }

  void selecionarModulo(int index) {
    state = state.copyWith(moduloSelecionado: index);
  }

  // Métodos Módulo 0: Descompactar
  void adicionarArquivos(List<String> novosArquivos) {
    final Set<String> atuais = Set.from(state.arquivosOrigem);
    atuais.addAll(novosArquivos);
    state = state.copyWith(arquivosOrigem: atuais.toList());
  }

  void removerArquivo(String arquivo) {
    final novos = List<String>.from(state.arquivosOrigem)..remove(arquivo);
    state = state.copyWith(arquivosOrigem: novos);
  }

  void limparArquivosOrigem() {
    state = state.copyWith(arquivosOrigem: []);
  }

  void setDiretorioDestino(String? destino) {
    state = state.copyWith(diretorioDestino: destino);
  }

  void toggleCriarSubpasta(bool value) {
    state = state.copyWith(criarSubpastaPorArquivo: value);
  }

  // Métodos Módulo 1: Copiar
  void adicionarItensCopiar(List<String> novosItens) {
    final Set<String> atuais = Set.from(state.itensCopiarOrigem);
    atuais.addAll(novosItens);
    state = state.copyWith(itensCopiarOrigem: atuais.toList());
  }

  void removerItemCopiar(int index) {
    if (index >= 0 && index < state.itensCopiarOrigem.length) {
      final novos = List<String>.from(state.itensCopiarOrigem)..removeAt(index);
      state = state.copyWith(itensCopiarOrigem: novos);
    }
  }

  void limparItensCopiar() {
    state = state.copyWith(itensCopiarOrigem: []);
  }

  void setDestinoCopiar(String? destino) {
    state = state.copyWith(destinoCopiar: destino);
  }

  void setRegraColisaoCopiar(String regra) {
    state = state.copyWith(regraColisaoCopiar: regra);
  }

  // Métodos Módulo 2: Mover
  void adicionarItensMover(List<String> novosItens) {
    final Set<String> atuais = Set.from(state.itensMoverOrigem);
    atuais.addAll(novosItens);
    state = state.copyWith(itensMoverOrigem: atuais.toList());
  }

  void removerItemMover(int index) {
    if (index >= 0 && index < state.itensMoverOrigem.length) {
      final novos = List<String>.from(state.itensMoverOrigem)..removeAt(index);
      state = state.copyWith(itensMoverOrigem: novos);
    }
  }

  void limparItensMover() {
    state = state.copyWith(itensMoverOrigem: []);
  }

  void setDestinoMover(String? destino) {
    state = state.copyWith(destinoMover: destino);
  }

  void toggleSobrescreverMover(bool valor) {
    state = state.copyWith(sobrescreverMover: valor);
  }

  // Métodos Módulo 3: Organizar
  void setDiretorioOrganizar(String? path) {
    state = state.copyWith(diretorioOrganizar: path);
  }

  void toggleIncludeSubfoldersOrganizar(bool valor) {
    state = state.copyWith(incluirSubpastasOrganizar: valor);
  }

  void toggleCategoria(String categoria, bool valor) {
    final novas = Map<String, bool>.from(state.categoriasSelecionadas);
    novas[categoria] = valor;
    state = state.copyWith(categoriasSelecionadas: novas);
  }

  void setCustomRule(String ext, String pasta) {
    state = state.copyWith(
      extensaoCustomizada: ext,
      pastaCustomizada: pasta,
    );
  }

  // Métodos Módulo 4: Procurar / Duplicados & Localizar Arquivos
  void setDiretorioBusca(String? path) {
    if (path != null && path.isNotEmpty) {
      adicionarSearchPath(path);
    }
  }

  void adicionarSearchPath(String path) {
    if (path.isEmpty) return;
    final Set<String> atuais = Set.from(state.searchPaths);
    atuais.add(path);
    state = state.copyWith(
      searchPaths: atuais.toList(),
      diretorioBusca: atuais.isNotEmpty ? atuais.first : null,
    );
  }

  void removerSearchPath(int index) {
    if (index >= 0 && index < state.searchPaths.length) {
      final novas = List<String>.from(state.searchPaths)..removeAt(index);
      state = state.copyWith(
        searchPaths: novas,
        diretorioBusca: novas.isNotEmpty ? novas.first : null,
      );
    }
  }

  void limparSearchPaths() {
    state = state.copyWith(
      searchPaths: [],
      diretorioBusca: null,
      gruposConflito: [],
      foundFiles: [],
    );
  }

  void toggleIncludeSubfolders(bool valor) {
    state = state.copyWith(includeSubfolders: valor);
  }

  void setSearchMode(SearchMode mode) {
    state = state.copyWith(searchMode: mode);
  }

  void setCategoriaFiltro(String categoria) {
    state = state.copyWith(categoriaFiltroBusca: categoria);
  }

  void setSearchFileNameQuery(String query) {
    state = state.copyWith(searchFileNameQuery: query);
  }

  void setSearchSizeFilter(String sizeFilter) {
    state = state.copyWith(searchSizeFilter: sizeFilter);
  }

  void selecionarGrupo(int index) {
    if (index >= 0 && index < state.gruposConflito.length) {
      state = state.copyWith(grupoConflitoSelecionado: index);
    }
  }

  Future<void> solicitarComando(String prompt) async {
    if (prompt.trim().isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      prompt: prompt,
      logsTerminal: '${state.logsTerminal}> Solicitando comando para: "$prompt"...\n',
    );

    try {
      final comando = await _lmStudioService.generatePowerShellCommand(prompt);
      state = state.copyWith(
        isLoading: false,
        comandoGerado: comando,
        logsTerminal: '${state.logsTerminal}> Comando gerado com sucesso via LM Studio.\n',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        logsTerminal: '${state.logsTerminal}> [ERRO IA]: $e\n',
      );
    }
  }

  Future<void> executarScript([String? scriptCustomizado]) async {
    final script = scriptCustomizado ?? state.comandoGerado;
    if (script.trim().isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      logsTerminal: '${state.logsTerminal}\n> Executando PowerShell:\n$script\n----------------------------------------\n',
    );

    try {
      final resultado = await _powerShellService.execute(script);

      final novoHistorico = List<Map<String, String>>.from(state.historico)
        ..add({
          'prompt': state.prompt,
          'comando': script,
          'resultado': resultado,
          'timestamp': DateTime.now().toIso8601String(),
        });

      state = state.copyWith(
        isLoading: false,
        logsTerminal: '${state.logsTerminal}$resultado\n> [Fim da execução]\n',
        historico: novoHistorico,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        logsTerminal: '${state.logsTerminal}> [ERRO EXECUÇÃO]: $e\n',
      );
    }
  }

  Future<void> descompactarAgora() async {
    if (state.arquivosOrigem.isEmpty ||
        state.diretorioDestino == null ||
        state.diretorioDestino!.isEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      progressoExecucao: 0.0,
      statusOperacao: 'Iniciando lote de extração...',
      logsTerminal: '${state.logsTerminal}> Executando extração em lote no Windows...\n',
    );

    try {
      final resultado = await _powerShellService.descompactarArquivos(
        arquivosOrigem: state.arquivosOrigem,
        diretorioDestino: state.diretorioDestino!,
        criarSubpastaPorArquivo: state.criarSubpastaPorArquivo,
        onProgresso: (processados, total, arquivoAtual) {
          final prog = processados / total;
          state = state.copyWith(
            progressoExecucao: prog,
            statusOperacao: 'Descompactando ($processados/$total): $arquivoAtual',
          );
        },
      );

      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 1.0,
        statusOperacao: 'Lote de descompactação finalizado com sucesso!',
        logsTerminal: '${state.logsTerminal}$resultado\n',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 0.0,
        statusOperacao: 'Erro durante o processo de extração.',
        logsTerminal: '${state.logsTerminal}> [ERRO EXTRAÇÃO]: $e\n',
      );
    }
  }

  Future<void> dispararCopia() async {
    if (state.itensCopiarOrigem.isEmpty ||
        state.destinoCopiar == null ||
        state.destinoCopiar!.isEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      progressoExecucao: 0.0,
      statusOperacao: 'Iniciando cópia de itens...',
      logsTerminal: '${state.logsTerminal}> Executando cópia em lote no Windows...\n',
    );

    try {
      final resultado = await _powerShellService.copiarItens(
        itensOrigem: state.itensCopiarOrigem,
        diretorioDestino: state.destinoCopiar!,
        regraColisao: state.regraColisaoCopiar,
        organizarNoDestino: state.organizarAposTransferir,
        onProgresso: (processados, total, itemAtual) {
          final prog = processados / total;
          state = state.copyWith(
            progressoExecucao: prog,
            statusOperacao: 'Copiando ($processados/$total): $itemAtual',
          );
        },
      );

      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 1.0,
        statusOperacao: 'Lote de cópia finalizado com sucesso!',
        logsTerminal: '${state.logsTerminal}$resultado\n',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 0.0,
        statusOperacao: 'Erro durante a cópia de itens.',
        logsTerminal: '${state.logsTerminal}> [ERRO CÓPIA]: $e\n',
      );
    }
  }

  Future<void> dispararMovimentacao() async {
    if (state.itensMoverOrigem.isEmpty ||
        state.destinoMover == null ||
        state.destinoMover!.isEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      progressoExecucao: 0.0,
      statusOperacao: 'Iniciando movimentação de itens...',
      logsTerminal: '${state.logsTerminal}> Executando movimentação em lote no Windows...\n',
    );

    try {
      final resultado = await _powerShellService.moverItens(
        itensOrigem: state.itensMoverOrigem,
        diretorioDestino: state.destinoMover!,
        sobrescreverExistentes: state.sobrescreverMover,
        organizarNoDestino: state.organizarAposTransferir,
        onProgresso: (processados, total, itemAtual) {
          final prog = processados / total;
          state = state.copyWith(
            progressoExecucao: prog,
            statusOperacao: 'Movendo ($processados/$total): $itemAtual',
          );
        },
      );

      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 1.0,
        statusOperacao: 'Lote de movimentação finalizado com sucesso!',
        logsTerminal: '${state.logsTerminal}$resultado\n',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 0.0,
        statusOperacao: 'Erro durante a movimentação de itens.',
        logsTerminal: '${state.logsTerminal}> [ERRO MOVIMENTAÇÃO]: $e\n',
      );
    }
  }

  Future<void> dispararOrganizacao() async {
    if (state.diretorioOrganizar == null || state.diretorioOrganizar!.isEmpty) {
      return;
    }

    final Map<String, List<String>> regrasAtivas = {};

    CommanderState.categoriasDefinidas.forEach((cat, exts) {
      if (state.categoriasSelecionadas[cat] == true) {
        regrasAtivas[cat] = exts;
      }
    });

    if (state.extensaoCustomizada.trim().isNotEmpty &&
        state.pastaCustomizada.trim().isNotEmpty) {
      final ext = state.extensaoCustomizada.trim().startsWith('.')
          ? state.extensaoCustomizada.trim()
          : '.${state.extensaoCustomizada.trim()}';
      regrasAtivas[state.pastaCustomizada.trim()] = [ext];
    }

    if (regrasAtivas.isEmpty) {
      state = state.copyWith(
        statusOperacao: 'Nenhuma categoria ou regra selecionada para organização.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      progressoExecucao: 0.0,
      statusOperacao: 'Iniciando organização do diretório...',
      logsTerminal: '${state.logsTerminal}> Executando organização de diretório no Windows...\n',
    );

    try {
      final resultado = await _powerShellService.organizarDiretorio(
        diretorioRaiz: state.diretorioOrganizar!,
        regras: regrasAtivas,
        incluirSubpastas: state.incluirSubpastasOrganizar,
        onProgresso: (processados, total, categoriaAtual) {
          final prog = processados / total;
          state = state.copyWith(
            progressoExecucao: prog,
            statusOperacao: 'Organizando ($processados/$total): $categoriaAtual',
          );
        },
      );

      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 1.0,
        statusOperacao: 'Organização do diretório concluída!',
        logsTerminal: '${state.logsTerminal}$resultado\n',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 0.0,
        statusOperacao: 'Erro durante a organização do diretório.',
        logsTerminal: '${state.logsTerminal}> [ERRO ORGANIZAÇÃO]: $e\n',
      );
    }
  }

  Future<void> dispararOrganizacaoDeItens(
      List<String> arquivos, String destino) async {
    if (arquivos.isEmpty || destino.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      progressoExecucao: 0.0,
      statusOperacao: 'Organizando e movendo itens selecionados...',
      logsTerminal:
          '${state.logsTerminal}> Iniciando organização de ${arquivos.length} item(ns) para: $destino...\n',
    );

    try {
      final resultado = await _powerShellService.organizarItensSelecionados(
        caminhosArquivos: arquivos,
        pastaDestinoBase: destino,
      );

      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 1.0,
        statusOperacao: 'Itens organizados e movidos com sucesso!',
        logsTerminal: '${state.logsTerminal}$resultado\n',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressoExecucao: 0.0,
        statusOperacao: 'Erro ao organizar e mover itens.',
        logsTerminal: '${state.logsTerminal}> [ERRO MOVER/ORGANIZAR]: $e\n',
      );
    }
  }

  Future<void> dispararVarreduraDuplicados() async {
    if (state.searchPaths.isEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      isEscaneando: true,
      progressoExecucao: 0.0,
      statusOperacao: 'Analisando arquivos e calculando hashes SHA-256...',
      logsTerminal: '${state.logsTerminal}> Iniciando varredura de duplicados em ${state.searchPaths.length} pasta(s) (filtro: ${state.categoriaFiltroBusca}, subpastas: ${state.includeSubfolders})...\n',
    );

    try {
      final grupos = await _powerShellService.detectarDuplicados(
        searchPaths: state.searchPaths,
        categoriaFiltro: state.categoriaFiltroBusca,
        includeSubfolders: state.includeSubfolders,
      );

      state = state.copyWith(
        isLoading: false,
        isEscaneando: false,
        progressoExecucao: 1.0,
        gruposConflito: grupos,
        grupoConflitoSelecionado: 0,
        statusOperacao: 'Varredura concluída. ${grupos.length} grupo(s) de conflito detectado(s).',
        logsTerminal: '${state.logsTerminal}> Varredura finalizada. Encontrados ${grupos.length} grupo(s) com duplicados/conflitos.\n',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isEscaneando: false,
        progressoExecucao: 0.0,
        statusOperacao: 'Varredura interrompida ou com erro.',
        logsTerminal: '${state.logsTerminal}> [VARREDURA CANCELADA OU ERRO]: $e\n',
      );
    }
  }

  Future<void> dispararBuscaArquivos() async {
    if (state.searchPaths.isEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      isEscaneando: true,
      progressoExecucao: 0.0,
      statusOperacao: 'Localizando arquivos por filtros...',
      logsTerminal: '${state.logsTerminal}> Iniciando busca de arquivos em ${state.searchPaths.length} pasta(s) (termo: "${state.searchFileNameQuery}", tamanho: ${state.searchSizeFilter})...\n',
    );

    try {
      final resultados = await _powerShellService.searchFiles(
        searchPaths: state.searchPaths,
        includeSubfolders: state.includeSubfolders,
        categoriaFiltro: state.categoriaFiltroBusca,
        nameQuery: state.searchFileNameQuery,
        sizeFilter: state.searchSizeFilter,
      );

      state = state.copyWith(
        isLoading: false,
        isEscaneando: false,
        progressoExecucao: 1.0,
        foundFiles: resultados,
        statusOperacao: 'Busca concluída. ${resultados.length} arquivo(s) localizado(s).',
        logsTerminal: '${state.logsTerminal}> Localizados ${resultados.length} arquivo(s) correspondente(s).\n',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isEscaneando: false,
        progressoExecucao: 0.0,
        statusOperacao: 'Busca de arquivos interrompida ou com erro.',
        logsTerminal: '${state.logsTerminal}> [BUSCA CANCELADA OU ERRO]: $e\n',
      );
    }
  }

  Future<void> cancelarVarredura() async {
    await _powerShellService.cancelarOperacaoAtiva();
    state = state.copyWith(
      isLoading: false,
      isEscaneando: false,
      progressoExecucao: 0.0,
      statusOperacao: 'Operação interrompida pelo usuário.',
      logsTerminal: '${state.logsTerminal}> Operação cancelada pelo usuário.\n',
    );
  }

  Future<void> removerArquivoDoConflito(String caminho, int grupoIndex) async {
    if (grupoIndex < 0 || grupoIndex >= state.gruposConflito.length) return;

    state = state.copyWith(
      isLoading: true,
      statusOperacao: 'Apagando arquivo...',
    );

    final ok = await _powerShellService.apagarArquivo(caminho);

    if (ok) {
      final novosGrupos = List<Map<String, dynamic>>.from(
        state.gruposConflito.map((g) => Map<String, dynamic>.from(g)),
      );

      final grupo = novosGrupos[grupoIndex];
      final arquivos = List<Map<String, dynamic>>.from(grupo['arquivos']);
      arquivos.removeWhere((a) => a['caminho'] == caminho);

      if (arquivos.length < 2) {
        novosGrupos.removeAt(grupoIndex);
      } else {
        grupo['arquivos'] = arquivos;
      }

      int novoSel = state.grupoConflitoSelecionado;
      if (novoSel >= novosGrupos.length) {
        novoSel = novosGrupos.isNotEmpty ? novosGrupos.length - 1 : 0;
      }

      state = state.copyWith(
        isLoading: false,
        gruposConflito: novosGrupos,
        grupoConflitoSelecionado: novoSel,
        statusOperacao: 'Arquivo apagado com sucesso.',
        logsTerminal: '${state.logsTerminal}> Arquivo removido: $caminho\n',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        statusOperacao: 'Falha ao apagar o arquivo.',
        logsTerminal: '${state.logsTerminal}> Erro ao tentar apagar: $caminho\n',
      );
    }
  }

  Future<void> renomearArquivoDoConflito(
      String caminho, String novoNome, int grupoIndex) async {
    if (grupoIndex < 0 || grupoIndex >= state.gruposConflito.length) return;

    state = state.copyWith(
      isLoading: true,
      statusOperacao: 'Renomeando arquivo...',
    );

    final ok = await _powerShellService.renomearArquivo(caminho, novoNome);

    if (ok) {
      final novosGrupos = List<Map<String, dynamic>>.from(
        state.gruposConflito.map((g) => Map<String, dynamic>.from(g)),
      );

      final grupo = novosGrupos[grupoIndex];
      final arquivos = List<Map<String, dynamic>>.from(grupo['arquivos']);

      for (var a in arquivos) {
        if (a['caminho'] == caminho) {
          a['nome'] = novoNome;
        }
      }
      grupo['arquivos'] = arquivos;

      state = state.copyWith(
        isLoading: false,
        gruposConflito: novosGrupos,
        statusOperacao: 'Arquivo renomeado com sucesso.',
        logsTerminal: '${state.logsTerminal}> Arquivo renomeado para: $novoNome\n',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        statusOperacao: 'Falha ao renomear o arquivo.',
        logsTerminal: '${state.logsTerminal}> Erro ao tentar renomear: $caminho\n',
      );
    }
  }
}

final commanderProvider =
    StateNotifierProvider<CommanderNotifier, CommanderState>((ref) {
  return CommanderNotifier();
});
