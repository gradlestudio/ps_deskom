import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main(List<String> args) {
  print('===========================================================');
  print('    GERADOR DE CHAVES DE LICENÇA COMERCIAL - GRADLE STUDIO ');
  print('===========================================================');

  String hwid = '';

  if (args.isNotEmpty && args[0].trim().isNotEmpty) {
    hwid = args[0].trim().toUpperCase();
  } else {
    stdout.write('\nDigite ou cole o HWID do cliente (ex: DESK-A1B2-C3D4-E5F6): ');
    final input = stdin.readLineSync();
    if (input != null) {
      hwid = input.trim().toUpperCase();
    }
  }

  if (hwid.isEmpty) {
    print('\n[ERRO] HWID não informado. Operação cancelada.');
    exit(1);
  }

  const secretSalt = 'GRADLE-STUDIO-2026-SECRET';
  final bytes = utf8.encode('$hwid-$secretSalt');
  final digest = sha256.convert(bytes).toString().toUpperCase();

  final b1 = digest.substring(0, 4);
  final b2 = digest.substring(4, 8);
  final b3 = digest.substring(8, 12);
  final b4 = digest.substring(12, 16);

  final licenseKey = 'KEY-$b1-$b2-$b3-$b4';

  print('\n-----------------------------------------------------------');
  print('  HWID do Cliente:       $hwid');
  print('  License Key Comercial: $licenseKey');
  print('-----------------------------------------------------------');

  print('\n[LEMBRETE DE CHAVES MESTRAS INSTITUCIONAIS]');
  print('  Dev Master:    GRADLE-STUDIO-DEV-2026-MASTER');
  print('  Server Master: GRADLE-STUDIO-SERVER-2026-MASTER');
  print('===========================================================\n');
}
