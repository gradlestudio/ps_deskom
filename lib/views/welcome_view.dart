import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../providers/commander_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/activation_dialog.dart';

class WelcomeView extends ConsumerStatefulWidget {
  const WelcomeView({super.key});

  @override
  ConsumerState<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends ConsumerState<WelcomeView> {
  Future<void> _concluirOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _exibirDialogoAtivacao() {
    showDialog(
      context: context,
      builder: (_) => const ActivationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final state = ref.watch(commanderProvider);
    const String envEdition = String.fromEnvironment('APP_EDITION', defaultValue: '');
    final bool isMaster = envEdition == 'MASTER' || state.statusLicencaTexto.contains('Master');

    final idiomas = [
      {'locale': const Locale('pt', 'BR'), 'code': 'PT', 'name': 'Português', 'flag': 'assets/flags/br.gif'},
      {'locale': const Locale('en', 'US'), 'code': 'EN', 'name': 'English', 'flag': 'assets/flags/uk.gif'},
      {'locale': const Locale('de', 'DE'), 'code': 'DE', 'name': 'Deutsch', 'flag': 'assets/flags/de.gif'},
      {'locale': const Locale('es', 'ES'), 'code': 'ES', 'name': 'Español', 'flag': 'assets/flags/es.gif'},
      {'locale': const Locale('fr', 'FR'), 'code': 'FR', 'name': 'Français', 'flag': 'assets/flags/fr.gif'},
      {'locale': const Locale('it', 'IT'), 'code': 'IT', 'name': 'Italiano', 'flag': 'assets/flags/it.gif'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animação Suave de Entrada da Logo Principal do Produto
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.85 + (0.15 * value),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/PS DesKom.png',
                        height: 110,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.terminal,
                          size: 90,
                          color: Color(0xFF0078D4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n?.bemVindoTitulo ?? 'Bem-vindo ao PS DesKom',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (isMaster) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF107C41).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF107C41)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Color(0xFF4EC9B0), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              l10n?.edicaoMasterAtiva ?? 'Edição Master — Administrador Ativo',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4EC9B0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text(
                l10n?.bemVindoSubtitulo ?? 'Selecione o seu idioma de preferência para começar:',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 20),

              // Seletor de Idiomas em Grade Interativa com Bandeiras em GIF
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: idiomas.map((item) {
                  final itemLocale = item['locale'] as Locale;
                  final isSelected = currentLocale.languageCode == itemLocale.languageCode;

                  return InkWell(
                    onTap: () {
                      ref.read(localeProvider.notifier).setLocale(itemLocale);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 140,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0078D4).withValues(alpha: 0.25)
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0078D4) : const Color(0xFF3F3F46),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Image.asset(
                              item['flag'] as String,
                              width: 26,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : const Color(0xFFCCCCCC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Ações Rápidas do Onboarding
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _exibirDialogoAtivacao,
                    icon: const Icon(Icons.key_outlined, size: 18),
                    label: Text(
                      l10n?.ativacaoLicenca ?? 'Ativação de Licença',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4EC9B0),
                      side: const BorderSide(color: Color(0xFF4EC9B0)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _concluirOnboarding,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(
                      l10n?.iniciarSistema ?? 'Iniciar PS DesKom',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Rodapé / Assinatura do Desenvolvedor
              Text(
                l10n?.desenvolvidoPor ?? 'Desenvolvido por Gradle Studio',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/Gradle Studio.png',
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.code,
                    size: 32,
                    color: Color(0xFF4EC9B0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
