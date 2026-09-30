import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../providers/commander_provider.dart';
import 'activation_dialog.dart';
import 'manual_help_dialog.dart';

class AboutDialogWidget extends ConsumerStatefulWidget {
  const AboutDialogWidget({super.key});

  @override
  ConsumerState<AboutDialogWidget> createState() => _AboutDialogWidgetState();
}

class _AboutDialogWidgetState extends ConsumerState<AboutDialogWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarScrollInfinito();
    });
  }

  void _iniciarScrollInfinito() async {
    await Future.delayed(const Duration(milliseconds: 300));
    while (mounted) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          await _scrollController.animateTo(
            maxScroll,
            duration: const Duration(seconds: 16),
            curve: Curves.linear,
          );
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted && _scrollController.hasClients) {
            await _scrollController.animateTo(
              0.0,
              duration: const Duration(seconds: 16),
              curve: Curves.linear,
            );
          }
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _exibirSubdialogoLicenca(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ActivationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commanderProvider);
    final statusTexto = state.statusLicencaTexto;
    final isAtivado = state.softwareAtivado;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF3F3F46)),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com Logo e Título
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/Gradle Studio.png',
                    height: 75,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 75,
                      height: 75,
                      color: const Color(0xFF252526),
                      child: const Icon(Icons.terminal,
                          size: 40, color: Color(0xFF0078D4)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'PS DesKom',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isAtivado
                                  ? const Color(0xFF107C41).withValues(alpha: 0.2)
                                  : const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isAtivado
                                    ? const Color(0xFF107C41)
                                    : const Color(0xFF3F3F46),
                              ),
                            ),
                            child: Text(
                              statusTexto,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isAtivado
                                    ? const Color(0xFF4EC9B0)
                                    : const Color(0xFFCCCCCC),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n?.versao ?? 'Versão 1.0.0 (Build 2026)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4EC9B0),
                          fontFamily: 'Consolas',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n?.desenvolvidoPor ?? 'Desenvolvido por Gradle Studio',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
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

            // Área Central: Créditos em Rolagem Contínua estilo Cinema
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ListView(
                      controller: _scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          l10n?.arquiteturaEngenharia ?? 'ARQUITETURA & ENGENHARIA DE SOFTWARE',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF888888),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pietro Villani',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n?.producaoDesign ?? 'PRODUÇÃO & DESIGN',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF888888),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Gradle Studio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0078D4),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n?.tecnologiasNativas ?? 'TECNOLOGIAS NATIVAS',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF888888),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Flutter Desktop & Windows PowerShell Core',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n?.avisoLegalEula ?? 'AVISO LEGAL & EULA',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD13438),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            l10n?.textoAvisoLegal ??
                                'Este software é disponibilizado no estado em que se encontra ("AS IS"), sem garantias expressas ou implícitas. O usuário é inteiramente responsável por validar e confirmar exclusões e modificações em seus discos e partições.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF888888),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.direitosReservados ?? 'Todos os direitos reservados © 2026 Gradle Studio.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),

                  // Gradiente superior de Fade Out
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 24,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF161616), Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // Gradiente inferior de Fade Out
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 24,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF161616), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFF3F3F46), height: 1),
            const SizedBox(height: 12),

            // Seção de Ações Rápidas
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(commanderProvider.notifier).checarAtualizacaoManual(context),
                  icon: const Icon(Icons.system_update_outlined, size: 14),
                  label: Text(l10n?.verificarAtualizacoes ?? 'Verificar Atualizações', style: const TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCCCCCC),
                    side: const BorderSide(color: Color(0xFF3F3F46)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _exibirSubdialogoLicenca(context),
                  icon: const Icon(Icons.key_outlined, size: 14),
                  label: Text(l10n?.ativacaoLicenca ?? 'Ativação de Licença', style: const TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4EC9B0),
                    side: const BorderSide(color: Color(0xFF4EC9B0)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const ManualHelpDialog(),
                    );
                  },
                  icon: const Icon(Icons.help_outline, size: 14),
                  label: Text(l10n?.manualAjuda ?? 'Manual / Ajuda', style: const TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCCCCCC),
                    side: const BorderSide(color: Color(0xFF3F3F46)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Rodapé com Links Sociais e Botão Fechar
            Row(
              children: [
                IconButton(
                  onPressed: () => _abrirUrl('https://instagram.com/gradlestudio.dev'),
                  icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFFE1306C), size: 20),
                  tooltip: 'Instagram: @gradlestudio.dev',
                ),
                IconButton(
                  onPressed: () => _abrirUrl('https://wa.me/5585996421006'),
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 20),
                  tooltip: 'WhatsApp: +55 85 99642-1006',
                ),
                IconButton(
                  onPressed: () => _abrirUrl('mailto:gradlestudio.dev@gmail.com'),
                  icon: const Icon(Icons.email_outlined, color: Color(0xFF0078D4), size: 20),
                  tooltip: 'E-mail: gradlestudio.dev@gmail.com',
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D2D2D),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n?.fechar ?? 'Fechar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
