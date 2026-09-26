import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'providers/commander_provider.dart';
import 'widgets/about_dialog_widget.dart';
import 'widgets/audio_preview_card.dart';
import 'widgets/update_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PSDesKomApp()));
}

class PSDesKomApp extends StatelessWidget {
  const PSDesKomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PS DesKom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0078D4),
          surface: Color(0xFF252526),
          onPrimary: Colors.white,
          onSurface: Color(0xFFCCCCCC),
        ),
        cardColor: const Color(0xFF252526),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2D2D2D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF3F3F46)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF3F3F46)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF0078D4)),
          ),
          hintStyle: const TextStyle(color: Color(0xFF888888)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _extController = TextEditingController();
  final TextEditingController _pastaController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _extController.dispose();
    _pastaController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Descompactar
  Future<void> _adicionarArquivos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['zip', 'rar', '7z'],
    );

    if (result != null) {
      final paths = result.paths.whereType<String>().toList();
      ref.read(commanderProvider.notifier).adicionarArquivos(paths);
    }
  }

  Future<void> _selecionarPastaDestino() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).setDiretorioDestino(selectedDirectory);
    }
  }

  // Copiar
  Future<void> _adicionarArquivosCopiar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null) {
      final paths = result.paths.whereType<String>().toList();
      ref.read(commanderProvider.notifier).adicionarItensCopiar(paths);
    }
  }

  Future<void> _adicionarPastaCopiar() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).adicionarItensCopiar([selectedDirectory]);
    }
  }

  Future<void> _selecionarDestinoCopiar() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).setDestinoCopiar(selectedDirectory);
    }
  }

  // Mover
  Future<void> _adicionarArquivosMover() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null) {
      final paths = result.paths.whereType<String>().toList();
      ref.read(commanderProvider.notifier).adicionarItensMover(paths);
    }
  }

  Future<void> _adicionarPastaMover() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).adicionarItensMover([selectedDirectory]);
    }
  }

  Future<void> _selecionarDestinoMover() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).setDestinoMover(selectedDirectory);
    }
  }

  // Organizar
  Future<void> _selecionarDiretorioOrganizar() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).setDiretorioOrganizar(selectedDirectory);
    }
  }

  // Procurar / Duplicados
  Future<void> _selecionarDiretorioBusca() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).setDiretorioBusca(selectedDirectory);
    }
  }

  Future<void> _organizarEMoverNaoDuplicados(
      BuildContext context, CommanderState state, CommanderNotifier notifier) async {
    String? dest = await FilePicker.platform.getDirectoryPath();
    if (dest != null && dest.isNotEmpty) {
      final List<String> todos = [];
      for (var g in state.gruposConflito) {
        final arqs = List<Map<String, dynamic>>.from(g['arquivos'] ?? []);
        for (var a in arqs) {
          final c = a['caminho'] as String?;
          if (c != null && c.isNotEmpty) todos.add(c);
        }
      }
      if (todos.isNotEmpty) {
        await notifier.dispararOrganizacaoDeItens(todos, dest);
      }
    }
  }

  void _exibirDialogoRenomear(BuildContext context, String caminho, int grupoIndex) {
    final nomeAtual = p.basename(caminho);
    final controller = TextEditingController(text: nomeAtual);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252526),
          title: const Text('Renomear Arquivo', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Novo nome do arquivo',
              labelStyle: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF888888))),
            ),
            ElevatedButton(
              onPressed: () {
                final novo = controller.text.trim();
                if (novo.isNotEmpty && novo != nomeAtual) {
                  ref
                      .read(commanderProvider.notifier)
                      .renomearArquivoDoConflito(caminho, novo, grupoIndex);
                }
                Navigator.of(dialogCtx).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D4)),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CommanderState>(commanderProvider, (previous, next) {
      if (previous?.logsTerminal != next.logsTerminal) {
        _scrollToBottom();
      }
    });

    final state = ref.watch(commanderProvider);
    final notifier = ref.read(commanderProvider.notifier);

    final List<String> modulos = [
      'DESCOMPACTAR',
      'COPIAR',
      'MOVER',
      'ORGANIZAR',
      'PROCURAR',
    ];

    return Scaffold(
      body: Column(
        children: [
          // Barra Superior com Título do Projeto e Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF252526),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal, color: Color(0xFF0078D4), size: 24),
                    const SizedBox(width: 10),
                    const Text(
                      'PS DesKom',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (state.temAtualizacao && state.dadosNovaVersao != null) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => UpdateDialog(dados: state.dadosNovaVersao!),
                          );
                        },
                        icon: const Icon(Icons.system_update_outlined,
                            size: 16, color: Color(0xFF107C41)),
                        label: Text(
                          'Atualização Disponível (v${state.dadosNovaVersao!['versao_recente']})',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF4EC9B0)),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF107C41),
                          side: const BorderSide(color: Color(0xFF107C41)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => notifier.limparTerminal(),
                      icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                      label: const Text('Limpar Console'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFCCCCCC),
                        side: const BorderSide(color: Color(0xFF3F3F46)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AboutDialogWidget(),
                        );
                      },
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Sobre'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0078D4),
                        side: const BorderSide(color: Color(0xFF0078D4)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Barra de Ferramentas / Abas de Módulos
                Row(
                  children: List.generate(modulos.length, (index) {
                    final isSelected = state.moduloSelecionado == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => notifier.selecionarModulo(index),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0078D4)
                                : const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0078D4)
                                  : const Color(0xFF3F3F46),
                            ),
                          ),
                          child: Text(
                            modulos[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFFCCCCCC),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF3F3F46)),

          // Área Central do Módulo Ativo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildConteudoModulo(context, state, notifier, modulos),
            ),
          ),

          // Painel de Progresso e Botão de Ação do Rodapé
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.isLoading || state.progressoExecucao > 0) ...[
                  LinearProgressIndicator(
                    value: state.progressoExecucao > 0 ? state.progressoExecucao : null,
                    backgroundColor: const Color(0xFF2D2D2D),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0078D4)),
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.statusOperacao.isNotEmpty
                            ? state.statusOperacao
                            : 'Aguardando ação do usuário...',
                        style: TextStyle(
                          fontSize: 12,
                          color: state.statusOperacao.contains('Erro')
                              ? Colors.redAccent
                              : const Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
                    if (state.moduloSelecionado == 0)
                      ElevatedButton.icon(
                        onPressed: (state.arquivosOrigem.isNotEmpty &&
                                state.diretorioDestino != null &&
                                state.diretorioDestino!.isNotEmpty &&
                                !state.isLoading)
                            ? () => notifier.descompactarAgora()
                            : null,
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.unarchive, size: 20),
                        label: const Text(
                          'DESCOMPACTAR AGORA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF107C41),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    if (state.moduloSelecionado == 1)
                      ElevatedButton.icon(
                        onPressed: (state.itensCopiarOrigem.isNotEmpty &&
                                state.destinoCopiar != null &&
                                state.destinoCopiar!.isNotEmpty &&
                                !state.isLoading)
                            ? () => notifier.dispararCopia()
                            : null,
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.copy, size: 20),
                        label: const Text(
                          'INICIAR CÓPIA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0078D4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    if (state.moduloSelecionado == 2)
                      ElevatedButton.icon(
                        onPressed: (state.itensMoverOrigem.isNotEmpty &&
                                state.destinoMover != null &&
                                state.destinoMover!.isNotEmpty &&
                                !state.isLoading)
                            ? () => notifier.dispararMovimentacao()
                            : null,
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.drive_file_move_outlined, size: 20),
                        label: const Text(
                          'MOVER ARQUIVOS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD13438),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    if (state.moduloSelecionado == 3)
                      ElevatedButton.icon(
                        onPressed: (state.diretorioOrganizar != null &&
                                state.diretorioOrganizar!.isNotEmpty &&
                                !state.isLoading)
                            ? () => notifier.dispararOrganizacao()
                            : null,
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_mosaic, size: 20),
                        label: const Text(
                          'ORGANIZAR PASTA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0078D4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    if (state.moduloSelecionado == 4)
                      state.isEscaneando
                          ? ElevatedButton.icon(
                              onPressed: () => notifier.cancelarVarredura(),
                              icon: const Icon(Icons.stop_circle_outlined, size: 20),
                              label: const Text(
                                'INTERROMPER BUSCA',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: (state.diretorioBusca != null &&
                                      state.diretorioBusca!.isNotEmpty &&
                                      !state.isLoading)
                                  ? () => notifier.dispararVarreduraDuplicados()
                                  : null,
                              icon: state.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.search_outlined, size: 20),
                              label: const Text(
                                'ESCANEAR DUPLICADOS',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0078D4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                              ),
                            ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Console Terminal Inferior
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              height: 160,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0C0C),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: SizedBox(
                      width: double.infinity,
                      child: SelectableText(
                        state.logsTerminal.isEmpty
                            ? 'Terminal pronto. Módulo operacional pronto.'
                            : state.logsTerminal,
                        style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 12,
                          color: state.logsTerminal.isEmpty
                              ? const Color(0xFF666666)
                              : const Color(0xFF4EC9B0),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildConteudoModulo(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
    List<String> modulos,
  ) {
    switch (state.moduloSelecionado) {
      case 0:
        return _buildModuloDescompactar(context, state, notifier);
      case 1:
        return _buildModuloCopiar(context, state, notifier);
      case 2:
        return _buildModuloMover(context, state, notifier);
      case 3:
        return _buildModuloOrganizar(context, state, notifier);
      case 4:
        return _buildModuloProcurar(context, state, notifier);
      default:
        return _buildModuloEmDesenvolvimento(modulos[state.moduloSelecionado]);
    }
  }

  Widget _buildModuloDescompactar(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CARD 1: ORIGEM DOS ARQUIVOS
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.folder_zip_outlined,
                              color: Color(0xFF0078D4), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Card 1 (ORIGEM) [${state.arquivosOrigem.length}]',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _adicionarArquivos,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('(+) Adicionar Arquivos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0078D4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF3F3F46), height: 20),
                  Expanded(
                    child: state.arquivosOrigem.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.archive_outlined,
                                    size: 40, color: Color(0xFF555555)),
                                SizedBox(height: 8),
                                Text(
                                  'Nenhum arquivo adicionado à fila.\nClique em "(+) Adicionar Arquivos" (.zip, .rar, .7z)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.arquivosOrigem.length,
                            separatorBuilder: (_, __) =>
                                const Divider(color: Color(0xFF2D2D2D), height: 1),
                            itemBuilder: (context, index) {
                              final filePath = state.arquivosOrigem[index];
                              final fileName = p.basename(filePath);
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                                leading: const Icon(Icons.insert_drive_file_outlined,
                                    color: Color(0xFF0078D4), size: 18),
                                title: Text(
                                  fileName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                                subtitle: Text(
                                  filePath,
                                  style: const TextStyle(
                                      color: Color(0xFF888888), fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.redAccent, size: 18),
                                  onPressed: () => notifier.removerArquivo(filePath),
                                  tooltip: 'Remover da fila',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // CARD 2: DESTINO DAS PASTAS
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.folder_open,
                              color: Color(0xFF0078D4), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Card 2 (DESTINO)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _selecionarPastaDestino,
                            icon: const Icon(Icons.create_new_folder_outlined, size: 16),
                            label: const Text('Selecionar Pasta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0078D4),
                              side: const BorderSide(color: Color(0xFF0078D4)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          if (state.caminhoGoogleDriveDetectado != null) ...[
                            const SizedBox(width: 6),
                            OutlinedButton.icon(
                              onPressed: () => notifier.setDestinoGoogleDrive(),
                              icon: const Icon(Icons.cloud_queue, size: 16),
                              label: const Text('Google Drive'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4EC9B0),
                                side: const BorderSide(color: Color(0xFF4EC9B0)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF3F3F46), height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Caminho de Destino:',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF888888)),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          state.diretorioDestino ??
                              'Nenhum diretório selecionado. Clique em "Selecionar Pasta".',
                          style: TextStyle(
                            fontSize: 13,
                            color: state.diretorioDestino != null
                                ? const Color(0xFF4EC9B0)
                                : const Color(0xFF888888),
                            fontFamily: 'Consolas',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: state.criarSubpastaPorArquivo,
                          activeColor: const Color(0xFF0078D4),
                          onChanged: (val) {
                            if (val != null) notifier.toggleCriarSubpasta(val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Criar pasta com o nome do arquivo para cada extração',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuloCopiar(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CARD 1: ORIGEM DOS ITENS
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.copy_all,
                              color: Color(0xFF0078D4), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Card 1 (ORIGEM) [${state.itensCopiarOrigem.length}]',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _adicionarArquivosCopiar,
                            icon: const Icon(Icons.insert_drive_file, size: 14),
                            label: const Text('(+) Arquivos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0078D4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: _adicionarPastaCopiar,
                            icon: const Icon(Icons.folder, size: 14),
                            label: const Text('(+) Pasta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0078D4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF3F3F46), height: 20),
                  Expanded(
                    child: state.itensCopiarOrigem.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.content_copy,
                                    size: 40, color: Color(0xFF555555)),
                                SizedBox(height: 8),
                                Text(
                                  'Nenhum item adicionado para cópia.\nUtilize "(+) Arquivos" ou "(+) Pasta".',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.itensCopiarOrigem.length,
                            separatorBuilder: (_, __) =>
                                const Divider(color: Color(0xFF2D2D2D), height: 1),
                            itemBuilder: (context, index) {
                              final itemPath = state.itensCopiarOrigem[index];
                              final itemName = p.basename(itemPath);
                              final isDirectory =
                                  FileSystemEntity.isDirectorySync(itemPath);
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                                leading: Icon(
                                  isDirectory
                                      ? Icons.folder_open
                                      : Icons.insert_drive_file,
                                  color: const Color(0xFF0078D4),
                                  size: 18,
                                ),
                                title: Text(
                                  itemName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                                subtitle: Text(
                                  itemPath,
                                  style: const TextStyle(
                                      color: Color(0xFF888888), fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.redAccent, size: 18),
                                  onPressed: () => notifier.removerItemCopiar(index),
                                  tooltip: 'Remover da fila',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // CARD 2: DESTINO DA CÓPIA E REGRAS
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.folder_open,
                              color: Color(0xFF0078D4), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Card 2 (DESTINO)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _selecionarDestinoCopiar,
                            icon: const Icon(Icons.create_new_folder_outlined, size: 16),
                            label: const Text('Selecionar Pasta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0078D4),
                              side: const BorderSide(color: Color(0xFF0078D4)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          if (state.caminhoGoogleDriveDetectado != null) ...[
                            const SizedBox(width: 6),
                            OutlinedButton.icon(
                              onPressed: () => notifier.setDestinoGoogleDrive(),
                              icon: const Icon(Icons.cloud_queue, size: 16),
                              label: const Text('Google Drive'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4EC9B0),
                                side: const BorderSide(color: Color(0xFF4EC9B0)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF3F3F46), height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Caminho de Destino:',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF888888)),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          state.destinoCopiar ??
                              'Nenhum diretório selecionado. Clique em "Selecionar Pasta".',
                          style: TextStyle(
                            fontSize: 13,
                            color: state.destinoCopiar != null
                                ? const Color(0xFF4EC9B0)
                                : const Color(0xFF888888),
                            fontFamily: 'Consolas',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: state.organizarAposTransferir,
                          activeColor: const Color(0xFF0078D4),
                          onChanged: (val) {
                            if (val != null) notifier.toggleOrganizarAposTransferir(val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Organizar automaticamente por categorias no destino',
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'REGRA DE COLISÃO / DUPLICADOS:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCCCCCC),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: state.regraColisaoCopiar,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    dropdownColor: const Color(0xFF2D2D2D),
                    items: const [
                      DropdownMenuItem(
                        value: 'substituir',
                        child: Text('Substituir existentes (Sobrescrever)'),
                      ),
                      DropdownMenuItem(
                        value: 'pular',
                        child: Text('Pular duplicados (Ignorar se existir)'),
                      ),
                      DropdownMenuItem(
                        value: 'manter',
                        child: Text('Manter ambos (Criar cópia renomeada)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        notifier.setRegraColisaoCopiar(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuloMover(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CARD 1: ORIGEM DOS ITENS A MOVER
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.drive_file_move_outlined,
                              color: Color(0xFFD13438), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Card 1 (ORIGEM) [${state.itensMoverOrigem.length}]',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _adicionarArquivosMover,
                            icon: const Icon(Icons.insert_drive_file, size: 14),
                            label: const Text('(+) Arquivos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD13438),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: _adicionarPastaMover,
                            icon: const Icon(Icons.folder, size: 14),
                            label: const Text('(+) Pasta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD13438),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF3F3F46), height: 20),
                  Expanded(
                    child: state.itensMoverOrigem.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.drive_file_move_outlined,
                                    size: 40, color: Color(0xFF555555)),
                                SizedBox(height: 8),
                                Text(
                                  'Nenhum item adicionado para movimentação.\nUtilize "(+) Arquivos" ou "(+) Pasta".',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.itensMoverOrigem.length,
                            separatorBuilder: (_, __) =>
                                const Divider(color: Color(0xFF2D2D2D), height: 1),
                            itemBuilder: (context, index) {
                              final itemPath = state.itensMoverOrigem[index];
                              final itemName = p.basename(itemPath);
                              final isDirectory =
                                  FileSystemEntity.isDirectorySync(itemPath);
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                                leading: Icon(
                                  isDirectory
                                      ? Icons.folder_open
                                      : Icons.insert_drive_file,
                                  color: const Color(0xFFD13438),
                                  size: 18,
                                ),
                                title: Text(
                                  itemName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                                subtitle: Text(
                                  itemPath,
                                  style: const TextStyle(
                                      color: Color(0xFF888888), fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.redAccent, size: 18),
                                  onPressed: () => notifier.removerItemMover(index),
                                  tooltip: 'Remover da fila',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // CARD 2: DESTINO DA MOVIMENTAÇÃO
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.folder_open,
                              color: Color(0xFFD13438), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Card 2 (DESTINO)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _selecionarDestinoMover,
                            icon: const Icon(Icons.create_new_folder_outlined, size: 16),
                            label: const Text('Selecionar Pasta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD13438),
                              side: const BorderSide(color: Color(0xFFD13438)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          if (state.caminhoGoogleDriveDetectado != null) ...[
                            const SizedBox(width: 6),
                            OutlinedButton.icon(
                              onPressed: () => notifier.setDestinoGoogleDrive(),
                              icon: const Icon(Icons.cloud_queue, size: 16),
                              label: const Text('Google Drive'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4EC9B0),
                                side: const BorderSide(color: Color(0xFF4EC9B0)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF3F3F46), height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Caminho de Destino:',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF888888)),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          state.destinoMover ??
                              'Nenhum diretório selecionado. Clique em "Selecionar Pasta".',
                          style: TextStyle(
                            fontSize: 13,
                            color: state.destinoMover != null
                                ? const Color(0xFF4EC9B0)
                                : const Color(0xFF888888),
                            fontFamily: 'Consolas',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: state.organizarAposTransferir,
                          activeColor: const Color(0xFFD13438),
                          onChanged: (val) {
                            if (val != null) notifier.toggleOrganizarAposTransferir(val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Organizar automaticamente por categorias no destino',
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: state.sobrescreverMover,
                          activeColor: const Color(0xFFD13438),
                          onChanged: (val) {
                            if (val != null) notifier.toggleSobrescreverMover(val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Sobrescrever arquivos se já existirem no destino',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuloOrganizar(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Seletor de Diretório Raiz
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: Color(0xFF3F3F46)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.folder_special, color: Color(0xFF0078D4), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DIRETÓRIO RAIZ A ORGANIZAR:',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 2),
                      SelectableText(
                        state.diretorioOrganizar ??
                            'Nenhum diretório selecionado. Clique em "Buscar Pasta".',
                        style: TextStyle(
                          fontSize: 13,
                          color: state.diretorioOrganizar != null
                              ? const Color(0xFF4EC9B0)
                              : const Color(0xFF888888),
                          fontFamily: 'Consolas',
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selecionarDiretorioOrganizar,
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('Buscar Pasta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Painel de Regras
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFF3F3F46)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'CATEGORIAS E REGRAS DE ORGANIZAÇÃO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Divider(color: Color(0xFF3F3F46), height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: CommanderState.categoriasDefinidas.keys
                                .map((categoria) {
                              final isSelected =
                                  state.categoriasSelecionadas[categoria] ?? true;
                              return SizedBox(
                                width: 280,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D2D2D),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: const Color(0xFF3F3F46)),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        activeColor: const Color(0xFF0078D4),
                                        onChanged: (val) {
                                          if (val != null) {
                                            notifier.toggleCategoria(categoria, val);
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              categoria,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              CommanderState
                                                  .categoriasDefinidas[categoria]!
                                                  .join(', '),
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF888888)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFF3F3F46)),
                          const SizedBox(height: 8),

                          // Regra Personalizada
                          Row(
                            children: [
                              const Text(
                                'Regra Personalizada:',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _extController,
                                  onChanged: (v) {
                                    notifier.setCustomRule(
                                        v, _pastaController.text);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Ex: .dds',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward,
                                  size: 16, color: Color(0xFF888888)),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 180,
                                child: TextField(
                                  controller: _pastaController,
                                  onChanged: (v) {
                                    notifier.setCustomRule(
                                        _extController.text, v);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Nome da Pasta Ex: Texturas DDS',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: state.incluirSubpastasOrganizar,
                          activeColor: const Color(0xFF0078D4),
                          onChanged: (val) {
                            if (val != null) {
                              notifier.toggleIncludeSubfoldersOrganizar(val);
                            }
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Incluir arquivos dentro de subpastas (Recursivo)',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuloProcurar(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Seletor de Pasta Raiz e Filtro por Categoria
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: Color(0xFF3F3F46)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.search_outlined, color: Color(0xFF0078D4), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PASTA A SER ANALISADA:',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 2),
                      SelectableText(
                        state.diretorioBusca ??
                            'Nenhum diretório selecionado. Clique em "Buscar Pasta".',
                        style: TextStyle(
                          fontSize: 13,
                          color: state.diretorioBusca != null
                              ? const Color(0xFF4EC9B0)
                              : const Color(0xFF888888),
                          fontFamily: 'Consolas',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _selecionarDiretorioBusca,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Buscar Pasta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0078D4),
                    side: const BorderSide(color: Color(0xFF0078D4)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    initialValue: state.categoriaFiltroBusca,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    dropdownColor: const Color(0xFF2D2D2D),
                    items: const [
                      DropdownMenuItem(
                          value: 'todos',
                          child: Text('Todos', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(
                          value: 'imagens',
                          child: Text('Imagens', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(
                          value: 'videos',
                          child: Text('Vídeos', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(
                          value: 'audios',
                          child: Text('Áudios', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(
                          value: 'textos',
                          child: Text('Texto/Docs', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(
                          value: 'instaladores',
                          child: Text('Instaladores', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) notifier.setCategoriaFiltro(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Painel Principal Dividido: Master - Detail
        Expanded(
          child: state.gruposConflito.isEmpty
              ? Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: Color(0xFF3F3F46)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.find_in_page_outlined,
                            size: 48, color: Color(0xFF555555)),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum conflito ou arquivo duplicado detectado.',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Selecione uma pasta e clique em "ESCANEAR DUPLICADOS" na barra inferior.',
                          style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coluna Esquerda: Lista de Conflitos
                    SizedBox(
                      width: 280,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Color(0xFF3F3F46)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'GRUPOS DE CONFLITO [${state.gruposConflito.length}]',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFCCCCCC),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const Divider(color: Color(0xFF3F3F46), height: 16),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: state.gruposConflito.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final grupo = state.gruposConflito[index];
                                    final isSelected =
                                        state.grupoConflitoSelecionado == index;
                                    final isIdentical =
                                        grupo['tipo'] == 'identical';
                                    final arquivos =
                                        grupo['arquivos'] as List? ?? [];

                                    return InkWell(
                                      onTap: () => notifier.selecionarGrupo(index),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF0078D4)
                                                  .withValues(alpha: 0.2)
                                              : const Color(0xFF2D2D2D),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF0078D4)
                                                : const Color(0xFF3F3F46),
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isIdentical
                                                        ? const Color(0xFF107C41)
                                                        : const Color(0xFFD83B01),
                                                    borderRadius:
                                                        BorderRadius.circular(2),
                                                  ),
                                                  child: Text(
                                                    isIdentical
                                                        ? 'CONTEÚDO IDÊNTICO'
                                                        : 'MESMO NOME',
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${arquivos.length} itens',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFFCCCCCC)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              arquivos.isNotEmpty
                                                  ? arquivos.first['nome'] ?? ''
                                                  : 'Grupo $index',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Coluna Direita: Painel de Comparação Lado a Lado
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Color(0xFF3F3F46)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: _buildPainelComparacao(
                            context,
                            state,
                            notifier,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPainelComparacao(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    if (state.grupoConflitoSelecionado < 0 ||
        state.grupoConflitoSelecionado >= state.gruposConflito.length) {
      return const Center(child: Text('Selecione um grupo de conflito à esquerda.'));
    }

    final grupo = state.gruposConflito[state.grupoConflitoSelecionado];
    final arquivos = List<Map<String, dynamic>>.from(grupo['arquivos'] ?? []);
    final isIdentical = grupo['tipo'] == 'identical';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              isIdentical ? Icons.verified_outlined : Icons.warning_amber_rounded,
              color: isIdentical ? const Color(0xFF107C41) : const Color(0xFFD83B01),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isIdentical
                    ? 'Comparação de Arquivos Duplicados (Conteúdo 100% Idêntico - SHA256)'
                    : 'Comparação de Arquivos com Mesmo Nome (Conteúdo Diferente)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  _organizarEMoverNaoDuplicados(context, state, notifier),
              icon: const Icon(Icons.drive_file_move_outlined, size: 14),
              label: const Text('Mover e Organizar Não Duplicados',
                  style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
        const Divider(color: Color(0xFF3F3F46), height: 20),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: arquivos.map((arq) {
                final caminho = arq['caminho'] as String? ?? '';
                final nome = arq['nome'] as String? ?? '';
                final tamanho = arq['tamanho'] as num? ?? 0;
                final modificado = arq['modificado'] as String? ?? '';
                final ext = p.extension(caminho).toLowerCase();

                final isImage = [
                  '.jpg',
                  '.jpeg',
                  '.png',
                  '.webp',
                  '.bmp',
                  '.gif'
                ].contains(ext);

                final isText = [
                  '.txt',
                  '.log',
                  '.json',
                  '.csv',
                  '.md',
                  '.xml'
                ].contains(ext);

                final isAudio = [
                  '.mp3',
                  '.wav',
                  '.flac',
                  '.aac',
                  '.m4a'
                ].contains(ext);

                final isVideo = [
                  '.mp4',
                  '.mkv',
                  '.avi',
                  '.mov',
                  '.wmv'
                ].contains(ext);

                final isExe = [
                  '.exe',
                  '.msi',
                  '.iso'
                ].contains(ext);

                final fileExists = File(caminho).existsSync();

                return Container(
                  width: 320,
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF3F3F46)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Prévia dinamicamente adaptada por tipo de arquivo
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF3F3F46)),
                          ),
                          child: _buildPreviewPorTipo(
                            caminho: caminho,
                            ext: ext,
                            isImage: isImage,
                            isText: isText,
                            isAudio: isAudio,
                            isVideo: isVideo,
                            isExe: isExe,
                            fileExists: fileExists,
                            arq: arq,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Informações do Arquivo
                        Text(
                          nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          caminho,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF888888),
                              fontFamily: 'Consolas'),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tamanho: ${(tamanho / 1024).toStringAsFixed(1)} KB',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFFCCCCCC)),
                            ),
                            Text(
                              modificado.length >= 10
                                  ? modificado.substring(0, 10)
                                  : modificado,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFFCCCCCC)),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF3F3F46), height: 16),

                        // Botões de Ação por Card
                        ElevatedButton.icon(
                          onPressed: () {
                            for (var outro in arquivos) {
                              final outCaminho = outro['caminho'] as String;
                              if (outCaminho != caminho) {
                                notifier.removerArquivoDoConflito(
                                    outCaminho, state.grupoConflitoSelecionado);
                              }
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Manter Este e Apagar Outros'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF107C41),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: () {
                            notifier.removerArquivoDoConflito(
                                caminho, state.grupoConflitoSelecionado);
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Excluir Este Arquivo'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        if (!isIdentical) ...[
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: () => _exibirDialogoRenomear(
                                context, caminho, state.grupoConflitoSelecionado),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Renomear'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0078D4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPorTipo({
    required String caminho,
    required String ext,
    required bool isImage,
    required bool isText,
    required bool isAudio,
    required bool isVideo,
    required bool isExe,
    required bool fileExists,
    required Map<String, dynamic> arq,
  }) {
    if (isImage && fileExists) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(caminho),
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, size: 40, color: Color(0xFF888888)),
          ),
        ),
      );
    } else if (isText && fileExists) {
      return FutureBuilder<String>(
        future: File(caminho)
            .readAsString()
            .then((s) => s.length > 800 ? '${s.substring(0, 800)}...' : s)
            .catchError((_) => 'Erro ao carregar prévia do texto.'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          return Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF111111),
            child: SingleChildScrollView(
              child: SelectableText(
                snapshot.data ?? 'Vazio',
                style: const TextStyle(
                  fontFamily: 'Consolas',
                  fontSize: 10,
                  color: Color(0xFF4EC9B0),
                ),
              ),
            ),
          );
        },
      );
    } else if (isAudio) {
      return AudioPreviewCard(
        key: ValueKey(caminho),
        caminhoArquivo: caminho,
        nomeArquivo: p.basename(caminho),
      );
    } else if (isVideo) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_outlined, size: 42, color: Color(0xFF0078D4)),
          const SizedBox(height: 6),
          Text(
            'Vídeo (${ext.toUpperCase()})',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Process.run('explorer.exe', [caminho]);
            },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Abrir no Player Padrão', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0078D4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      );
    } else if (isExe) {
      final fileVersion = arq['fileVersion'] as String? ?? '';
      final productName = arq['productName'] as String? ?? '';
      final companyName = arq['companyName'] as String? ?? '';

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.install_desktop, size: 40, color: Color(0xFF0078D4)),
            const SizedBox(height: 6),
            if (productName.isNotEmpty)
              Text(
                productName,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (companyName.isNotEmpty)
              Text(
                companyName,
                style: const TextStyle(fontSize: 10, color: Color(0xFFCCCCCC)),
                textAlign: TextAlign.center,
              ),
            if (fileVersion.isNotEmpty)
              Text(
                'Versão: $fileVersion',
                style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
              ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              size: 48, color: Color(0xFF0078D4)),
          const SizedBox(height: 8),
          Text(
            'Arquivo (${ext.isEmpty ? 'Sem Extensão' : ext.toUpperCase()})',
            style: const TextStyle(fontSize: 11, color: Color(0xFFCCCCCC)),
          ),
        ],
      );
    }
  }

  Widget _buildModuloEmDesenvolvimento(String nomeModulo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 48, color: Color(0xFF0078D4)),
          const SizedBox(height: 12),
          Text(
            'Módulo $nomeModulo em desenvolvimento',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use as opções de automação ou alterne para as abas operacionais.',
            style: TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
