import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleAuthService {
  static const String clientId = '689176821238-btq90a1q377dn57ngtbv30l1d6bfk2r5.apps.googleusercontent.com';
  static const int port = 8088;
  static const String redirectUri = 'http://127.0.0.1:$port/';

  HttpServer? _server;

  Future<Map<String, String>?> authenticateGoogleDesktop() async {
    try {
      // 1. Inicia servidor HTTP loopback local na porta 8088
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

      // 2. Constrói URL de autorização OAuth2 com TODOS os parâmetros obrigatórios
      final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'openid email profile https://www.googleapis.com/auth/drive.file',
        'access_type': 'offline',
        'prompt': 'select_account',
      });

      // 3. Abre o navegador padrão do sistema operacional
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl);
      } else {
        throw Exception('Não foi possível abrir o navegador padrão.');
      }

      // 4. Aguarda a requisição do callback do Google no loopback
      final requestCompleter = Completer<Map<String, String>?>();

      _server!.listen((HttpRequest request) async {
        final queryParams = request.requestedUri.queryParameters;
        final code = queryParams['code'];
        final error = queryParams['error'];

        // Resposta visual amigável exibida no navegador
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write('''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Autenticação Concluída — PS DesKom</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #0D1117; color: #FFFFFF; text-align: center; padding: 50px; }
    .card { background: #161616; border: 1px solid #0078D4; border-radius: 8px; max-width: 480px; margin: 0 auto; padding: 32px; }
    h2 { color: #107C41; margin-bottom: 8px; }
    p { color: #CCCCCC; font-size: 14px; }
  </style>
</head>
<body>
  <div class="card">
    <h2>✔ Autenticação Concluída!</h2>
    <p>Sua conta Google foi vinculada com sucesso ao <strong>PS DesKom</strong>.</p>
    <p>Você já pode fechar esta aba e retornar ao aplicativo.</p>
  </div>
</body>
</html>
''');
        await request.response.close();

        if (code != null) {
          final perfil = await _trocarCodePorPerfil(code);
          requestCompleter.complete(perfil);
        } else {
          requestCompleter.completeError(Exception('Login cancelado ou erro: $error'));
        }
      });

      final result = await requestCompleter.future.timeout(const Duration(minutes: 3), onTimeout: () {
        throw TimeoutException('Tempo limite esgotado para login com Google.');
      });

      if (result != null && result['email'] != null && result['email']!.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('google_user_email', result['email']!);
        await prefs.setString('google_user_name', result['name'] ?? '');
        await prefs.setString('google_user_picture', result['picture'] ?? '');
      }

      return result;
    } catch (e) {
      rethrow;
    } finally {
      await _server?.close(force: true);
      _server = null;
    }
  }

  Future<Map<String, String>> _trocarCodePorPerfil(String code) async {
    try {
      final tokenUrl = Uri.parse('https://oauth2.googleapis.com/token');
      final res = await http.post(tokenUrl, body: {
        'code': code,
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      });

      if (res.statusCode == 200) {
        final tokenData = jsonDecode(res.body);
        final accessToken = tokenData['access_token'];

        final userInfoUrl = Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo');
        final userRes = await http.get(userInfoUrl, headers: {
          'Authorization': 'Bearer $accessToken',
        });

        if (userRes.statusCode == 200) {
          final userData = jsonDecode(utf8.decode(userRes.bodyBytes));
          final String name = userData['name']?.toString() ?? userData['given_name']?.toString() ?? 'Usuário Google';
          final String email = userData['email']?.toString() ?? '';
          final String picture = userData['picture']?.toString() ?? '';

          return {
            'email': email,
            'name': name,
            'picture': picture,
          };
        }
      }
    } catch (_) {}

    return {
      'email': '',
      'name': '',
      'picture': '',
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_user_email');
    await prefs.remove('google_user_name');
    await prefs.remove('google_user_picture');
  }
}
