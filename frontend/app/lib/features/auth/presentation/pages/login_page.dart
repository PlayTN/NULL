import 'package:flutter/cupertino.dart';
import 'package:app/core/di/app_dependencies.dart';
import 'package:app/core/styles/app_colors.dart';
import 'package:app/core/api/api_exception.dart';
import 'package:app/core/theme/theme_manager.dart';

class LoginPage extends StatefulWidget {
  final Function(bool) onLoginSuccess;
  final ThemeManager themeManager;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.themeManager,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _codiceFiscaleController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codiceFiscaleController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String tipoAutenticazione) async {
    final codiceFiscale = _codiceFiscaleController.text.trim().toUpperCase();

    // Validazione codice fiscale
    if (codiceFiscale.isEmpty) {
      setState(() {
        _errorMessage = 'Inserisci il codice fiscale';
      });
      return;
    }

    if (codiceFiscale.length != 16) {
      setState(() {
        _errorMessage = 'Il codice fiscale deve essere di 16 caratteri';
      });
      return;
    }

    if (!RegExp(r'^[A-Z0-9]{16}$').hasMatch(codiceFiscale)) {
      setState(() {
        _errorMessage = 'Codice fiscale non valido';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepository = AppDependencies.authRepository;
      if (authRepository == null) {
        throw Exception('Servizio di autenticazione non disponibile');
      }

      final loginResponse = await authRepository.login(
        codiceFiscale: codiceFiscale,
        tipoAutenticazione: tipoAutenticazione,
      );

      // Salva i token
      final authService = AppDependencies.authService;
      if (authService != null) {
        await authService.saveTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          expiresInSeconds: loginResponse.expiresIn,
        );
      }

      if (mounted) {
        widget.onLoginSuccess(true);
        Navigator.of(context).pop();
      }
    } on ValidationException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore durante il login: $e';
        _isLoading = false;
      });
    }
  }

  void _showLoginDialog(String tipoAutenticazione, String tipoLabel) {
    final isDark = widget.themeManager.isDarkMode;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Accedi con $tipoLabel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _codiceFiscaleController,
              placeholder: 'Codice Fiscale (16 caratteri)',
              maxLength: 16,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _errorMessage != null
                      ? CupertinoColors.systemRed
                      : AppColors.borderSecondary(isDark),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              _codiceFiscaleController.clear();
              setState(() {
                _errorMessage = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Annulla'),
          ),
          CupertinoDialogAction(
            onPressed: _isLoading
                ? null
                : () async {
                    Navigator.of(context).pop();
                    await _handleLogin(tipoAutenticazione);
                  },
            child: _isLoading
                ? const CupertinoActivityIndicator()
                : const Text('Accedi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeManager,
      builder: (context, _) {
        final isDark = widget.themeManager.isDarkMode;

        return CupertinoPageScaffold(
          backgroundColor: AppColors.background(isDark),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColors.surface(isDark),
            middle: Text(
              'Accedi',
              style: TextStyle(
                color: AppColors.text(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: CupertinoNavigationBarBackButton(
              color: AppColors.primary(isDark),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Schermata di benvenuto (parte superiore)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.person_crop_circle_fill,
                            size: 80,
                            color: AppColors.primary(isDark),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Benvenuto in NULL',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text(isDark),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Accedi per utilizzare tutti i servizi',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary(isDark),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pulsanti di login (parte inferiore)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Pulsante Login con SPID
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(12),
                          onPressed: _isLoading
                              ? null
                              : () => _showLoginDialog('spid', 'SPID'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.shield_fill,
                                color: CupertinoColors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Accedi con SPID',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Pulsante Login con CIE
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primary(isDark),
                          onPressed: _isLoading
                              ? null
                              : () => _showLoginDialog('cie', 'CIE'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.creditcard_fill,
                                color: CupertinoColors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Accedi con CIE',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(height: 16),
                        const CupertinoActivityIndicator(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

