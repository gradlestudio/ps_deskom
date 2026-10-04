import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'local_ai_repository.dart';

class LmStudioRepositoryImpl implements LocalAiRepository {
  final String baseUrl;
  final http.Client _client;

  LmStudioRepositoryImpl({
    this.baseUrl = 'http://127.0.0.1:1234/v1',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<bool> checkConnection({String host = 'http://127.0.0.1:1234'}) async {
    try {
      final url = Uri.parse('$host/v1/models');
      final response = await _client.get(url).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableModels({String host = 'http://127.0.0.1:1234'}) async {
    try {
      final url = Uri.parse('$host/v1/models');
      final response = await _client.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
        final data = json['data'] as List?;
        if (data != null && data.isNotEmpty) {
          final List<String> models = [];
          for (var item in data) {
            if (item is Map && item['id'] != null) {
              models.add(item['id'].toString());
            }
          }
          if (models.isNotEmpty) return models;
        }
      }
    } catch (_) {}
    return ['qwen2.5-coder-3b-instruct'];
  }

  @override
  Future<String> sendPrompt({
    required String prompt,
    String? systemPrompt,
    String? model,
  }) async {
    final url = Uri.parse('$baseUrl/chat/completions');
    const defaultSystemPrompt =
        'Você é um assistente técnico especializado e gerador de automação PowerShell para Windows. '
        'Responda estritamente com o código ou resposta técnica solicitada sem comentários desnecessários.';

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': model ?? 'qwen2.5-coder-3b-instruct',
              'messages': [
                {'role': 'system', 'content': systemPrompt ?? defaultSystemPrompt},
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.2,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'];
          if (message != null && message['content'] != null) {
            return (message['content'] as String).trim();
          }
        }
        return '';
      } else {
        throw Exception('Servidor LM Studio retornou status HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tempo limite de resposta excedido ao conectar com LM Studio (45s).');
    } on SocketException catch (e) {
      throw Exception('Conexão recusada pelo LM Studio em $baseUrl ($e). Certifique-se de que o servidor local está ativo.');
    } catch (e) {
      throw Exception('Falha na comunicação com a IA Local: $e');
    }
  }

  @override
  Stream<String> streamPrompt({
    required String prompt,
    String? systemPrompt,
    String? model,
  }) {
    final controller = StreamController<String>();
    final url = Uri.parse('$baseUrl/chat/completions');
    const defaultSystemPrompt =
        'Você é um assistente técnico especializado e gerador de automação PowerShell para Windows. '
        'Responda estritamente com o código ou resposta técnica solicitada sem comentários desnecessários.';

    Future<void>(() async {
      try {
        final request = http.Request('POST', url);
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode({
          'model': model ?? 'qwen2.5-coder-3b-instruct',
          'messages': [
            {'role': 'system', 'content': systemPrompt ?? defaultSystemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.2,
          'stream': true,
        });

        final response = await _client.send(request).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen(
            (line) {
              final trimmed = line.trim();
              if (trimmed.startsWith('data: ')) {
                final dataStr = trimmed.substring(6).trim();
                if (dataStr == '[DONE]') {
                  controller.close();
                  return;
                }
                try {
                  final json = jsonDecode(dataStr);
                  final choices = json['choices'] as List?;
                  if (choices != null && choices.isNotEmpty) {
                    final delta = choices[0]['delta'];
                    if (delta != null && delta['content'] != null) {
                      controller.add(delta['content'] as String);
                    }
                  }
                } catch (_) {}
              }
            },
            onError: (err) {
              controller.addError(Exception('Erro no fluxo de respostas da IA: $err'));
              controller.close();
            },
            onDone: () {
              if (!controller.isClosed) controller.close();
            },
            cancelOnError: true,
          );
        } else {
          controller.addError(Exception('LM Studio retornou HTTP ${response.statusCode}'));
          controller.close();
        }
      } on TimeoutException {
        controller.addError(Exception('Timeout de conexão com o LM Studio.'));
        controller.close();
      } on SocketException catch (e) {
        controller.addError(Exception('Falha de conexão com o LM Studio: $e'));
        controller.close();
      } catch (e) {
        controller.addError(Exception('Erro de execução do streaming: $e'));
        controller.close();
      }
    });

    return controller.stream;
  }
}
