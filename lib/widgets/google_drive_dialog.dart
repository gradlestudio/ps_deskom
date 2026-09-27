import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleDriveDialog extends StatelessWidget {
  const GoogleDriveDialog({super.key});

  Future<void> _baixarGoogleDrive() async {
    final uri = Uri.parse('https://www.google.com/drive/download/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              children: const [
                Icon(Icons.cloud_off_outlined,
                    color: Color(0xFF0078D4), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Google Drive Desktop Não Detectado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF3F3F46), height: 1),
            const SizedBox(height: 14),

            const Text(
              'Para integrar pastas e transferir arquivos diretamente com a sua nuvem através do PS DesKom, é necessário que o aplicativo oficial do Google Drive para Desktop esteja instalado e sincronizado no Windows.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFCCCCCC),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido',
                      style: TextStyle(color: Color(0xFF888888))),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _baixarGoogleDrive();
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Baixar Google Drive'),
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
