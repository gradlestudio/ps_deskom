import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/local_ai_repository.dart';
import '../repositories/lmstudio_repository_impl.dart';

const String _appEditionEnv = String.fromEnvironment('APP_EDITION', defaultValue: 'MASTER');

/// Verifica se a edição atual do aplicativo tem suporte ao módulo de IA Local
bool isLocalAiSupported() {
  final String edition = _appEditionEnv.trim().toUpperCase();
  if (edition == 'MASTER' || edition.startsWith('DEV')) {
    return true;
  }
  return false;
}

/// Provider condicional da IA Local (LM Studio)
/// Retorna o repositório configurado para MASTER e edições DEV (Dev Basic, Dev Pro, Dev Max, Dev PJ).
/// Retorna `null` em edições comerciais comuns (Basic, Pro, Max).
final localAiRepositoryProvider = Provider<LocalAiRepository?>((ref) {
  if (isLocalAiSupported()) {
    return LmStudioRepositoryImpl();
  }
  return null;
});
