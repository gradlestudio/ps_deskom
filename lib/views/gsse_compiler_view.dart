import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/gsse_manifest.dart';
import '../providers/commander_provider.dart';
import '../services/gsse_packager_service.dart';

class _EditionItem {
  final String label;
  final String folderName;
  final String appName;
  bool selected;

  _EditionItem({
    required this.label,
    required this.folderName,
    required this.appName,
    this.selected = false,
  });
}

class GsseCompilerView extends ConsumerStatefulWidget {
  const GsseCompilerView({super.key});

  @override
  ConsumerState<GsseCompilerView> createState() => _GsseCompilerViewState();
}

class _GsseCompilerViewState extends ConsumerState<GsseCompilerView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _versionController;
  late TextEditingController _publisherController;

  String? _sourceDirPath;
  String? _outputDirPath;

  bool _selectAll = false;
  final List<_EditionItem> _editions = [
    _EditionItem(label: 'Master', folderName: 'PS_DesKom_Master', appName: 'PS DesKom Master', selected: false),
    _EditionItem(label: 'Basic', folderName: 'PS_DesKom_Basic', appName: 'PS DesKom Basic', selected: false),
    _EditionItem(label: 'Pro', folderName: 'PS_DesKom_Pro', appName: 'PS DesKom Pro', selected: false),
    _EditionItem(label: 'Max', folderName: 'PS_DesKom_Max', appName: 'PS DesKom Max', selected: false),
    _EditionItem(label: 'Dev Basic', folderName: 'PS_DesKom_Dev_Basic', appName: 'PS DesKom Dev Basic', selected: false),
    _EditionItem(label: 'Dev Pro', folderName: 'PS_DesKom_Dev_Pro', appName: 'PS DesKom Dev Pro', selected: false),
    _EditionItem(label: 'Dev Max', folderName: 'PS_DesKom_Dev_Max', appName: 'PS DesKom Dev Max', selected: false),
    _EditionItem(label: 'Dev PJ', folderName: 'PS_DesKom_Dev_PJ', appName: 'PS DesKom Dev PJ', selected: false),
  ];

  bool _createDesktopShortcut = true;
  bool _createStartMenuShortcut = true;
  bool _runAfterInstall = true;

  bool _isCompilando = false;
  double _progresso = 0.0;
  String _statusMensagem = '';

  @override
  void initState() {
    super.initState();
    _versionController = TextEditingController(text: '1.0.0');
    _publisherController = TextEditingController(text: 'Gradle Studio');
    _sourceDirPath = p.join(Directory.current.path, 'dist');
    _outputDirPath = p.join(Directory.current.path, 'dist', 'Installers');
  }

  @override
  void dispose() {
    _versionController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  void _toggleSelectAll(bool? val) {
    final newValue = val ?? false;
    setState(() {
      _selectAll = newValue;
      for (var ed in _editions) {
        ed.selected = newValue;
      }
    });
  }

  Future<void> _selecionarPastaOrigem() async {
    final l10n = AppLocalizations.of(context);
    try {
      final String? path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: l10n?.labelPastaOrigem ?? 'Selecionar Origem Raiz (dist)',
      );

      if (path != null && path.trim().isNotEmpty) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;

        setState(() {
          _sourceDirPath = path;
        });
      }
    } catch (e, stack) {
      debugPrint('Erro ao abrir seletor nativo de origem: $e\n$stack');
    }
  }

  Future<void> _selecionarPastaSaida() async {
    final l10n = AppLocalizations.of(context);
    try {
      final String? path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: l10n?.labelPastaSaida ?? 'Selecionar Saída dos Instaladores',
      );

      if (path != null && path.trim().isNotEmpty) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;

        setState(() {
          _outputDirPath = path;
        });
      }
    } catch (e, stack) {
      debugPrint('Erro ao abrir seletor nativo de saída: $e\n$stack');
    }
  }

  Future<void> _compilarInstaladoresLote() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(commanderProvider.notifier);

    final selectedEditions = _editions.where((e) => e.selected).toList();

    if (selectedEditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione pelo menos uma edição para compilar.'),
          backgroundColor: Colors.amber[800],
        ),
      );
      return;
    }

    final String rootOriginDir = _sourceDirPath ?? p.join(Directory.current.path, 'dist');
    final String finalOutputDir = _outputDirPath ?? p.join(Directory.current.path, 'dist', 'Installers');
    final String version = _versionController.text.trim().isNotEmpty ? _versionController.text.trim() : '1.0.0';
    final String publisher = _publisherController.text.trim().isNotEmpty ? _publisherController.text.trim() : 'Gradle Studio';

    setState(() {
      _isCompilando = true;
      _progresso = 0.0;
      _statusMensagem = l10n.msgCompilandoInstalador;
    });

    notifier.adicionarLog('===========================================================');
    notifier.adicionarLog('  ${l10n.tituloCompiladorGsse} (BATCH BUILD)');
    notifier.adicionarLog('===========================================================');
    notifier.adicionarLog('  • Edições Selecionadas: ${selectedEditions.length} item(ns)');
    notifier.adicionarLog('  • Versão:      v$version');
    notifier.adicionarLog('  • Publisher:   $publisher');
    notifier.adicionarLog('  • Origem Raiz: $rootOriginDir');
    notifier.adicionarLog('  • Destino:     $finalOutputDir');

    final packager = GssePackagerService();
    int concluidos = 0;
    int pulados = 0;

    for (int i = 0; i < selectedEditions.length; i++) {
      final edition = selectedEditions[i];
      final editionSourceDir = Directory(p.join(rootOriginDir, edition.folderName));

      notifier.adicionarLog('-----------------------------------------------------------');
      notifier.adicionarLog('  [${i + 1}/${selectedEditions.length}] Processando: ${edition.appName}');

      if (!await editionSourceDir.exists()) {
        notifier.adicionarLog('  [AVISO] Pasta da edição "${edition.folderName}" não encontrada em "$rootOriginDir". Pulando...');
        pulados++;
        continue;
      }

      try {
        final editionOutputDir = Directory(p.join(finalOutputDir, '${edition.folderName}_v$version'));

        if (await editionOutputDir.exists()) {
          notifier.adicionarLog('  [INFO] Localizada pasta anterior em "${editionOutputDir.path}". Limpando processos residuais do instalador...');
          try {
            await Process.run('taskkill', ['/F', '/IM', 'Setup_${edition.folderName}_v$version.exe', '/T']);
          } catch (_) {}

          await Future.delayed(const Duration(milliseconds: 300));

          try {
            await editionOutputDir.delete(recursive: true);
          } catch (err) {
            notifier.adicionarLog('  [AVISO] Remoção da pasta anterior atenuada: $err');
          }
        }

        await editionOutputDir.create(recursive: true);

        final outputFile = File(p.join(editionOutputDir.path, 'Setup_${edition.folderName}_v$version.exe'));

        final manifest = GsseManifest(
          appName: edition.appName,
          appEdition: edition.label,
          version: version,
          publisher: publisher,
          website: 'https://gradlestudio.com',
          defaultInstallDir: r'C:\Program Files\Gradle Studio\' + edition.appName,
          mainExecutable: 'ps_deskom.exe',
          createDesktopShortcut: _createDesktopShortcut,
          createStartMenuShortcut: _createStartMenuShortcut,
          runAfterInstall: _runAfterInstall,
        );

        final stubFile = File(p.join(Directory.current.path, 'assets', 'tools', 'gs_stub.exe'));

        final resultFile = await packager.buildInstaller(
          sourceDir: editionSourceDir,
          stubExecutable: stubFile,
          outputFile: outputFile,
          manifest: manifest,
          onProgress: (mensagem, stepProgress) {
            final overallProgress = (i + stepProgress) / selectedEditions.length;
            if (mounted) {
              setState(() {
                _statusMensagem = '[${edition.label}] $mensagem';
                _progresso = overallProgress.clamp(0.0, 1.0);
              });
            }
            notifier.adicionarLog('    $mensagem');
          },
        );

        final double totalMb = (await resultFile.length()) / (1024 * 1024);
        notifier.adicionarLog('  [OK] Gerado com sucesso: ${resultFile.path} (${totalMb.toStringAsFixed(2)} MB)');
        concluidos++;
      } catch (e, stack) {
        notifier.adicionarLog('  [ERRO NA EDIÇÃO ${edition.label}] $e');
        notifier.adicionarLog('  $stack');
      }
    }

    notifier.adicionarLog('===========================================================');
    notifier.adicionarLog('  [LOTE CONCLUÍDO] $concluidos executável(is) gerado(s), $pulados pulado(s).');
    notifier.adicionarLog('===========================================================');

    if (mounted) {
      setState(() {
        _isCompilando = false;
        _progresso = 1.0;
        _statusMensagem = 'Compilação em lote concluída com sucesso!';
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF161616),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF107C41)),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF107C41), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.msgInstaladorSucesso,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lote finalizado:\n$concluidos instalador(es) gerado(s) na pasta de saída.',
                style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
              ),
              const SizedBox(height: 10),
              Text(
                'Destino: $finalOutputDir',
                style: const TextStyle(color: Color(0xFF4EC9B0), fontSize: 12, fontFamily: 'Consolas'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.fechar, style: const TextStyle(color: Color(0xFF888888))),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final Uri uri = Uri.directory(finalOutputDir);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  Process.run('explorer.exe', [finalOutputDir]);
                }
              },
              icon: const Icon(Icons.folder_open, size: 16),
              label: Text(l10n.btnAbrirPasta),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF107C41),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho da View
            Row(
              children: [
                const Icon(Icons.construction_outlined, color: Color(0xFF0078D4), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tituloCompiladorGsse,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Compilador em lote de instaladores autônomos (Engine NSIS / GSSE) — Edição Master',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFF3F3F46), height: 1),
            const SizedBox(height: 10),

            // Card 1: Diretório de Origem Raiz (dist)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252526),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder_special, color: Color(0xFF0078D4), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Diretório de Origem Raiz (dist):',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF3F3F46)),
                          ),
                          child: Text(
                            _sourceDirPath ?? p.join(Directory.current.path, 'dist'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Consolas',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _selecionarPastaOrigem,
                        icon: const Icon(Icons.folder_open, size: 14),
                        label: Text(l10n.btnSelecionarOrigem, style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D2D2D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Card 2: Grade de Seleção de Versões (Checkboxes)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252526),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checklist_rtl_outlined, color: Color(0xFF4EC9B0), size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Edições do PS DesKom para Compilar:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC)),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _toggleSelectAll(!_selectAll),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: _selectAll,
                                activeColor: const Color(0xFF0078D4),
                                onChanged: _toggleSelectAll,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.selecionarTodasEdicoes,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF4EC9B0), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: _editions.map((edition) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            edition.selected = !edition.selected;
                            _selectAll = _editions.every((e) => e.selected);
                          });
                        },
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: edition.selected ? const Color(0xFF0078D4).withValues(alpha: 0.15) : const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: edition.selected ? const Color(0xFF0078D4) : const Color(0xFF3F3F46),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: edition.selected,
                                  activeColor: const Color(0xFF0078D4),
                                  onChanged: (val) {
                                    setState(() {
                                      edition.selected = val ?? false;
                                      _selectAll = _editions.every((e) => e.selected);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  edition.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: edition.selected ? Colors.white : const Color(0xFFCCCCCC),
                                    fontWeight: edition.selected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Card 3: Linha de Metadados Lado a Lado (Versão e Publisher)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252526),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.labelVersaoSoftware, style: const TextStyle(fontSize: 11, color: Color(0xFFCCCCCC))),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _versionController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            hintText: l10n.hintVersaoSoftware,
                            hintStyle: const TextStyle(color: Colors.white38),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.labelDesenvolvedorSoftware, style: const TextStyle(fontSize: 11, color: Color(0xFFCCCCCC))),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _publisherController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            hintText: l10n.hintDesenvolvedorSoftware,
                            hintStyle: const TextStyle(color: Colors.white38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Card 4: Diretório de Saída dos Instaladores Gerados
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252526),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.labelPastaSaida, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF3F3F46)),
                          ),
                          child: Text(
                            _outputDirPath ?? p.join(Directory.current.path, 'dist', 'Installers'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Consolas',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _selecionarPastaSaida,
                        icon: const Icon(Icons.folder_special_outlined, size: 14),
                        label: Text(l10n.btnSelecionarSaida, style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D2D2D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Checkboxes de Opções de Instalação Alinhadas
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _createDesktopShortcut = !_createDesktopShortcut),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: _createDesktopShortcut,
                                activeColor: const Color(0xFF0078D4),
                                onChanged: (val) => setState(() => _createDesktopShortcut = val ?? true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.optAtalhoDesktop, style: const TextStyle(fontSize: 11, color: Colors.white)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _createStartMenuShortcut = !_createStartMenuShortcut),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: _createStartMenuShortcut,
                                activeColor: const Color(0xFF0078D4),
                                onChanged: (val) => setState(() => _createStartMenuShortcut = val ?? true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.optAtalhoMenuIniciar, style: const TextStyle(fontSize: 11, color: Colors.white)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _runAfterInstall = !_runAfterInstall),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: _runAfterInstall,
                                activeColor: const Color(0xFF0078D4),
                                onChanged: (val) => setState(() => _runAfterInstall = val ?? true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.optExecutarAposInstalar, style: const TextStyle(fontSize: 11, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Barra de Progresso durante a compilação
            if (_isCompilando) ...[
              LinearProgressIndicator(
                value: _progresso,
                backgroundColor: const Color(0xFF2D2D2D),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0078D4)),
              ),
              const SizedBox(height: 6),
              Text(
                _statusMensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF4EC9B0), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ],

            // Botão Principal de Ação
            ElevatedButton.icon(
              onPressed: _isCompilando ? null : _compilarInstaladoresLote,
              icon: const Icon(Icons.build_circle_outlined, size: 18),
              label: Text(
                l10n.btnCompilarSelecionados,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
