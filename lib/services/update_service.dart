import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateService {
  static const String versaoLocal = '1.0.0';
  static const String urlEndpoint =
      'https://raw.githubusercontent.com/gradlestudio/ps_deskom/refs/heads/main/version.json';

  Future<Map<String, dynamic>?> verificarAtualizacoes() async {
    final client = http.Client();
    try {
      final response = await client
          .get(Uri.parse(urlEndpoint))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final bodyText = utf8.decode(response.bodyBytes);
        final data = jsonDecode(bodyText);

        if (data is Map<String, dynamic>) {
          final versaoRecente = data['versao_recente'] as String? ?? '1.0.0';

          if (versaoRecente != versaoLocal) {
            return {
              'versao_recente': versaoRecente,
              'download_url': data['download_url'] ??
                  'https://github.com/gradlestudio/ps_deskom',
              'novidades': List<String>.from(data['novidades'] ?? []),
            };
          }
        }
      }
    } catch (_) {
      // Captura silenciosa de falhas de conexão ou timeouts
    } finally {
      client.close();
    }
    return null;
  }
}
