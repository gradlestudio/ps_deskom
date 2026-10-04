import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class BotManagerService {
  final String processName;

  BotManagerService({this.processName = 'grad-bot'});

  String sanitizeOutput(String raw) {
    // Remove códigos de escape ANSI / cores de terminal
    final ansiRegex = RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]');
    return raw.replaceAll(ansiRegex, '');
  }

  Future<String> _getBotScriptPath() async {
    // 1. Tenta pelo diretório do executável resolvido (dist de produção)
    final appDir = File(Platform.resolvedExecutable).parent.path;
    final installedBotPath = p.join(appDir, 'tools', 'whatsapp_bot', 'bot.js');
    if (await File(installedBotPath).exists()) {
      return installedBotPath;
    }

    // 2. Fallback para o diretório de trabalho atual (ambiente dev / projeto)
    final devBotPath = p.join(Directory.current.path, 'tools', 'whatsapp_bot', 'bot.js');
    if (await File(devBotPath).exists()) {
      return devBotPath;
    }

    // 3. Fallback relativo seguro
    return 'tools/whatsapp_bot/bot.js';
  }

  Future<ProcessResult> _runCommand(String command) async {
    return await Process.run(
      'powershell.exe',
      ['-Command', '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $command'],
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
  }

  Future<Map<String, dynamic>> getStatus() async {
    try {
      final res = await _runCommand('pm2 jlist');
      if (res.exitCode == 0) {
        final List<dynamic> list = jsonDecode(res.stdout.toString());
        for (var item in list) {
          if (item['name'] == processName || item['name'] == 'bot') {
            final pm2Env = item['pm2_env'];
            final status = pm2Env != null ? pm2Env['status'] : 'unknown';
            final uptime = pm2Env != null ? pm2Env['pm_uptime'] : 0;
            final restarts = pm2Env != null ? pm2Env['restart_time'] : 0;
            return {
              'online': status == 'online',
              'status': status,
              'uptime': uptime,
              'restarts': restarts,
              'pid': item['pid'] ?? 0,
            };
          }
        }
      }
      return {'online': false, 'status': 'stopped', 'uptime': 0, 'restarts': 0};
    } catch (_) {
      return {'online': false, 'status': 'error', 'uptime': 0, 'restarts': 0};
    }
  }

  Future<String> getList() async {
    try {
      final res = await _runCommand('pm2 list --no-color');
      final stdoutStr = res.stdout.toString();
      final stderrStr = res.stderr.toString();
      final raw = stdoutStr.isNotEmpty
          ? stdoutStr
          : (stderrStr.isNotEmpty ? stderrStr : 'Nenhuma saída do PM2.');
      return sanitizeOutput(raw);
    } catch (e) {
      return 'Erro ao executar pm2 list: $e';
    }
  }

  Future<String> getLogs() async {
    try {
      final res = await _runCommand('pm2 logs $processName --lines 35 --nostream --no-color');
      final output = res.stdout.toString() + res.stderr.toString();
      final raw = output.isNotEmpty ? output : 'Nenhum registro de log recente encontrado.';
      return sanitizeOutput(raw);
    } catch (e) {
      return 'Erro ao obter logs: $e';
    }
  }

  Future<String> startBot() async {
    try {
      final scriptPath = await _getBotScriptPath();
      final res = await _runCommand('pm2 start "$scriptPath" --name "$processName" --no-color');
      final stdoutStr = res.stdout.toString();
      final stderrStr = res.stderr.toString();
      final raw = stdoutStr.isNotEmpty
          ? stdoutStr
          : (stderrStr.isNotEmpty ? stderrStr : 'Bot iniciado.');
      return sanitizeOutput(raw);
    } catch (e) {
      return 'Erro ao iniciar o bot: $e';
    }
  }

  Future<String> restartBot() async {
    try {
      final scriptPath = await _getBotScriptPath();
      final res = await _runCommand('pm2 restart "$processName" --no-color || pm2 start "$scriptPath" --name "$processName" --no-color');
      final stdoutStr = res.stdout.toString();
      final stderrStr = res.stderr.toString();
      final raw = stdoutStr.isNotEmpty
          ? stdoutStr
          : (stderrStr.isNotEmpty ? stderrStr : 'Bot reiniciado.');
      return sanitizeOutput(raw);
    } catch (e) {
      return 'Erro ao reiniciar o bot: $e';
    }
  }

  Future<String> stopBot() async {
    try {
      final res = await _runCommand('pm2 stop $processName --no-color');
      final stdoutStr = res.stdout.toString();
      final stderrStr = res.stderr.toString();
      final raw = stdoutStr.isNotEmpty
          ? stdoutStr
          : (stderrStr.isNotEmpty ? stderrStr : 'Bot parado.');
      return sanitizeOutput(raw);
    } catch (e) {
      return 'Erro ao parar o bot: $e';
    }
  }
}
