import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/gsse_manifest.dart';
import '../providers/commander_provider.dart';
import '../services/gsse_packager_service.dart';

enum GsseCompilerMode { universal, batchPsDesKom }
enum CompilacaoStatusState { idle, processing, success, failure }

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

  GsseCompilerMode _compilerMode = GsseCompilerMode.universal;
  CompilacaoStatusState _statusState = CompilacaoStatusState.idle;

  // Controllers - Universal Mode
  late TextEditingController _appNameController;
  late TextEditingController _mainExeController;

  // Controllers - Directory Paths
  late TextEditingController _sourceDirController;
  late TextEditingController _outputDirController;

  // Controllers - Shared Metadata
  late TextEditingController _versionController;
  late TextEditingController _publisherController;

  String? _sourceDirPath;
  String? _outputDirPath;
  String? _customIconPath;

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

  double _progresso = 0.0;
  String _statusMensagem = '';
  String _detalheSucesso = '';
  String _ultimoOutputDir = '';
  String _detalheErro = '';
  final StringBuffer _logsErroCompilacao = StringBuffer();

  @override
  void initState() {
    super.initState();
    _appNameController = TextEditingController(text: '');
    _mainExeController = TextEditingController(text: '');
    _sourceDirController = TextEditingController(text: '');
    _outputDirController = TextEditingController(text: '');
    _versionController = TextEditingController(text: '1.0.0');
    _publisherController = TextEditingController(text: 'Gradle Studio');
    _sourceDirPath = null;
    _outputDirPath = null;
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _mainExeController.dispose();
    _sourceDirController.dispose();
    _outputDirController.dispose();
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

  Future<String?> _pickDirectorySafely(String title) async {
    try {
      final script =
          '[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null; \$dialog = New-Object System.Windows.Forms.FolderBrowserDialog; \$dialog.Description = "$title"; if (\$dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output \$dialog.SelectedPath }';
      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-WindowStyle', 'Hidden', '-Command', script],
      );
      if (result.exitCode == 0) {
        final output = (result.stdout as String).trim();
        return output.isNotEmpty ? output : null;
      }
    } catch (e) {
      debugPrint('Erro no seletor de pasta seguro: $e');
    }
    return null;
  }

  Future<void> _selecionarPastaOrigem() async {
    final l10n = AppLocalizations.of(context);
    final String title = l10n?.labelPastaOrigem ?? 'Selecionar Diretório de Origem';
    final String? path = await _pickDirectorySafely(title);

    if (path != null && path.trim().isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _sourceDirPath = path;
        _sourceDirController.text = path;
      });
    }
  }

  Future<void> _selecionarPastaSaida() async {
    final l10n = AppLocalizations.of(context);
    final String title = l10n?.labelPastaSaida ?? 'Selecionar Saída dos Instaladores';
    final String? path = await _pickDirectorySafely(title);

    if (path != null && path.trim().isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _outputDirPath = path;
        _outputDirController.text = path;
      });
    }
  }

  Future<void> _selecionarIconeCustomizado() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecionar Ícone do Instalador (.ico)',
        type: FileType.custom,
        allowedExtensions: ['ico'],
      );

      await Future.delayed(const Duration(milliseconds: 150));

      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        final selectedPath = result.files.first.path!;
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _customIconPath = selectedPath;
            });
          }
        });
      }
    } on PlatformException catch (pe) {
      debugPrint('Erro de plataforma Win32 no seletor de ícone: $pe');
    } catch (e) {
      debugPrint('Erro ao selecionar ícone .ico: $e');
    }
  }

  Future<void> _compilarInstaladorUniversal() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(commanderProvider.notifier);

    final String appName = _appNameController.text.trim().isNotEmpty ? _appNameController.text.trim() : 'Software Avulso';
    final String mainExe = _mainExeController.text.trim().isNotEmpty ? _mainExeController.text.trim() : 'app.exe';
    final String version = _versionController.text.trim().isNotEmpty ? _versionController.text.trim() : '1.0.0';
    final String publisher = _publisherController.text.trim().isNotEmpty ? _publisherController.text.trim() : 'Gradle Studio';
    final String sourceDirStr = _sourceDirController.text.trim().isNotEmpty
        ? _sourceDirController.text.trim()
        : (_sourceDirPath ?? File(Platform.resolvedExecutable).parent.path);
    final String outputDirStr = _outputDirController.text.trim().isNotEmpty
        ? _outputDirController.text.trim()
        : (_outputDirPath ?? p.join(File(Platform.resolvedExecutable).parent.path, 'dist', 'Installers'));

    final sourceDir = Directory(sourceDirStr);
    if (!await sourceDir.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diretório de origem não encontrado: $sourceDirStr'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _logsErroCompilacao.clear();
    setState(() {
      _statusState = CompilacaoStatusState.processing;
      _progresso = 0.05;
      _statusMensagem = 'Iniciando compilação do aplicativo avulso...';
    });

    notifier.adicionarLog('COMPILAÇÃO UNIVERSAL: $appName (v$version)');

    try {
      final String safeFolderName = appName.replaceAll(RegExp(r'[^\w\.-]'), '_');
      final outputDir = Directory(p.join(outputDirStr, '${safeFolderName}_v$version'));
      await outputDir.create(recursive: true);

      final outputFile = File(p.join(outputDir.path, 'Setup_${safeFolderName}_v$version.exe'));

      final manifest = GsseManifest(
        appName: appName,
        appEdition: 'UNIVERSAL',
        version: version,
        publisher: publisher,
        website: 'https://gradlestudio.com',
        defaultInstallDir: r'C:\Program Files\' + publisher + r'\' + appName,
        mainExecutable: mainExe,
        createDesktopShortcut: _createDesktopShortcut,
        createStartMenuShortcut: _createStartMenuShortcut,
        runAfterInstall: _runAfterInstall,
        iconPath: _customIconPath,
      );

      final packager = GssePackagerService();
      final resultFile = await packager.buildInstaller(
        sourceDir: sourceDir,
        outputFile: outputFile,
        manifest: manifest,
        onProgress: (mensagem, progress) {
          if (mounted) {
            setState(() {
              _statusMensagem = mensagem;
              _progresso = progress;
            });
          }
          _logsErroCompilacao.writeln('    $mensagem');
        },
      );

      final double totalMb = (await resultFile.length()) / (1024 * 1024);

      if (mounted) {
        setState(() {
          _statusState = CompilacaoStatusState.success;
          _progresso = 1.0;
          _statusMensagem = 'Instalador Universal gerado com sucesso!';
          _detalheSucesso = 'Gerado: ${p.basename(resultFile.path)} (${totalMb.toStringAsFixed(2)} MB)';
          _ultimoOutputDir = outputDir.path;
        });

        _exibirDialogoSucesso(l10n, resultFile.path, outputDir.path);
      }
    } catch (e, stack) {
      _logsErroCompilacao.writeln('ERRO NA COMPILAÇÃO UNIVERSAL: $e\n$stack');
      if (mounted) {
        setState(() {
          _statusState = CompilacaoStatusState.failure;
          _detalheErro = e.toString();
          _statusMensagem = 'Erro na compilação do instalador.';
        });
      }
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

    final String appDirFolder = File(Platform.resolvedExecutable).parent.path;
    final String rootOriginDir = _sourceDirController.text.trim().isNotEmpty
        ? _sourceDirController.text.trim()
        : (_sourceDirPath ?? p.join(appDirFolder, 'dist'));
    final String finalOutputDir = _outputDirController.text.trim().isNotEmpty
        ? _outputDirController.text.trim()
        : (_outputDirPath ?? p.join(appDirFolder, 'dist', 'Installers'));
    final String version = _versionController.text.trim().isNotEmpty ? _versionController.text.trim() : '1.0.0';
    final String publisher = _publisherController.text.trim().isNotEmpty ? _publisherController.text.trim() : 'Gradle Studio';

    _logsErroCompilacao.clear();
    setState(() {
      _statusState = CompilacaoStatusState.processing;
      _progresso = 0.0;
      _statusMensagem = l10n.msgCompilandoInstalador;
    });

    notifier.adicionarLog('COMPILAÇÃO EM LOTE: ${selectedEditions.length} edição(ões)');

    final packager = GssePackagerService();
    int concluidos = 0;
    int pulados = 0;

    for (int i = 0; i < selectedEditions.length; i++) {
      final edition = selectedEditions[i];
      final editionSourceDir = Directory(p.join(rootOriginDir, edition.folderName));

      _logsErroCompilacao.writeln('[${i + 1}/${selectedEditions.length}] Processando: ${edition.appName}');

      if (!await editionSourceDir.exists()) {
        _logsErroCompilacao.writeln('  [AVISO] Pasta "${edition.folderName}" não encontrada. Pulando...');
        pulados++;
        continue;
      }

      try {
        final editionOutputDir = Directory(p.join(finalOutputDir, '${edition.folderName}_v$version'));

        if (await editionOutputDir.exists()) {
          try {
            await Process.run('taskkill', ['/F', '/IM', 'Setup_${edition.folderName}_v$version.exe', '/T']);
          } catch (_) {}

          await Future.delayed(const Duration(milliseconds: 300));

          try {
            await editionOutputDir.delete(recursive: true);
          } catch (_) {}
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
          iconPath: _customIconPath,
        );

        final stubFile = File(p.join(appDirFolder, 'assets', 'tools', 'gs_stub.exe'));

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
            _logsErroCompilacao.writeln('    $mensagem');
          },
        );

        final double totalMb = (await resultFile.length()) / (1024 * 1024);
        _logsErroCompilacao.writeln('  [OK] ${resultFile.path} (${totalMb.toStringAsFixed(2)} MB)');
        concluidos++;
      } catch (e, stack) {
        _logsErroCompilacao.writeln('  [ERRO NA EDIÇÃO ${edition.label}] $e\n$stack');
      }
    }

    if (mounted) {
      if (concluidos > 0) {
        setState(() {
          _statusState = CompilacaoStatusState.success;
          _progresso = 1.0;
          _statusMensagem = 'Compilação em lote concluída com sucesso!';
          _detalheSucesso = '$concluidos instalador(es) gerado(s) ($pulados pulado(s)) em $finalOutputDir';
          _ultimoOutputDir = finalOutputDir;
        });

        _exibirDialogoSucesso(l10n, '$concluidos instalador(es) gerado(s)', finalOutputDir);
      } else {
        setState(() {
          _statusState = CompilacaoStatusState.failure;
          _detalheErro = 'Nenhum instalador foi gerado no lote.';
          _statusMensagem = 'Falha na compilação do lote.';
        });
      }
    }
  }

  void _exibirDialogoSucesso(AppLocalizations l10n, String detalhe, String finalOutputDir) {
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
              'Compilação finalizada com sucesso:\n$detalhe',
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

  Widget _buildProgressStatusCard() {
    switch (_statusState) {
      case CompilacaoStatusState.idle:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF252526),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF3F3F46)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF888888), size: 18),
              SizedBox(width: 10),
              Text(
                'Aguardando início da compilação do instalador...',
                style: TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ],
          ),
        );

      case CompilacaoStatusState.processing:
        final pctInt = (_progresso * 100).toInt().clamp(0, 100);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF252526),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF0078D4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0078D4)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Execução em andamento: $_statusMensagem ($pctInt%)',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$pctInt%',
                    style: const TextStyle(color: Color(0xFF0078D4), fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Consolas'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progresso,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF1E1E1E),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0078D4)),
                ),
              ),
            ],
          ),
        );

      case CompilacaoStatusState.success:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF107C41).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF107C41)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF107C41), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '✔ Instalador gerado com sucesso!',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final dir = _ultimoOutputDir;
                      if (dir.isNotEmpty) {
                        final Uri uri = Uri.directory(dir);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          Process.run('explorer.exe', [dir]);
                        }
                      }
                    },
                    icon: const Icon(Icons.folder_open, size: 14),
                    label: const Text('Abrir Pasta de Saída', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF107C41),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              if (_detalheSucesso.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _detalheSucesso,
                  style: const TextStyle(color: Color(0xFF4EC9B0), fontSize: 11, fontFamily: 'Consolas'),
                ),
              ],
            ],
          ),
        );

      case CompilacaoStatusState.failure:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFD83B01).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD83B01)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFD83B01), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Falha na compilação: $_detalheErro',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF161616),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFFD83B01)),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.bug_report_outlined, color: Color(0xFFD83B01), size: 22),
                              SizedBox(width: 8),
                              Text('Log Detalhado de Erro — NSIS/GSSE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: SizedBox(
                            width: 600,
                            height: 350,
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _logsErroCompilacao.isEmpty ? 'Nenhum detalhe adicional de erro disponível.' : _logsErroCompilacao.toString(),
                                style: const TextStyle(fontFamily: 'Consolas', fontSize: 11, color: Color(0xFFCCCCCC)),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Fechar', style: TextStyle(color: Color(0xFF888888))),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 14),
                    label: const Text('Ver Log Detalhado', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD83B01),
                      side: const BorderSide(color: Color(0xFFD83B01)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(commanderProvider);

    const String appEditionEnv = String.fromEnvironment('APP_EDITION', defaultValue: 'MASTER');
    final bool isMasterEdition = appEditionEnv == 'MASTER' || state.statusLicencaTexto.contains('Master');

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
                        'Compilador de instaladores nativos e gerador NSIS/GSSE para aplicações Windows Desktop',
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
            const SizedBox(height: 12),

            // Seletor de Modo Operacional (Universal vs Lote PS DesKom)
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<GsseCompilerMode>(
                    segments: [
                      const ButtonSegment<GsseCompilerMode>(
                        value: GsseCompilerMode.universal,
                        icon: Icon(Icons.apps_outlined, size: 16),
                        label: Text('Aplicativo Avulso (Universal)', style: TextStyle(fontSize: 12)),
                      ),
                      if (isMasterEdition)
                        const ButtonSegment<GsseCompilerMode>(
                          value: GsseCompilerMode.batchPsDesKom,
                          icon: Icon(Icons.inventory_2_outlined, size: 16),
                          label: Text('Ecossistema PS DesKom (Em Lote)', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                    selected: {_compilerMode},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _compilerMode = newSelection.first;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: const Color(0xFF252526),
                      selectedBackgroundColor: const Color(0xFF0078D4),
                      selectedForegroundColor: Colors.white,
                      foregroundColor: const Color(0xFFCCCCCC),
                      side: const BorderSide(color: Color(0xFF3F3F46)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- MODO UNIVERSAL (APLICATIVO AVULSO) ---
            if (_compilerMode == GsseCompilerMode.universal) ...[
              // Card: Informações da Aplicação Avulsa
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
                    const Row(
                      children: [
                        Icon(Icons.widgets_outlined, color: Color(0xFF0078D4), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Informações do Aplicativo:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nome da Aplicação *:', style: TextStyle(fontSize: 11, color: Color(0xFFCCCCCC))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _appNameController,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  hintText: 'Ex: Meu Software',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Executável Principal (.exe) *:', style: TextStyle(fontSize: 11, color: Color(0xFFCCCCCC))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _mainExeController,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Consolas'),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  hintText: 'Ex: app.exe',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Card: Seletor de Ícone Customizado (.ico)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF252526),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF3F3F46)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, color: Color(0xFF4EC9B0), size: 16),
                    const SizedBox(width: 8),
                    const Text('Ícone do Instalador (.ico):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _customIconPath != null ? p.basename(_customIconPath!) : 'Ícone Padrão da Gradle Studio (app_icon.ico)',
                        style: TextStyle(
                          fontSize: 11,
                          color: _customIconPath != null ? const Color(0xFF4EC9B0) : const Color(0xFF888888),
                          fontFamily: 'Consolas',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _selecionarIconeCustomizado,
                      icon: const Icon(Icons.file_upload_outlined, size: 14),
                      label: const Text('Selecionar .ico', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D2D2D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Card: Diretório de Origem Raiz
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
                        _compilerMode == GsseCompilerMode.universal
                            ? 'Diretório de Origem dos Arquivos do App (Release) *:'
                            : 'Diretório de Origem Raiz (dist) *:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sourceDirController,
                          onChanged: (val) {
                            _sourceDirPath = val.trim().isNotEmpty ? val.trim() : null;
                          },
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Consolas'),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            hintText: 'Digite, cole ou selecione a pasta de origem (Release)... *',
                            hintStyle: TextStyle(color: Color(0xFF888888), fontSize: 11),
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

            // --- MODO ECOSSISTEMA PS DESKOM (EM LOTE) ---
            if (_compilerMode == GsseCompilerMode.batchPsDesKom) ...[
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
            ],

            // Card: Linha de Metadados (Versão e Publisher)
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

            // Card: Diretório de Saída dos Instaladores Gerados
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
                  Text('${l10n.labelPastaSaida} *', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _outputDirController,
                          onChanged: (val) {
                            _outputDirPath = val.trim().isNotEmpty ? val.trim() : null;
                          },
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Consolas'),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            hintText: 'Digite, cole ou selecione o diretório de destino... *',
                            hintStyle: TextStyle(color: Color(0xFF888888), fontSize: 11),
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

            // Card Visual de Progresso e Status
            _buildProgressStatusCard(),
            const SizedBox(height: 12),

            // Botão Principal de Ação
            ListenableBuilder(
              listenable: Listenable.merge([
                _appNameController,
                _mainExeController,
                _sourceDirController,
                _outputDirController,
              ]),
              builder: (context, _) {
                final bool isSourceValid = _sourceDirController.text.trim().isNotEmpty ||
                    (_sourceDirPath != null && _sourceDirPath!.trim().isNotEmpty);
                final bool isOutputValid = _outputDirController.text.trim().isNotEmpty ||
                    (_outputDirPath != null && _outputDirPath!.trim().isNotEmpty);

                final bool isUniversalValid = _appNameController.text.trim().isNotEmpty &&
                    _mainExeController.text.trim().isNotEmpty &&
                    isSourceValid &&
                    isOutputValid;

                final bool isBatchValid = _editions.any((e) => e.selected) && isSourceValid && isOutputValid;

                final bool canCompile = _statusState != CompilacaoStatusState.processing &&
                    (_compilerMode == GsseCompilerMode.universal ? isUniversalValid : isBatchValid);

                return ElevatedButton.icon(
                  onPressed: canCompile
                      ? (_compilerMode == GsseCompilerMode.universal
                          ? _compilarInstaladorUniversal
                          : _compilarInstaladoresLote)
                      : null,
                  icon: const Icon(Icons.build_circle_outlined, size: 18),
                  label: Text(
                    l10n.btnCompilarSelecionados,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D4),
                    disabledBackgroundColor: const Color(0xFF333333),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
