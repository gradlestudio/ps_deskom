import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  final Map<String, dynamic> dados;

  const UpdateDialog({
    super.key,
    required this.dados,
  });

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final versaoRecente = dados['versao_recente'] as String? ?? '1.1.0';
    final downloadUrl = dados['download_url'] as String? ?? '';
    final novidades = List<String>.from(dados['novidades'] ?? []);

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
                const Icon(Icons.system_update_outlined,
                    color: Color(0xFF107C41), size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Nova Versão Disponível!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF107C41).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF107C41)),
                  ),
                  child: const Text(
                    'Gratuita e Vitalícia',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4EC9B0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF3F3F46), height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                const Text(
                  'Versão Atual: 1.0.0',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF107C41)),
                const SizedBox(width: 8),
                Text(
                  'Nova Versão: $versaoRecente',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4EC9B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'O QUE HÁ DE NOVO:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFCCCCCC),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              constraints: const BoxConstraints(maxHeight: 140),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF252526),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: novidades.isEmpty
                      ? [
                          const Text('• Melhorias de desempenho e correções gerais.',
                              style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)))
                        ]
                      : novidades
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text('• $item',
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFFCCCCCC))),
                              ))
                          .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Lembrar Mais Tarde',
                      style: TextStyle(color: Color(0xFF888888))),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (downloadUrl.isNotEmpty) {
                      _abrirUrl(downloadUrl);
                    }
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Baixar Atualização'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF107C41),
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
