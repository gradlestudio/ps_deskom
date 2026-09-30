import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'powershell_service.dart';

enum AppEdition {
  bas('BAS'),
  pro('PRO'),
  max('MAX'),
  devBas('DEV-BAS'),
  devPro('DEV-PRO'),
  devMax('DEV-MAX'),
  devPj('DEV-PJ');

  final String code;
  const AppEdition(this.code);
}

class LicenseService {
  static const String masterKeyDev = 'GRADLE-STUDIO-DEV-2026-MASTER';
  static const String masterKeyServer = 'GRADLE-STUDIO-SERVER-2026-MASTER';
  static const String masterKey = masterKeyDev;
  static const String secretSalt = 'GRADLE-STUDIO-2026-SECRET';

  final PowerShellService _powerShellService;
  final AppEdition edicaoAtual;

  LicenseService({
    PowerShellService? powerShellService,
    this.edicaoAtual = AppEdition.devPro,
  }) : _powerShellService = powerShellService ?? PowerShellService();

  Future<String> obterHwid() async {
    try {
      final psScript = '''
\$uuid = (Get-WmiObject Win32_ComputerSystemProduct -ErrorAction SilentlyContinue).UUID
if (-not \$uuid) { \$uuid = \$env:COMPUTERNAME + \$env:USERNAME }
Write-Output \$uuid
''';
      final raw = (await _powerShellService.executeEncoded(psScript)).trim();
      final input = raw.isNotEmpty ? raw : 'PSDESKOM-DEFAULT-HWID-2026';

      final bytes = utf8.encode(input);
      final digest = sha256.convert(bytes).toString().toUpperCase();

      final b1 = digest.substring(0, 4);
      final b2 = digest.substring(4, 8);
      final b3 = digest.substring(8, 12);
      final b4 = digest.substring(12, 16);

      return 'DESK-${edicaoAtual.code}-$b1-$b2-$b3-$b4';
    } catch (_) {
      return 'DESK-${edicaoAtual.code}-8849-3921-9941-2026';
    }
  }

  String gerarChaveEsperada(String hwid) {
    final bytes = utf8.encode('$hwid-$secretSalt');
    final digest = sha256.convert(bytes).toString().toUpperCase();

    final b1 = digest.substring(0, 4);
    final b2 = digest.substring(4, 8);
    final b3 = digest.substring(8, 12);
    final b4 = digest.substring(12, 16);

    return 'KEY-$b1-$b2-$b3-$b4';
  }

  Future<Map<String, dynamic>> validarEAtivarChave(
      String chaveInput, String hwid) async {
    final chave = chaveInput.trim().toUpperCase();

    if (chave == masterKeyDev) {
      const tipo = 'Gradle Studio Dev';
      await _salvarNoPrefs(chave, tipo);
      return {
        'ativado': true,
        'tipo': tipo,
        'isDev': true,
        'mensagem': 'Licença Mestra "Gradle Studio Dev" Ativada com Sucesso!'
      };
    }

    if (chave == masterKeyServer) {
      const tipo = 'Gradle Studio Server';
      await _salvarNoPrefs(chave, tipo);
      return {
        'ativado': true,
        'tipo': tipo,
        'isDev': true,
        'mensagem': 'Licença Mestra "Gradle Studio Server" Ativada com Sucesso!'
      };
    }

    final chaveValidaCliente = gerarChaveEsperada(hwid);
    if (chave == chaveValidaCliente) {
      const tipo = 'Licença Comercial';
      await _salvarNoPrefs(chave, tipo);
      return {
        'ativado': true,
        'tipo': tipo,
        'isDev': false,
        'mensagem': 'Licença Comercial Ativada com Sucesso!'
      };
    }

    return {
      'ativado': false,
      'tipo': 'Não Ativado',
      'isDev': false,
      'mensagem': 'Chave de Licença Inválida.'
    };
  }

  Future<Map<String, dynamic>> carregarStatusLicenca(String hwid) async {
    final prefs = await SharedPreferences.getInstance();
    final chaveSalva = prefs.getString('license_key') ?? '';

    if (chaveSalva.isEmpty) {
      return {'ativado': false, 'tipo': 'Não Ativado', 'isDev': false};
    }

    if (chaveSalva == masterKeyDev) {
      return {'ativado': true, 'tipo': 'Gradle Studio Dev', 'isDev': true};
    }

    if (chaveSalva == masterKeyServer) {
      return {'ativado': true, 'tipo': 'Gradle Studio Server', 'isDev': true};
    }

    if (chaveSalva == gerarChaveEsperada(hwid)) {
      return {'ativado': true, 'tipo': 'Licença Comercial', 'isDev': false};
    }

    return {'ativado': false, 'tipo': 'Não Ativado', 'isDev': false};
  }

  Future<void> _salvarNoPrefs(String chave, String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('license_key', chave);
    await prefs.setString('license_type', tipo);
  }

  Future<void> revogarLicenca() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('license_key');
    await prefs.remove('license_type');
  }
}
