import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

enum AiProviderType { gemini, claude, openai, customOpenAi }

class ConnectAiDialog extends StatefulWidget {
  const ConnectAiDialog({super.key});

  @override
  State<ConnectAiDialog> createState() => _ConnectAiDialogState();
}

class _ConnectAiDialogState extends State<ConnectAiDialog> {
  AiProviderType _selectedProvider = AiProviderType.gemini;
  late TextEditingController _apiKeyController;
  late TextEditingController _endpointController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _endpointController = TextEditingController(text: 'http://127.0.0.1:1234/v1');
    _carregarCredenciais();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    super.dispose();
  }

  Future<void> _carregarCredenciais() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProviderStr = prefs.getString('ai_provider') ?? 'gemini';
    final savedKey = prefs.getString('ai_api_key') ?? '';
    final savedEndpoint = prefs.getString('ai_custom_endpoint') ?? 'http://127.0.0.1:1234/v1';

    if (mounted) {
      setState(() {
        _selectedProvider = AiProviderType.values.firstWhere(
          (p) => p.name == savedProviderStr,
          orElse: () => AiProviderType.gemini,
        );
        _apiKeyController.text = savedKey;
        _endpointController.text = savedEndpoint;
      });
    }
  }

  Future<void> _salvarCredenciais() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('ai_provider', _selectedProvider.name);
    await prefs.setString('ai_api_key', _apiKeyController.text.trim());
    await prefs.setString('ai_custom_endpoint', _endpointController.text.trim());

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais da IA salvas com sucesso!'),
          backgroundColor: Color(0xFF107C41),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _abrirLinkConsole(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF0078D4)),
      ),
      title: Row(
        children: [
          const Icon(Icons.cloud_sync_outlined, color: Color(0xFF0078D4), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.modalConectarIa,
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.provedorIa,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFCCCCCC)),
              ),
              const SizedBox(height: 6),

              RadioListTile<AiProviderType>(
                value: AiProviderType.gemini,
                groupValue: _selectedProvider,
                activeColor: const Color(0xFF0078D4),
                dense: true,
                title: const Text('Google Gemini (AI Studio)', style: TextStyle(color: Colors.white, fontSize: 12)),
                subtitle: InkWell(
                  onTap: () => _abrirLinkConsole('https://aistudio.google.com/app/apikey'),
                  child: const Text('Obter chave no Google AI Studio (aistudio.google.com)', style: TextStyle(color: Color(0xFF4EC9B0), fontSize: 10)),
                ),
                onChanged: (val) => setState(() => _selectedProvider = val!),
              ),

              RadioListTile<AiProviderType>(
                value: AiProviderType.claude,
                groupValue: _selectedProvider,
                activeColor: const Color(0xFF0078D4),
                dense: true,
                title: const Text('Anthropic Claude', style: TextStyle(color: Colors.white, fontSize: 12)),
                subtitle: InkWell(
                  onTap: () => _abrirLinkConsole('https://console.anthropic.com/settings/keys'),
                  child: const Text('Obter chave no Anthropic Console (console.anthropic.com)', style: TextStyle(color: Color(0xFF4EC9B0), fontSize: 10)),
                ),
                onChanged: (val) => setState(() => _selectedProvider = val!),
              ),

              RadioListTile<AiProviderType>(
                value: AiProviderType.openai,
                groupValue: _selectedProvider,
                activeColor: const Color(0xFF0078D4),
                dense: true,
                title: const Text('OpenAI ChatGPT', style: TextStyle(color: Colors.white, fontSize: 12)),
                subtitle: InkWell(
                  onTap: () => _abrirLinkConsole('https://platform.openai.com/api-keys'),
                  child: const Text('Obter chave na OpenAI Platform (platform.openai.com)', style: TextStyle(color: Color(0xFF4EC9B0), fontSize: 10)),
                ),
                onChanged: (val) => setState(() => _selectedProvider = val!),
              ),

              RadioListTile<AiProviderType>(
                value: AiProviderType.customOpenAi,
                groupValue: _selectedProvider,
                activeColor: const Color(0xFF0078D4),
                dense: true,
                title: const Text('Outras / LM Studio / OpenAI-Compatible API', style: TextStyle(color: Colors.white, fontSize: 12)),
                onChanged: (val) => setState(() => _selectedProvider = val!),
              ),

              const SizedBox(height: 12),

              if (_selectedProvider == AiProviderType.customOpenAi) ...[
                const Text('Endpoint Customizado (REST API):', style: TextStyle(fontSize: 11, color: Color(0xFFCCCCCC))),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _endpointController,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Consolas'),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    hintText: 'http://127.0.0.1:1234/v1',
                  ),
                ),
                const SizedBox(height: 10),
              ],

              Text(l10n.chaveApiKey, style: const TextStyle(fontSize: 11, color: Color(0xFFCCCCCC))),
              const SizedBox(height: 4),
              TextFormField(
                controller: _apiKeyController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Consolas'),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  hintText: 'sk-...',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.fechar, style: const TextStyle(color: Color(0xFF888888))),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _salvarCredenciais,
          icon: _isSaving
              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check, size: 16),
          label: Text(l10n.btnValidarChave),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0078D4),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
