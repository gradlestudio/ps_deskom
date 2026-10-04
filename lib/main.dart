import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'providers/commander_provider.dart';
import 'providers/locale_provider.dart';
import 'views/bot_control_dialog.dart';
import 'views/gsse_compiler_view.dart';
import 'views/local_ai_view.dart';
import 'views/welcome_view.dart';
import 'widgets/about_dialog_widget.dart';
import 'widgets/audio_preview_card.dart';
import 'widgets/connect_ai_dialog.dart';
import 'widgets/google_drive_dialog.dart';
import 'widgets/google_login_dialog.dart';
import 'widgets/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1024, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: 'PS DesKom',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: PSDesKomApp()));
}

class ImageZoomDialog extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ImageZoomDialog({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<ImageZoomDialog> createState() => _ImageZoomDialogState();
}

class _ImageZoomDialogState extends State<ImageZoomDialog> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _proxima() {
    if (_currentIndex < widget.imagePaths.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _anterior() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return const Dialog(child: SizedBox.shrink());
    }

    final currentPath = widget.imagePaths[_currentIndex];
    final fileName = p.basename(currentPath);

    return Dialog(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Área Central de Imagem com Zoom e Pan
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                File(currentPath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                ),
              ),
            ),
          ),

          // Botão Fechar
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Fechar',
              ),
            ),
          ),

          // Seta de Navegação Esquerda
          if (widget.imagePaths.length > 1 && _currentIndex > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: _anterior,
                    tooltip: 'Imagem Anterior',
                  ),
                ),
              ),
            ),

          // Seta de Navegação Direita
          if (widget.imagePaths.length > 1 && _currentIndex < widget.imagePaths.length - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: _proxima,
                    tooltip: 'Próxima Imagem',
                  ),
                ),
              ),
            ),

          // Barra Informativa Inferior
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3F3F46)),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.imagePaths.length} — $fileName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PSDesKomApp extends ConsumerWidget {
  const PSDesKomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'PS DesKom',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
      home: const AppRootWrapper(),
    );
  }
}

class AppRootWrapper extends StatefulWidget {
  const AppRootWrapper({super.key});

  @override
  State<AppRootWrapper> createState() => _AppRootWrapperState();
}

