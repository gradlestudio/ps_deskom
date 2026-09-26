import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/commander_provider.dart';

class ActivationDialog extends ConsumerStatefulWidget {
  const ActivationDialog({super.key});

  @override
  ConsumerState<ActivationDialog> createState() => _ActivationDialogState();
}

class _ActivationDialogState extends ConsumerState<ActivationDialog> {
  final TextEditingController _chaveController = TextEditingController();

  @override
  void dispose() {
    _chaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commanderProvider);
    final notifier = ref.read(commanderProvider.notifier);

    final isAtivado = state.softwareAtivado;
    final statusTexto = state.statusLicencaTexto;
    final hwid = state.hwidAtual;

    return Dialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF3F3F46)),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.vpn_key_outlined,
                    color: Color(0xFF0078D4), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Ativação do PS DesKom',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAtivado
                        ? const Color(0xFF107C41).withValues(alpha: 0.2)
                        : const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAtivado
                          ? const Color(0xFF107C41)
                          : const Color(0xFF3F3F46),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isAtivado
                              ? const Color(0xFF107C41)
                              : Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusTexto,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAtivado
                              ? const Color(0xFF4EC9B0)
                              : const Color(0xFFCCCCCC),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF3F3F46), height: 1),
            const SizedBox(height: 16),

            // Identificador do Computador (HWID)
            const Text(
              'IDENTIFICADOR DO COMPUTADOR (HWID):',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF888888),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF252526),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      hwid.isEmpty ? 'Carregando HWID...' : hwid,
                      style: const TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 13,
                        color: Color(0xFF4EC9B0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: hwid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('HWID copiado para a área de transferência!'),
                          backgroundColor: Color(0xFF0078D4),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Copiar', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFCCCCCC),
                      side: const BorderSide(color: Color(0xFF3F3F46)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Entrada de Chave de Licença
            const Text(
              'CHAVE DE LICENÇA (LICENSE KEY):',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF888888),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _chaveController,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Consolas'),
              decoration: const InputDecoration(
                hintText: 'Insira sua chave (ex: KEY-XXXX-YYYY-ZZZZ)',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),

            // Botões de Ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar',
                      style: TextStyle(color: Color(0xFF888888))),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final chave = _chaveController.text.trim();
                    if (chave.isNotEmpty) {
                      final resultado =
                          await notifier.validarChaveAtivacao(chave);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(resultado['mensagem'] ?? ''),
                            backgroundColor: resultado['ativado'] == true
                                ? const Color(0xFF107C41)
                                : Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Validar e Ativar Licença'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
