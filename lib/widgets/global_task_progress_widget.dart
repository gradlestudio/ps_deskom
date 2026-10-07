import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/commander_provider.dart';

class GlobalTaskProgressWidget extends ConsumerWidget {
  const GlobalTaskProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commanderProvider);
    final l10n = AppLocalizations.of(context);

    final bool isRunning = state.isLoading || state.isEscaneando;
    final double progresso = state.progressoExecucao.clamp(0.0, 1.0);
    final int pctInt = (progresso * 100).toInt();
    final String statusMsg = state.statusOperacao.isNotEmpty
        ? state.statusOperacao
        : (isRunning ? (l10n?.taskRunning ?? 'Executando operação...') : (l10n?.taskIdle ?? 'Pronto para iniciar a operação'));

    final bool isCompletedSuccess = !isRunning && progresso == 1.0;
    final bool isError = !isRunning && state.statusOperacao.toLowerCase().contains('erro');

    if (!isRunning && !isCompletedSuccess && !isError && state.statusOperacao.isEmpty) {
      // Estado Ocioso (Idle)
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFF252526),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF3F3F46)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF888888), size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n?.taskIdle ?? 'Pronto para iniciar a operação',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (isRunning) {
      // Estado em Execução (Running)
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFF252526),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF0078D4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0078D4)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$statusMsg ($pctInt%)',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$pctInt%',
                  style: const TextStyle(color: Color(0xFF0078D4), fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Consolas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progresso > 0 ? progresso : null,
                minHeight: 6,
                backgroundColor: const Color(0xFF2D2D30),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0078D4)),
              ),
            ),
          ],
        ),
      );
    }

    if (isCompletedSuccess) {
      // Estado Concluído com Sucesso
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFF107C41).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF107C41)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF107C41), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                statusMsg.isNotEmpty ? statusMsg : (l10n?.taskCompleted ?? 'Operação concluída com sucesso!'),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // Estado de Erro ou Falha
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFD83B01).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD83B01)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD83B01), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusMsg.isNotEmpty ? statusMsg : (l10n?.taskFailed ?? 'Falha na operação.'),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