class _AppRootWrapperState extends State<AppRootWrapper> {
  bool? _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('has_completed_onboarding') ?? false;
    setState(() {
      _hasCompletedOnboarding = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCompletedOnboarding == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1117),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0078D4)),
        ),
      );
    }

    if (_hasCompletedOnboarding == true) {
      return const HomeScreen();
    } else {
      return const WelcomeView();
    }
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
  final TextEditingController _zipNameController = TextEditingController(text: 'Arquivo_Compactado.zip');

  @override
  void dispose() {
    _scrollController.dispose();
    _extController.dispose();
    _pastaController.dispose();
    _zipNameController.dispose();
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

  // Descompactar / Compactar
  Future<void> _adicionarArquivos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      final paths = result.paths.whereType<String>().toList();
      ref.read(commanderProvider.notifier).adicionarArquivos(paths);
    }
  }

  Future<void> _adicionarPastaOrigem() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).adicionarArquivos([selectedDirectory]);
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

  // Google Drive Flexível com Navegação em Subpastas
  Future<void> _selecionarOrigemGoogleDrive(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) async {
    String? drivePath = state.caminhoGoogleDriveDetectado;
    if (drivePath == null || drivePath.isEmpty || !Directory(drivePath).existsSync()) {
      await notifier.verificarGoogleDrive();
      drivePath = ref.read(commanderProvider).caminhoGoogleDriveDetectado;
    }

    if (drivePath != null && drivePath.isNotEmpty && Directory(drivePath).existsSync()) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        initialDirectory: drivePath,
        dialogTitle: 'Selecionar pasta do Google Drive (Origem)',
      );
      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        if (state.moduloSelecionado == 1) {
          notifier.adicionarItensCopiar([selectedDirectory]);
        } else if (state.moduloSelecionado == 2) {
          notifier.adicionarItensMover([selectedDirectory]);
        } else if (state.moduloSelecionado == 0) {
          notifier.adicionarArquivos([selectedDirectory]);
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => const GoogleDriveDialog(),
        );
      }
    }
  }

  Future<void> _selecionarDestinoGoogleDrive(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) async {
    String? drivePath = state.caminhoGoogleDriveDetectado;
    if (drivePath == null || drivePath.isEmpty || !Directory(drivePath).existsSync()) {
      await notifier.verificarGoogleDrive();
      drivePath = ref.read(commanderProvider).caminhoGoogleDriveDetectado;
    }

    if (drivePath != null && drivePath.isNotEmpty && Directory(drivePath).existsSync()) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        initialDirectory: drivePath,
        dialogTitle: 'Selecionar pasta do Google Drive (Destino)',
      );
      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        if (state.moduloSelecionado == 0) {
          notifier.setDiretorioDestino(selectedDirectory);
        } else if (state.moduloSelecionado == 1) {
          notifier.setDestinoCopiar(selectedDirectory);
        } else if (state.moduloSelecionado == 2) {
          notifier.setDestinoMover(selectedDirectory);
        } else if (state.moduloSelecionado == 3) {
          notifier.setDiretorioOrganizar(selectedDirectory);
        } else if (state.moduloSelecionado == 4) {
          notifier.adicionarSearchPath(selectedDirectory);
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => const GoogleDriveDialog(),
        );
      }
    }
  }

  // Procurar / Duplicados
  Future<void> _selecionarDiretorioBusca() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(commanderProvider.notifier).adicionarSearchPath(selectedDirectory);
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
    final l10n = AppLocalizations.of(context);

    ref.listen<Locale>(localeProvider, (previous, next) {
      if (previous != next && l10n != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.inicializarLogsComL10n(l10n);
        });
      }
    });

    if (state.logsTerminal.isEmpty && l10n != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.inicializarLogsComL10n(l10n);
      });
    }

    const String appEditionEnv = String.fromEnvironment('APP_EDITION', defaultValue: '');
    final bool showGsseTab = appEditionEnv == 'MASTER' ||
        appEditionEnv.startsWith('DEV') ||
        state.statusLicencaTexto.contains('Master') ||
        state.statusLicencaTexto.contains('Dev');

    final List<String> modulos = [
      l10n?.descompactar ?? 'DESCOMPACTAR',
      l10n?.compactar ?? 'COMPACTAR',
      l10n?.copiar ?? 'COPIAR',
      l10n?.mover ?? 'MOVER',
      l10n?.organizar ?? 'ORGANIZAR',
      l10n?.procurar ?? 'PROCURAR',
      if (showGsseTab) l10n?.abaCompilarInstalador ?? 'COMPILAR INSTALADOR',
      if (showGsseTab) l10n?.iaLocal ?? 'IA LOCAL',
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
                          '${l10n?.atualizacaoDisponivel ?? 'Atualização Disponível'} (v${state.dadosNovaVersao!['versao_recente']})',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF4EC9B0)),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF107C41),
                          side: const BorderSide(color: Color(0xFF107C41)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Seletor Rápido de Idioma
                    PopupMenuButton<Locale>(
                      tooltip: 'Alterar Idioma / Change Language / Cambiar Idioma / Cambia Lingua / Changer de Langue / Sprache Ändern',
                      color: const Color(0xFF2D2D2D),
                      offset: const Offset(0, 40),
                      onSelected: (newLocale) {
                        ref.read(localeProvider.notifier).setLocale(newLocale);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: const Locale('pt', 'BR'),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.asset('assets/flags/br.gif',
                                    width: 22, height: 15, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              const Text('Português (BR)',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('en', 'US'),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.asset('assets/flags/uk.gif',
                                    width: 22, height: 15, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              const Text('English (US)',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('de', 'DE'),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.asset('assets/flags/de.gif',
                                    width: 22, height: 15, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              const Text('Deutsch (DE)',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('es', 'ES'),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.asset('assets/flags/es.gif',
                                    width: 22, height: 15, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              const Text('Español (ES)',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('fr', 'FR'),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.asset('assets/flags/fr.gif',
                                    width: 22, height: 15, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              const Text('Français (FR)',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('it', 'IT'),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.asset('assets/flags/it.gif',
                                    width: 22, height: 15, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              const Text('Italiano (IT)',
                                  style: TextStyle(fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF3F3F46)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.asset(
                                ref.watch(localeProvider).languageCode == 'en'
                                    ? 'assets/flags/uk.gif'
                                    : ref.watch(localeProvider).languageCode == 'de'
                                        ? 'assets/flags/de.gif'
                                        : ref.watch(localeProvider).languageCode == 'es'
                                            ? 'assets/flags/es.gif'
                                            : ref.watch(localeProvider).languageCode == 'fr'
                                                ? 'assets/flags/fr.gif'
                                                : ref.watch(localeProvider).languageCode == 'it'
                                                    ? 'assets/flags/it.gif'
                                                    : 'assets/flags/br.gif',
                                width: 20,
                                height: 14,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ref.watch(localeProvider).languageCode.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFFCCCCCC)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.explore_outlined, size: 20, color: Color(0xFF4EC9B0)),
                      tooltip: l10n?.bemVindoTitulo ?? 'Boas-Vindas / Welcome',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WelcomeView()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.account_circle_outlined, size: 20, color: Color(0xFF4EC9B0)),
                      tooltip: l10n?.entrarComGoogle ?? 'Entrar com Google',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const GoogleLoginDialog(),
                        );
                      },
                    ),
                    if (showGsseTab) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.cloud_sync_outlined, size: 20, color: Color(0xFF0078D4)),
                        tooltip: l10n?.modalConectarIa ?? 'Conectar IA',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const ConnectAiDialog(),
                          );
                        },
                      ),
                    ],
                    if (const String.fromEnvironment('APP_EDITION', defaultValue: '') == 'MASTER' ||
                        state.statusLicencaTexto.contains('Master')) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.smart_toy_outlined, size: 20, color: Color(0xFF0078D4)),
                        tooltip: 'Gerenciador Grad Bot (PM2)',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const BotControlDialog(),
                          );
                        },
                      ),
                    ],
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => notifier.limparTerminal(),
                      icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                      label: Text(l10n?.limparConsole ?? 'Limpar Console'),
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
                      label: Text(l10n?.sobre ?? 'Sobre'),
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
                            : (l10n?.aguardandoAcao ?? 'Aguardando ação do usuário...'),
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
                        label: Text(
                          l10n?.descompactarAgora ?? 'DESCOMPACTAR AGORA',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        label: Text(
                          l10n?.iniciarCopia ?? 'INICIAR CÓPIA',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        label: Text(
                          l10n?.moverArquivos ?? 'MOVER ARQUIVOS',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        label: Text(
                          l10n?.organizarPasta ?? 'ORGANIZAR PASTA',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                              label: Text(
                                l10n?.interromperBusca ?? 'INTERROMPER BUSCA',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: (state.searchPaths.isNotEmpty && !state.isLoading)
                                  ? () {
                                      if (state.searchMode == SearchMode.duplicates) {
                                        notifier.dispararVarreduraDuplicados();
                                      } else {
                                        notifier.dispararBuscaArquivos();
                                      }
                                    }
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
                                  : Icon(
                                      state.searchMode == SearchMode.duplicates
                                          ? Icons.search_outlined
                                          : Icons.find_in_page_outlined,
                                      size: 20),
                              label: Text(
                                state.searchMode == SearchMode.duplicates
                                    ? (l10n?.escanearDuplicados ?? 'ESCANEAR DUPLICADOS')
                                    : (l10n?.localizarArquivos ?? 'LOCALIZAR ARQUIVOS'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                        state.getFormattedLogs(l10n).isEmpty
                            ? (l10n?.terminalPronto ?? 'Terminal pronto. Módulo operacional pronto.')
                            : state.getFormattedLogs(l10n),
                        style: TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 12,
                          color: state.getFormattedLogs(l10n).isEmpty
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
        return _buildModuloCompactar(context, state, notifier);
      case 2:
        return _buildModuloCopiar(context, state, notifier);
      case 3:
        return _buildModuloMover(context, state, notifier);
      case 4:
        return _buildModuloOrganizar(context, state, notifier);
      case 5:
        return _buildModuloProcurar(context, state, notifier);
      case 6:
        return const GsseCompilerView();
      case 7:
        return const LocalAiView();
      default:
        return _buildModuloEmDesenvolvimento(modulos[state.moduloSelecionado]);
    }
  }

  Widget _buildModuloDescompactar(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ORIGEM DOS ARQUIVOS
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
                            '${l10n?.origem ?? 'ORIGEM'} [${state.arquivosOrigem.length}]',
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
                        label: Text(l10n?.adicionarArquivos ?? '(+) Adicionar Arquivos'),
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
                              children: [
                                const Icon(Icons.archive_outlined,
                                    size: 40, color: Color(0xFF555555)),
                                const SizedBox(height: 8),
                                Text(
                                  l10n?.nenhumArquivoDescompactar ??
                                      "Nenhum arquivo adicionado à fila.\nClique em '(+) Adicionar Arquivos' (.zip, .rar, .7z)",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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

        // DESTINO DAS PASTAS
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
                          const Icon(Icons.folder_open,
                              color: Color(0xFF0078D4), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.destino ?? 'DESTINO',
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
                          OutlinedButton.icon(
                            onPressed: _selecionarPastaDestino,
                            icon: const Icon(Icons.create_new_folder_outlined, size: 16),
                            label: Text(l10n?.selecionarPasta ?? 'Selecionar Pasta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0078D4),
                              side: const BorderSide(color: Color(0xFF0078D4)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _selecionarDestinoGoogleDrive(context, state, notifier),
                            icon: const Icon(Icons.cloud_queue, size: 16),
                            label: Text(l10n?.googleDrive ?? 'Google Drive'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4EC9B0),
                              side: const BorderSide(color: Color(0xFF4EC9B0)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n?.caminhoDestino ?? 'Caminho de Destino:',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF888888)),
                            ),
                            if (state.diretorioDestino != null &&
                                state.diretorioDestino!.isNotEmpty)
                              Tooltip(
                                message: l10n?.limparDestino ?? 'Limpar destino',
                                child: InkWell(
                                  onTap: () => notifier.setDiretorioDestino(null),
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.close,
                                        color: Colors.redAccent, size: 16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          (state.diretorioDestino != null && state.diretorioDestino!.isNotEmpty)
                              ? state.diretorioDestino!
                              : (l10n?.nenhumDiretorioSelecionado ?? 'Nenhum diretório selecionado. Clique em "Selecionar Pasta".'),
                          style: TextStyle(
                            fontSize: 13,
                            color: (state.diretorioDestino != null && state.diretorioDestino!.isNotEmpty)
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
                        Expanded(
                          child: Text(
                            l10n?.criarSubpastaExtracao ?? 'Criar pasta com o nome do arquivo para cada extração',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
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

  Widget _buildModuloCompactar(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ORIGEM DOS ARQUIVOS PARA COMPACTAR
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
                          const Icon(Icons.archive_outlined,
                              color: Color(0xFF0078D4), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n?.origem ?? 'ORIGEM'} [${state.arquivosOrigem.length}]',
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
                            onPressed: _adicionarArquivos,
                            icon: const Icon(Icons.add, size: 16),
                            label: Text(l10n?.adicionarArquivos ?? '(+) Arquivos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0078D4),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: _adicionarPastaOrigem,
                            icon: const Icon(Icons.folder_open, size: 16),
                            label: Text(l10n?.adicionarPasta ?? '(+) Pasta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D2D2D),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: state.arquivosOrigem.isEmpty
                          ? Center(
                              child: Text(
                                l10n?.nenhumArquivoLocalizado ?? 'Nenhum arquivo ou pasta selecionado.',
                                style: const TextStyle(color: Color(0xFF888888)),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.arquivosOrigem.length,
                              itemBuilder: (context, index) {
                                final filePath = state.arquivosOrigem[index];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.insert_drive_file_outlined,
                                      size: 18, color: Color(0xFFCCCCCC)),
                                  title: Text(
                                    p.basename(filePath),
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
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
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // DESTINO DO ARQUIVO COMPACTADO (.ZIP)
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
                          const Icon(Icons.folder_outlined,
                              color: Color(0xFF107C41), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.destino ?? 'DESTINO',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _selecionarPastaDestino,
                        icon: const Icon(Icons.folder_open, size: 16),
                        label: Text(l10n?.selecionarPasta ?? 'Selecionar Pasta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF107C41),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          (state.diretorioDestino != null && state.diretorioDestino!.isNotEmpty)
                              ? state.diretorioDestino!
                              : (l10n?.nenhumDiretorioSelecionado ?? 'Nenhum diretório selecionado. Clique em "Selecionar Pasta".'),
                          style: TextStyle(
                            fontSize: 13,
                            color: (state.diretorioDestino != null && state.diretorioDestino!.isNotEmpty)
                                ? const Color(0xFF4EC9B0)
                                : const Color(0xFF888888),
                            fontFamily: 'Consolas',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.labelNomeArquivoZip ?? 'Nome do Arquivo Compactado (.zip):',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _zipNameController,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Consolas'),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      hintText: 'Arquivo_Compactado.zip',
                    ),
                  ),
                  const Spacer(),
                  if (state.isLoading)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: state.progressoExecucao,
                          backgroundColor: const Color(0xFF2D2D2D),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0078D4)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.statusOperacao,
                          style: const TextStyle(color: Color(0xFF4EC9B0), fontSize: 12),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: (state.arquivosOrigem.isEmpty || state.diretorioDestino == null)
                          ? null
                          : () {
                              notifier.dispararCompactacao(_zipNameController.text);
                            },
                      icon: const Icon(Icons.archive, size: 18),
                      label: Text(l10n?.btnCompactarAgora ?? 'COMPACTAR ARQUIVOS EM LOTE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0078D4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ORIGEM DOS ITENS
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
                            '${l10n?.origem ?? 'ORIGEM'} [${state.itensCopiarOrigem.length}]',
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
                            label: Text(l10n?.adicionarArquivos ?? '(+) Arquivos'),
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
                            label: Text(l10n?.adicionarPasta ?? '(+) Pasta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0078D4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _selecionarOrigemGoogleDrive(context, state, notifier),
                            icon: const Icon(Icons.cloud_queue, size: 14),
                            label: Text(l10n?.adicionarGoogleDrive ?? '(+) Google Drive'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4EC9B0),
                              side: const BorderSide(color: Color(0xFF4EC9B0)),
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
                              children: [
                                const Icon(Icons.content_copy,
                                    size: 40, color: Color(0xFF555555)),
                                const SizedBox(height: 8),
                                Text(
                                  l10n?.nenhumItemCopiar ??
                                      "Nenhum item adicionado para cópia.\nUtilize '(+) Arquivos', '(+) Pasta' ou '(+) Google Drive'.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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

        // DESTINO DA CÓPIA E REGRAS
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
                          const Icon(Icons.folder_open,
                              color: Color(0xFF0078D4), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.destino ?? 'DESTINO',
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
                          OutlinedButton.icon(
                            onPressed: _selecionarDestinoCopiar,
                            icon: const Icon(Icons.create_new_folder_outlined, size: 16),
                            label: Text(l10n?.selecionarPasta ?? 'Selecionar Pasta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0078D4),
                              side: const BorderSide(color: Color(0xFF0078D4)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _selecionarDestinoGoogleDrive(context, state, notifier),
                            icon: const Icon(Icons.cloud_queue, size: 16),
                            label: Text(l10n?.googleDrive ?? 'Google Drive'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4EC9B0),
                              side: const BorderSide(color: Color(0xFF4EC9B0)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n?.caminhoDestino ?? 'Caminho de Destino:',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF888888)),
                            ),
                            if (state.destinoCopiar != null &&
                                state.destinoCopiar!.isNotEmpty)
                              Tooltip(
                                message: l10n?.limparDestino ?? 'Limpar destino',
                                child: InkWell(
                                  onTap: () => notifier.setDestinoCopiar(null),
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.close,
                                        color: Colors.redAccent, size: 16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          (state.destinoCopiar != null && state.destinoCopiar!.isNotEmpty)
                              ? state.destinoCopiar!
                              : (l10n?.nenhumDiretorioSelecionado ?? 'Nenhum diretório selecionado. Clique em "Selecionar Pasta".'),
                          style: TextStyle(
                            fontSize: 13,
                            color: (state.destinoCopiar != null && state.destinoCopiar!.isNotEmpty)
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
                        Expanded(
                          child: Text(
                            l10n?.organizarAposTransferir ?? 'Organizar automaticamente por categorias no destino',
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          value: state.auditarSha256,
                          activeColor: const Color(0xFF0078D4),
                          onChanged: (val) {
                            if (val != null) notifier.toggleAuditarSha256(val);
                          },
                        ),
                        Expanded(
                          child: Text(
                            l10n?.auditarSha256 ?? 'Auditar integridade de transferência (Hash SHA-256)',
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.regraColisaoDuplicados ?? 'REGRA DE COLISÃO / DUPLICADOS:',
                    style: const TextStyle(
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
                    items: [
                      DropdownMenuItem(
                        value: 'substituir',
                        child: Text(l10n?.substituirExistentes ?? 'Substituir existentes (Sobrescrever)'),
                      ),
                      DropdownMenuItem(
                        value: 'pular',
                        child: Text(l10n?.pularDuplicados ?? 'Pular duplicados (Ignorar se existir)'),
                      ),
                      DropdownMenuItem(
                        value: 'manter',
                        child: Text(l10n?.manterAmbos ?? 'Manter ambos (Criar cópia renomeada)'),
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
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ORIGEM DOS ITENS A MOVER
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
                            '${l10n?.origem ?? 'ORIGEM'} [${state.itensMoverOrigem.length}]',
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
                            label: Text(l10n?.adicionarArquivos ?? '(+) Arquivos'),
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
                            label: Text(l10n?.adicionarPasta ?? '(+) Pasta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD13438),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _selecionarOrigemGoogleDrive(context, state, notifier),
                            icon: const Icon(Icons.cloud_queue, size: 14),
                            label: Text(l10n?.adicionarGoogleDrive ?? '(+) Google Drive'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4EC9B0),
                              side: const BorderSide(color: Color(0xFF4EC9B0)),
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
                              children: [
                                const Icon(Icons.drive_file_move_outlined,
                                    size: 40, color: Color(0xFF555555)),
                                const SizedBox(height: 8),
                                Text(
                                  l10n?.nenhumItemMover ??
                                      "Nenhum item adicionado para movimentação.\nUtilize '(+) Arquivos', '(+) Pasta' ou '(+) Google Drive'.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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

        // DESTINO DA MOVIMENTAÇÃO
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
                          const Icon(Icons.folder_open,
                              color: Color(0xFFD13438), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.destino ?? 'DESTINO',
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
                          OutlinedButton.icon(
                            onPressed: _selecionarDestinoMover,
                            icon: const Icon(Icons.create_new_folder_outlined, size: 16),
                            label: Text(l10n?.selecionarPasta ?? 'Selecionar Pasta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD13438),
                              side: const BorderSide(color: Color(0xFFD13438)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _selecionarDestinoGoogleDrive(context, state, notifier),
                            icon: const Icon(Icons.cloud_queue, size: 16),
                            label: Text(l10n?.googleDrive ?? 'Google Drive'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4EC9B0),
                              side: const BorderSide(color: Color(0xFF4EC9B0)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n?.caminhoDestino ?? 'Caminho de Destino:',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF888888)),
                            ),
                            if (state.destinoMover != null &&
                                state.destinoMover!.isNotEmpty)
                              Tooltip(
                                message: l10n?.limparDestino ?? 'Limpar destino',
                                child: InkWell(
                                  onTap: () => notifier.setDestinoMover(null),
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.close,
                                        color: Colors.redAccent, size: 16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          (state.destinoMover != null && state.destinoMover!.isNotEmpty)
                              ? state.destinoMover!
                              : (l10n?.nenhumDiretorioSelecionado ?? 'Nenhum diretório selecionado. Clique em "Selecionar Pasta".'),
                          style: TextStyle(
                            fontSize: 13,
                            color: (state.destinoMover != null && state.destinoMover!.isNotEmpty)
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
                        Expanded(
                          child: Text(
                            l10n?.organizarAposTransferir ?? 'Organizar automaticamente por categorias no destino',
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          value: state.auditarSha256,
                          activeColor: const Color(0xFFD13438),
                          onChanged: (val) {
                            if (val != null) notifier.toggleAuditarSha256(val);
                          },
                        ),
                        Expanded(
                          child: Text(
                            l10n?.auditarSha256 ?? 'Auditar integridade de transferência (Hash SHA-256)',
                            style: const TextStyle(fontSize: 11, color: Colors.white),
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
                        Expanded(
                          child: Text(
                            l10n?.sobrescreverExistentes ?? 'Sobrescrever arquivos se já existirem no destino',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
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
    final l10n = AppLocalizations.of(context);

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
                      Text(
                        l10n?.diretorioRaiz ?? 'DIRETÓRIO RAIZ A ORGANIZAR:',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 2),
                      SelectableText(
                        (state.diretorioOrganizar != null && state.diretorioOrganizar!.isNotEmpty)
                            ? state.diretorioOrganizar!
                            : (l10n?.nenhumDiretorioSelecionado ?? 'Nenhum diretório selecionado. Clique em "Buscar Pasta".'),
                        style: TextStyle(
                          fontSize: 13,
                          color: (state.diretorioOrganizar != null && state.diretorioOrganizar!.isNotEmpty)
                              ? const Color(0xFF4EC9B0)
                              : const Color(0xFF888888),
                          fontFamily: 'Consolas',
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.diretorioOrganizar != null &&
                    state.diretorioOrganizar!.isNotEmpty) ...[
                  IconButton(
                    onPressed: () => notifier.setDiretorioOrganizar(null),
                    icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                    tooltip: 'Limpar Pasta',
                  ),
                  const SizedBox(width: 6),
                ],
                ElevatedButton.icon(
                  onPressed: _selecionarDiretorioOrganizar,
                  icon: const Icon(Icons.search, size: 16),
                  label: Text(l10n?.buscarPasta ?? 'Buscar Pasta'),
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
                  Text(
                    l10n?.categoriasEregras ?? 'CATEGORIAS E REGRAS DE ORGANIZAÇÃO',
                    style: const TextStyle(
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
                                  state.categoriasSelecionadas[categoria] ?? false;
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
                                              categoria == 'Documentos PDF'
                                                  ? (l10n?.documentosPdf ?? categoria)
                                                  : categoria == 'Word Doc'
                                                      ? (l10n?.wordDoc ?? categoria)
                                                      : categoria == 'Planilhas'
                                                          ? (l10n?.planilhas ?? categoria)
                                                          : categoria == 'Músicas'
                                                              ? (l10n?.musicas ?? categoria)
                                                              : categoria == 'Vídeos'
                                                                  ? (l10n?.videos ?? categoria)
                                                                  : categoria == 'Imagens'
                                                                      ? (l10n?.imagens ?? categoria)
                                                                      : categoria == 'Arquivos Compactados'
                                                                          ? (l10n?.arquivosCompactados ?? categoria)
                                                                          : categoria == 'Instaladores'
                                                                              ? (l10n?.instaladores ?? categoria)
                                                                              : categoria,
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
                              Text(
                                l10n?.regraPersonalizada ?? 'Regra Personalizada:',
                                style: const TextStyle(
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
                                  decoration: InputDecoration(
                                    hintText: l10n?.hintNomePasta ?? 'Nome da Pasta Ex: Texturas DDS',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
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
                        Expanded(
                          child: Text(
                            l10n?.incluirSubpastas ?? 'Incluir arquivos dentro de subpastas (Recursivo)',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
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
    final l10n = AppLocalizations.of(context);
    final isDuplicatesMode = state.searchMode == SearchMode.duplicates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Seletor de Modo de Operação + Pastas + Filtros
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: Color(0xFF3F3F46)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Linha 1: Alternador de Modo e Seleção de Pastas
                Row(
                  children: [
                    SegmentedButton<SearchMode>(
                      segments: [
                        ButtonSegment(
                          value: SearchMode.duplicates,
                          label: Text(l10n?.duplicadosSha256 ?? 'Duplicados (SHA-256)', style: const TextStyle(fontSize: 12)),
                          icon: const Icon(Icons.copy_outlined, size: 16),
                        ),
                        ButtonSegment(
                          value: SearchMode.fileSearch,
                          label: Text(l10n?.localizarArquivos ?? 'Localizar Arquivos', style: const TextStyle(fontSize: 12)),
                          icon: const Icon(Icons.search_outlined, size: 16),
                        ),
                      ],
                      selected: {state.searchMode},
                      onSelectionChanged: (set) {
                        if (set.isNotEmpty) notifier.setSearchMode(set.first);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF0078D4);
                          }
                          return const Color(0xFF2D2D2D);
                        }),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _selecionarDiretorioBusca,
                      icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                      label: Text(l10n?.adicionarPastaBusca ?? '+ Adicionar Pasta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0078D4),
                        side: const BorderSide(color: Color(0xFF0078D4)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    if (state.searchPaths.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      TextButton.icon(
                        onPressed: () => notifier.limparSearchPaths(),
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Limpar'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF888888),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Checkbox(
                          value: state.includeSubfolders,
                          activeColor: const Color(0xFF0078D4),
                          onChanged: (val) {
                            if (val != null) notifier.toggleIncludeSubfolders(val);
                          },
                        ),
                        Text(
                          l10n?.incluirSubpastas ?? 'Incluir subpastas (Recursivo)',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),

                // Lista de Chips de Pastas Selecionadas
                if (state.searchPaths.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: List.generate(state.searchPaths.length, (index) {
                      final path = state.searchPaths[index];
                      return Chip(
                        backgroundColor: const Color(0xFF2D2D2D),
                        side: const BorderSide(color: Color(0xFF3F3F46)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        label: Text(
                          path,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4EC9B0),
                              fontFamily: 'Consolas'),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                        onDeleted: () => notifier.removerSearchPath(index),
                      );
                    }),
                  ),
                ],

                const SizedBox(height: 8),

                // Linha 2: Filtros de Busca Responsivos com Checkboxes Diretos
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Filtros:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF888888)),
                    ),
                    ...[
                      {'key': 'todos', 'label': l10n?.todasMidias ?? 'Todas Mídias'},
                      {'key': 'imagens', 'label': l10n?.imagens ?? 'Imagens'},
                      {'key': 'videos', 'label': l10n?.videos ?? 'Vídeos'},
                      {'key': 'audios', 'label': l10n?.musicas ?? 'Áudios'},
                      {'key': 'textos', 'label': 'Texto/Docs'},
                      {'key': 'instaladores', 'label': l10n?.instaladores ?? 'Instaladores'},
                    ].map((cat) {
                      final String catKey = cat['key']!;
                      final String catLabel = cat['label']!;
                      final bool isSelected = state.categoriaFiltroBusca == catKey;

                      return InkWell(
                        onTap: () => notifier.setCategoriaFiltro(catKey),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0078D4).withValues(alpha: 0.2) : const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0078D4) : const Color(0xFF3F3F46),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: Checkbox(
                                  value: isSelected,
                                  activeColor: const Color(0xFF0078D4),
                                  onChanged: (val) {
                                    if (val == true) {
                                      notifier.setCategoriaFiltro(catKey);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                catLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? Colors.white : const Color(0xFFCCCCCC),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                if (!isDuplicatesMode) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          onChanged: (v) => notifier.setSearchFileNameQuery(v),
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: l10n?.hintBuscarNomeExtensao ?? 'Buscar por nome ou extensão (ex: .log)...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: state.searchSizeFilter,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          ),
                          dropdownColor: const Color(0xFF2D2D2D),
                          items: [
                            DropdownMenuItem(value: 'Todos', child: Text(l10n?.qualquerTamanho ?? 'Qualquer Tamanho', style: const TextStyle(fontSize: 11))),
                            const DropdownMenuItem(value: '< 10 MB', child: Text('< 10 MB', style: TextStyle(fontSize: 11))),
                            const DropdownMenuItem(value: '10-100 MB', child: Text('10-100 MB', style: TextStyle(fontSize: 11))),
                            const DropdownMenuItem(value: '100 MB - 1 GB', child: Text('100 MB - 1 GB', style: TextStyle(fontSize: 11))),
                            const DropdownMenuItem(value: '> 1 GB', child: Text('> 1 GB', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (val) {
                            if (val != null) notifier.setSearchSizeFilter(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Área Central de Resultados
        Expanded(
          child: isDuplicatesMode
              ? _buildResultadosDuplicados(context, state, notifier)
              : _buildResultadosBuscaArquivos(context, state, notifier),
        ),
      ],
    );
  }

  Widget _buildResultadosBuscaArquivos(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context);

    if (state.foundFiles.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFF3F3F46)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_outlined, size: 48, color: Color(0xFF555555)),
              const SizedBox(height: 12),
              Text(
                l10n?.nenhumArquivoLocalizado ?? 'Nenhum arquivo localizado.',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.orientacaoLocalizarArquivos ??
                    'Adicione uma ou mais pastas e clique em "LOCALIZAR ARQUIVOS".',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: Color(0xFF3F3F46)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Color(0xFF0078D4), size: 20),
                const SizedBox(width: 8),
                Text(
                  'ARQUIVOS LOCALIZADOS [${state.foundFiles.length}]',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white),
                ),
              ],
            ),
            const Divider(color: Color(0xFF3F3F46), height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: state.foundFiles.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Color(0xFF2D2D2D), height: 1),
                itemBuilder: (context, index) {
                  final file = state.foundFiles[index];
                  final sizeKb = (file.sizeBytes / 1024).toStringAsFixed(1);

                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: const Icon(Icons.insert_drive_file,
                        color: Color(0xFF0078D4), size: 20),
                    title: Text(
                      file.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    subtitle: Text(
                      '${file.path} • $sizeKb KB',
                      style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 11,
                          fontFamily: 'Consolas'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new,
                              size: 18, color: Color(0xFF0078D4)),
                          tooltip: 'Abrir Arquivo',
                          onPressed: () {
                            Process.run('explorer.exe', [file.path]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.folder_open,
                              size: 18, color: Color(0xFF4EC9B0)),
                          tooltip: 'Abrir Localização',
                          onPressed: () {
                            Process.run('explorer.exe', ['/select,', file.path]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy,
                              size: 18, color: Color(0xFFCCCCCC)),
                          tooltip: 'Copiar Caminho',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: file.path));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Caminho copiado!'),
                                backgroundColor: Color(0xFF0078D4),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadosDuplicados(
    BuildContext context,
    CommanderState state,
    CommanderNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context);

    if (state.gruposConflito.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFF3F3F46)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.find_in_page_outlined,
                  size: 48, color: Color(0xFF555555)),
              const SizedBox(height: 12),
              Text(
                l10n?.nenhumConflitoDetectado ??
                    'Nenhum conflito ou arquivo duplicado detectado.',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.orientacaoEscaneanarDuplicados ??
                    'Adicione uma ou mais pastas e clique em "ESCANEAR DUPLICADOS".',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
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
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final grupo = state.gruposConflito[index];
                        final isSelected =
                            state.grupoConflitoSelecionado == index;
                        final isIdentical = grupo['tipo'] == 'identical';
                        final arquivos = grupo['arquivos'] as List? ?? [];

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isIdentical
                                            ? const Color(0xFF107C41)
                                            : const Color(0xFFD83B01),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        isIdentical
                                            ? 'CONTEÚDO IDÊNTICO'
                                            : 'MESMO NOME',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
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

    final List<String> imagensDoGrupo = arquivos
        .map((a) => a['caminho'] as String? ?? '')
        .where((c) =>
            c.isNotEmpty &&
            File(c).existsSync() &&
            ['.jpg', '.jpeg', '.png', '.webp', '.bmp', '.gif']
                .contains(p.extension(c).toLowerCase()))
        .toList();

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
                            context: context,
                            caminho: caminho,
                            ext: ext,
                            isImage: isImage,
                            isText: isText,
                            isAudio: isAudio,
                            isVideo: isVideo,
                            isExe: isExe,
                            fileExists: fileExists,
                            arq: arq,
                            imagensDoGrupo: imagensDoGrupo,
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
                          label: const Text('Manter Este e Mover Outros p/ Lixeira'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF107C41),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Tooltip(
                          message: 'Enviar para a Lixeira do Windows',
                          child: OutlinedButton.icon(
                            onPressed: () {
                              notifier.removerArquivoDoConflito(
                                  caminho, state.grupoConflitoSelecionado);
                            },
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Mover para a Lixeira'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
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
    required BuildContext context,
    required String caminho,
    required String ext,
    required bool isImage,
    required bool isText,
    required bool isAudio,
    required bool isVideo,
    required bool isExe,
    required bool fileExists,
    required Map<String, dynamic> arq,
    required List<String> imagensDoGrupo,
  }) {
    if (isImage && fileExists) {
      final imgIndex = imagensDoGrupo.indexOf(caminho);
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(caminho),
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 40, color: Color(0xFF888888)),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.black.withValues(alpha: 0.65),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: const Icon(Icons.zoom_in, color: Colors.white),
                tooltip: 'Ampliar Imagem',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ImageZoomDialog(
                      imagePaths: imagensDoGrupo.isNotEmpty ? imagensDoGrupo : [caminho],
                      initialIndex: imgIndex >= 0 ? imgIndex : 0,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
