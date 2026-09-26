import 'dart:convert';
import 'package:http/http.dart' as http;

class LMStudioService {
  final String baseUrl;

  LMStudioService({this.baseUrl = 'http://127.0.0.1:1234/api/v0/chat/completions'});

  Future<String> generatePowerShellCommand(String userPrompt) async {
    final url = Uri.parse(baseUrl);
    const systemPrompt =
        'Você é um gerador de comandos e scripts PowerShell para Windows. '
        'Responda ESTRITAMENTE com o código executável do PowerShell, sem qualquer explicação, '
        'sem blocos de código markdown, sem crases (``` ou `) e sem texto adicional.';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'qwen2.5-coder-3b-instruct',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.1,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawContent = data['choices'][0]['message']['content'] as String;
      return _sanitizeCommand(rawContent);
    } else {
      throw Exception('Falha ao se comunicar com LM Studio: ${response.statusCode} - ${response.body}');
    }
  }

  String _sanitizeCommand(String content) {
    String cleaned = content.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^```[a-zA-Z]*\n?'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\n?```$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```'), '');
    return cleaned.trim();
  }
}
