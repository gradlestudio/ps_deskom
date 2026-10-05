import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/google_auth_service.dart';

class GoogleLoginDialog extends StatefulWidget {
  const GoogleLoginDialog({super.key});

  @override
  State<GoogleLoginDialog> createState() => _GoogleLoginDialogState();
}

class _GoogleLoginDialogState extends State<GoogleLoginDialog> {
  final GoogleAuthService _authService = GoogleAuthService();
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userPicture = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarEstadoConta();
  }

  Future<void> _carregarEstadoConta() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('google_user_email');
    final name = prefs.getString('google_user_name');
    final picture = prefs.getString('google_user_picture');

    if (mounted) {
      setState(() {
        _isLoggedIn = email != null && email.isNotEmpty;
        _userEmail = email ?? '';
        _userName = name ?? '';
        _userPicture = picture ?? '';
      });
    }
  }

  Future<void> _fazerLoginGoogle() async {
    setState(() => _isLoading = true);

    try {
      final perfil = await _authService.authenticateGoogleDesktop();
      if (mounted && perfil != null && (perfil['email']?.isNotEmpty ?? false)) {
        setState(() {
          _isLoading = false;
          _isLoggedIn = true;
          _userEmail = perfil['email'] ?? '';
          _userName = perfil['name'] ?? '';
          _userPicture = perfil['picture'] ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login com Google efetuado com sucesso!'),
            backgroundColor: Color(0xFF107C41),
          ),
        );
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no login com Google: $e')),
        );
      }
    }
  }

  Future<void> _desconectarConta() async {
    await _authService.logout();

    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userEmail = '';
        _userName = '';
        _userPicture = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta Google desconectada.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF0078D4)),
      ),
      title: Row(
        children: [
          const Icon(Icons.account_circle_outlined, color: Color(0xFF0078D4), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isLoggedIn ? 'Conta Google Conectada' : l10n.entrarComGoogle,
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isLoggedIn) ...[
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF0078D4),
                backgroundImage: _userPicture.isNotEmpty ? NetworkImage(_userPicture) : null,
                child: _userPicture.isEmpty
                    ? const Icon(Icons.person, size: 36, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _userName.isNotEmpty ? _userName : 'Usuário Google',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                _userEmail,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4EC9B0), fontFamily: 'Consolas'),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF107C41).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF107C41)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF107C41), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Sincronização com Google Drive Habilitada',
                      style: TextStyle(fontSize: 11, color: Color(0xFF4EC9B0), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Icon(Icons.cloud_outlined, size: 54, color: Color(0xFF0078D4)),
              const SizedBox(height: 12),
              const Text(
                'Conecte sua conta do Google para integração direta com o Google Drive Desktop e backup na nuvem.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _fazerLoginGoogle,
                icon: _isLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.login, size: 18),
                label: Text(
                  l10n.entrarComGoogle,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0078D4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.fechar, style: const TextStyle(color: Color(0xFF888888))),
        ),
        if (_isLoggedIn)
          ElevatedButton.icon(
            onPressed: _desconectarConta,
            icon: const Icon(Icons.logout, size: 14),
            label: Text(l10n.desconectarConta),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}
