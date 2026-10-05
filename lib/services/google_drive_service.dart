import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'google_auth_service.dart';

class GoogleDriveService {
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('google_access_token');
    final refreshToken = prefs.getString('google_refresh_token');

    if (token != null && token.isNotEmpty) {
      return token;
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      return await _renovarAccessToken(refreshToken);
    }

    return null;
  }

  Future<String?> _renovarAccessToken(String refreshToken) async {
    try {
      final tokenUrl = Uri.parse('https://oauth2.googleapis.com/token');
      final res = await http.post(tokenUrl, body: {
        'client_id': GoogleAuthService.clientId,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token',
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final newToken = data['access_token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('google_access_token', newToken);
          return newToken;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> uploadArquivo({
    required File arquivoLocal,
    String? nomePastaDestino,
    void Function(String msg)? onLog,
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      onLog?.call('Contas do Google não autenticada. Faça login com o Google primeiro.');
      return false;
    }

    try {
      final fileName = p.basename(arquivoLocal.path);
      onLog?.call('Iniciando upload de "$fileName" para o Google Drive...');

      final url = Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');
      final metadata = {
        'name': fileName,
        'description': 'Arquivo enviado via PS DesKom',
      };

      final bytes = await arquivoLocal.readAsBytes();

      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromString(
          'metadata',
          jsonEncode(metadata),
          contentType: http.MediaType('application', 'json'),
        ))
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ));

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        onLog?.call('✔ Upload de "$fileName" concluído com sucesso no Google Drive!');
        return true;
      } else {
        onLog?.call('Erro no upload (HTTP ${response.statusCode}).');
        return false;
      }
    } catch (e) {
      onLog?.call('Falha ao enviar arquivo para o Google Drive: $e');
      return false;
    }
  }

  Future<List<Map<String, String>>> listarArquivosDrive() async {
    final token = await _getAccessToken();
    if (token == null) return [];

    try {
      final url = Uri.parse('https://www.googleapis.com/drive/v3/files?pageSize=20&fields=files(id,name,mimeType)');
      final res = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final files = data['files'] as List?;
        if (files != null) {
          return files.map((f) => {
            'id': f['id']?.toString() ?? '',
            'name': f['name']?.toString() ?? '',
            'mimeType': f['mimeType']?.toString() ?? '',
          }).toList();
        }
      }
    } catch (_) {}

    return [];
  }
}
