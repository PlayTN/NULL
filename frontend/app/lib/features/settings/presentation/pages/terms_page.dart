import 'package:flutter/cupertino.dart';
import 'package:app/core/theme/theme_manager.dart';
import 'package:app/core/styles/app_colors.dart';
import 'package:app/core/styles/app_text_styles.dart';

/// Pagina con i termini e condizioni di utilizzo
class TermsPage extends StatelessWidget {
  final ThemeManager themeManager;

  const TermsPage({
    super.key,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        final isDark = themeManager.isDarkMode;

        return CupertinoPageScaffold(
          backgroundColor: AppColors.background(isDark),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColors.surface(isDark),
            middle: Text(
              'Termini e condizioni',
              style: AppTextStyles.title(isDark),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.shield_fill,
                          size: 48,
                          color: AppColors.primary(isDark),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Termini e condizioni di utilizzo',
                          style: AppTextStyles.title(isDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ultimo aggiornamento: ${_getLastUpdateDate()}',
                          style: AppTextStyles.bodySecondary(isDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contenuto
                  _buildSection(
                    isDark: isDark,
                    title: '1. Accettazione dei termini',
                    content:
                        'Utilizzando l\'app NULL, accetti di rispettare questi termini e condizioni. Se non accetti questi termini, ti preghiamo di non utilizzare l\'app.',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '2. Utilizzo del servizio',
                    content:
                        'L\'app NULL è un servizio fornito dal Comune di Trento per la gestione dei lockers pubblici. Il servizio è gratuito per tutti i cittadini di Trento. L\'utilizzo dei lockers è soggetto alla disponibilità delle celle.',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '3. Responsabilità dell\'utente',
                    content:
                        'L\'utente è responsabile di:\n\n'
                        '• Utilizzare i lockers in modo corretto e rispettoso\n'
                        '• Non depositare oggetti pericolosi, illegali o di valore elevato\n'
                        '• Rispettare i tempi di utilizzo delle celle\n'
                        '• Mantenere la sicurezza delle proprie credenziali di accesso\n'
                        '• Segnalare eventuali problemi o malfunzionamenti',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '4. Limitazione di responsabilità',
                    content:
                        'Il Comune di Trento non si assume responsabilità per:\n\n'
                        '• Danni o perdite di oggetti depositati nei lockers\n'
                        '• Malfunzionamenti tecnici o interruzioni del servizio\n'
                        '• Utilizzo improprio dei lockers da parte degli utenti',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '5. Modifiche ai termini',
                    content:
                        'Il Comune di Trento si riserva il diritto di modificare questi termini in qualsiasi momento. Le modifiche saranno comunicate agli utenti tramite l\'app o altri canali ufficiali.',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '6. Contatti',
                    content:
                        'Per domande o chiarimenti sui termini e condizioni, puoi contattare il supporto all\'indirizzo supporto@null.trento.it o al numero +39 0461 123456.',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.text(isDark),
            ),
          ),
        ],
      ),
    );
  }

  String _getLastUpdateDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}

