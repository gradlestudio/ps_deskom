import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/commander_provider.dart';
import '../providers/local_ai_provider.dart';

class LocalAiView extends ConsumerStatefulWidget {
  const LocalAiView({super.key});

  @override
  ConsumerState<LocalAiView> createState() => _LocalAiViewState();
}

class _LocalAiViewState extends ConsumerState<LocalAiView> {
  late TextEditingController _promptController;
  late TextEditingController _responseController;

  bool _isConnected = false;
  bool _isCheckingConnection = false;
  bool _isGenerating = false;
  StreamSubscription<String>? _streamSub;

  List<String> _models = ['qwen2.5-coder-3b-instruct'];
  String? _selectedModel = 'qwen2.5-coder-3b-instruct';

  List<String> _getPresetPrompts(AppLocalizations l10n) {
    return [
      l10n.presetIaMaiorArquivo,
      l10n.presetIaLimparTemp,
      l10n.presetIaAuditarRede,
      l10n.presetIaBackupZip,
    ];
  }

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _responseController = TextEditingController();
    _testarConexao();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _promptController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _testarConexao() async {
    final aiRepo = ref.read(localAiRepositoryProvider);
    if (aiRepo == null) return;

    setState(() => _isCheckingConnection = true);

    try {
      final isOnline = await aiRepo.checkConnection();
      List<String> loadedModels = _models;
      if (isOnline) {
        loadedModels = await aiRepo.getAvailableModels();
      }

      if (mounted) {
        setState(() {
          _isConnected = isOnline;
          _isCheckingConnection = false;
          _models = loadedModels;
          if (!loadedModels.contains(_selectedModel) && loadedModels.isNotEmpty) {
            _selectedModel = loadedModels.first;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isCheckingConnection = false;
        });
      }
    }
  }

  Future<void> _enviarPromptStream() async {
    final aiRepo = ref.read(localAiRepositoryProvider);
    final notifier = ref.read(commanderProvider.notifier);
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty || aiRepo == null || _isGenerating) return;

    setState(() {
      _isGenerating = true;
      _responseController.text = '';
    });

    notifier.adicionarLog('===========================================================');
    notifier.adicionarLog('  SOLICITAÇÃO DE AUTOMAÇÃO IA LOCAL (LM STUDIO)');
    notifier.adicionarLog('===========================================================');
    notifier.adicionarLog('  • Modelo: "${_selectedModel ?? 'default'}"');
    notifier.adicionarLog('  • Prompt: "$prompt"');

    const systemPrompt =
        'Você é um gerador de comandos e scripts PowerShell para Windows. '
        'Responda ESTRITAMENTE com o código executável do PowerShell, sem qualquer explicação, '
        'sem blocos de código markdown, sem crases (``` ou `) e sem texto adicional.';

    try {
      final stream = aiRepo.streamPrompt(
        prompt: prompt,
        systemPrompt: systemPrompt,
        model: _selectedModel,
      );

      _streamSub = stream.listen(
        (chunk) {
          if (mounted) {
            setState(() {
              _responseController.text += chunk;
            });
          }
        },
        onError: (err) {
          if (mounted) {
            setState(() {
              _isGenerating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro na resposta da IA: $err'), backgroundColor: Colors.redAccent),
            );
          }
          notifier.adicionarLog('  [ERRO IA] $err');
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isGenerating = false;
              _sanitizeResponse();
            });
          }
          notifier.adicionarLog('  [SUCESSO] Código gerado com sucesso via LM Studio.');
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
      notifier.adicionarLog('  [ERRO IA]: $e');
    }
  }

  void _sanitizeResponse() {
    String cleaned = _responseController.text.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^```[a-zA-Z]*\n?'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\n?```$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```'), '');
    _responseController.text = cleaned.trim();
  }

  void _interromperGeracao() {
    _streamSub?.cancel();
    setState(() => _isGenerating = false);
    _sanitizeResponse();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(commanderProvider.notifier);
    final presets = _getPresetPrompts(l10n);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho da View
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: Color(0xFF0078D4), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tituloIaLocal,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.subtituloIaLocal,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              // Selector de Modelo LM Studio se conectado
              if (_isConnected && _models.isNotEmpty) ...[
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF3F3F46)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _models.contains(_selectedModel) ? _selectedModel : _models.first,
                      dropdownColor: const Color(0xFF252526),
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontFamily: 'Consolas'),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0078D4), size: 18),
                      items: _models.map((model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedModel = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Badge de Status de Conexão com LM Studio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _isConnected
                      ? const Color(0xFF107C41).withValues(alpha: 0.2)
                      : Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isConnected ? const Color(0xFF107C41) : Colors.redAccent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.error_outline,
                      color: _isConnected ? const Color(0xFF107C41) : Colors.redAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isConnected ? l10n.statusConectadoIa : l10n.statusDesconectadoIa,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isConnected ? const Color(0xFF4EC9B0) : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isCheckingConnection ? null : _testarConexao,
                icon: _isCheckingConnection
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 14),
                label: Text(l10n.btnTestarConexao, style: const TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D2D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF3F3F46), height: 1),
          const SizedBox(height: 10),

          // Presets / Modelos de Atendimento Rápido
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF252526),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3F3F46)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.modelosPredefinidos,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: presets.map((preset) {
                    return ActionChip(
                      label: Text(preset, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: const Color(0xFF2D2D2D),
                      side: const BorderSide(color: Color(0xFF3F3F46)),
                      onPressed: () {
                        setState(() {
                          _promptController.text = preset;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Campo de Entrada do Prompt
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
                TextFormField(
                  controller: _promptController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.hintDigitarPromptIa,
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isGenerating)
                      ElevatedButton.icon(
                        onPressed: _interromperGeracao,
                        icon: const Icon(Icons.stop, size: 16),
                        label: Text(l10n.btnInterromperIa, style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _enviarPromptStream,
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: Text(l10n.btnEnviarPrompt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0078D4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Console de Código Retornado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3F3F46)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.code, color: Color(0xFF4EC9B0), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      l10n.labelCodigoGeradoIa,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4EC9B0)),
                    ),
                    const Spacer(),
                    if (_responseController.text.isNotEmpty) ...[
                      IconButton(
                        tooltip: l10n.tooltipCopiarCodigo,
                        icon: const Icon(Icons.copy, size: 14, color: Colors.white70),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _responseController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.msgCodigoCopiado)),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: l10n.tooltipExecutarPs,
                        icon: const Icon(Icons.play_arrow, size: 16, color: Color(0xFF107C41)),
                        onPressed: () {
                          notifier.executarScript(_responseController.text);
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _responseController,
                  maxLines: 8,
                  style: const TextStyle(
                    color: Color(0xFFDCDCDC),
                    fontSize: 12,
                    fontFamily: 'Consolas',
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: l10n.hintRespostaIa,
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 12, fontFamily: 'Consolas'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
