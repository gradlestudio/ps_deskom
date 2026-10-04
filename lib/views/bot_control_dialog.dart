import 'package:flutter/material.dart';
import '../services/bot_manager_service.dart';

class BotControlDialog extends StatefulWidget {
  const BotControlDialog({super.key});

  @override
  State<BotControlDialog> createState() => _BotControlDialogState();
}

class _BotControlDialogState extends State<BotControlDialog> {
  final BotManagerService _botService = BotManagerService();
  final ScrollController _scrollController = ScrollController();
  final StringBuffer _logsConsole = StringBuffer();

  bool _isCarregando = false;
  bool _isOnline = false;
  String _statusTexto = 'Verificando...';

  @override
  void initState() {
    super.initState();
    _atualizarStatus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _atualizarStatus() async {
    final statusMap = await _botService.getStatus();
    if (mounted) {
      setState(() {
        _isOnline = statusMap['online'] == true;
        _statusTexto = _isOnline ? 'Online (PID: ${statusMap['pid']})' : 'Parado (Stopped)';
      });
    }
  }

  void _adicionarSaida(String titulo, String resultado) {
    if (!mounted) return;
    setState(() {
      _logsConsole.writeln('===========================================================');
      _logsConsole.writeln('  $titulo -- ${DateTime.now().toString().substring(11, 19)}');
      _logsConsole.writeln('===========================================================');
      _logsConsole.writeln(resultado.trim());
      _logsConsole.writeln('');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _executarAcao(String titulo, Future<String> Function() acao) async {
    setState(() => _isCarregando = true);
    final resultado = await acao();
    _adicionarSaida(titulo, resultado);
    await _atualizarStatus();
    if (mounted) {
      setState(() => _isCarregando = false);
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
        constraints: const BoxConstraints(
          maxWidth: 880,
          minWidth: 800,
          maxHeight: 620,
        ),
        width: 880,
        height: 620,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho Principal do Painel de Controle
            Row(
              children: [
                const Icon(Icons.smart_toy_outlined, color: Color(0xFF0078D4), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Gerenciador Grad Bot (PM2 Control)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // Badge de Status Online/Offline
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isOnline
                        ? const Color(0xFF107C41).withValues(alpha: 0.25)
                        : const Color(0xFFD13438).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isOnline ? const Color(0xFF107C41) : const Color(0xFFD13438),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isOnline ? const Color(0xFF107C41) : const Color(0xFFD13438),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusTexto,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? const Color(0xFF4EC9B0) : const Color(0xFFF1707A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Color(0xFF888888), size: 20),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF3F3F46), height: 1),
            const SizedBox(height: 12),

            // Barra de Ações Rápidas do Bot
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _isCarregando
                      ? null
                      : () => _executarAcao('ESTADO DA EXECUÇÃO (PM2 LIST)', () => _botService.getList()),
                  icon: const Icon(Icons.list_alt_outlined, size: 14),
                  label: const Text('Estado da Execução', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCCCCCC),
                    side: const BorderSide(color: Color(0xFF3F3F46)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isCarregando
                      ? null
                      : () => _executarAcao('CONSULTA DE LOGS (PM2 LOGS)', () => _botService.getLogs()),
                  icon: const Icon(Icons.receipt_long_outlined, size: 14),
                  label: const Text('Consultar Logs', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCCCCCC),
                    side: const BorderSide(color: Color(0xFF3F3F46)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isCarregando
                      ? null
                      : () => _executarAcao('REINICIAR BOT (PM2 RESTART)', () => _botService.restartBot()),
                  icon: const Icon(Icons.refresh_outlined, size: 14),
                  label: const Text('Reiniciar Bot', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0078D4),
                    side: const BorderSide(color: Color(0xFF0078D4)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isCarregando
                      ? null
                      : () => _executarAcao('INICIAR BOT (PM2 START)', () => _botService.startBot()),
                  icon: const Icon(Icons.play_arrow_outlined, size: 14),
                  label: const Text('Iniciar Bot', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF107C41),
                    side: const BorderSide(color: Color(0xFF107C41)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isCarregando
                      ? null
                      : () => _executarAcao('PARAR BOT (PM2 STOP)', () => _botService.stopBot()),
                  icon: const Icon(Icons.stop_circle_outlined, size: 14),
                  label: const Text('Parar Bot', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD13438),
                    side: const BorderSide(color: Color(0xFFD13438)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Console estilo Terminal para exibição de comandos e logs PM2 com suporte a scroll horizontal
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF3F3F46)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.terminal_outlined, color: Color(0xFF888888), size: 14),
                        const SizedBox(width: 6),
                        const Text(
                          'CONSOLE DE SAÍDA PM2',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF888888),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => setState(() => _logsConsole.clear()),
                          child: const Text(
                            'Limpar Console',
                            style: TextStyle(fontSize: 10, color: Color(0xFF0078D4)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFF21262D), height: 1),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectionArea(
                            child: Text(
                              _logsConsole.isEmpty
                                  ? 'Aguardando ação do operador... Clique em "Estado da Execução" ou "Consultar Logs".'
                                  : _logsConsole.toString(),
                              softWrap: false,
                              style: const TextStyle(
                                fontFamily: 'Consolas',
                                fontSize: 12.5,
                                color: Color(0xFFCCCCCC),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
