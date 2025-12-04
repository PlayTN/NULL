import 'package:flutter/cupertino.dart';
import 'package:app/core/theme/theme_manager.dart';
import 'package:app/core/styles/app_colors.dart';
import 'package:app/core/styles/app_text_styles.dart';

/// Pagina con l'informativa sulla privacy
class PrivacyPolicyPage extends StatelessWidget {
  final ThemeManager themeManager;

  const PrivacyPolicyPage({
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
              'Informativa sulla privacy',
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
                          CupertinoIcons.doc_text_fill,
                          size: 48,
                          color: AppColors.primary(isDark),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Informativa sulla privacy',
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
                    title: '1. Titolare del trattamento',
                    content:
                        'Il titolare del trattamento dei dati personali è il Comune di Trento, con sede in Via Manci, 2 - 38122 Trento. Per contatti: privacy@comune.trento.it',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '2. Dati raccolti',
                    content:
                        'L\'app NULL raccoglie i seguenti dati personali:\n\n'
                        '• Dati di registrazione (nome, email, telefono)\n'
                        '• Dati di utilizzo (storico prenotazioni, celle utilizzate)\n'
                        '• Dati di localizzazione (posizione GPS per trovare i lockers più vicini)\n'
                        '• Dati tecnici (indirizzo IP, tipo di dispositivo, sistema operativo)',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '3. Finalità del trattamento',
                    content:
                        'I dati personali vengono utilizzati per:\n\n'
                        '• Fornire i servizi dell\'app (prenotazione celle, gestione account)\n'
                        '• Migliorare l\'esperienza utente e il funzionamento dell\'app\n'
                        '• Comunicare con l\'utente per questioni relative al servizio\n'
                        '• Rispettare obblighi di legge e regolamentari',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '4. Base giuridica',
                    content:
                        'Il trattamento dei dati personali si basa su:\n\n'
                        '• Consenso dell\'interessato\n'
                        '• Esecuzione di un contratto (fornitura del servizio)\n'
                        '• Interesse legittimo del titolare (miglioramento del servizio)\n'
                        '• Obblighi di legge',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '5. Conservazione dei dati',
                    content:
                        'I dati personali vengono conservati per il tempo necessario alle finalità per cui sono stati raccolti, e comunque non oltre i termini previsti dalla legge. I dati di utilizzo vengono conservati per un massimo di 2 anni dalla data di ultimo utilizzo.',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '6. Diritti dell\'interessato',
                    content:
                        'Ai sensi del GDPR, l\'utente ha diritto a:\n\n'
                        '• Accedere ai propri dati personali\n'
                        '• Richiedere la rettifica o la cancellazione dei dati\n'
                        '• Opporsi al trattamento dei dati\n'
                        '• Richiedere la limitazione del trattamento\n'
                        '• Richiedere la portabilità dei dati\n'
                        '• Revocare il consenso in qualsiasi momento',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '7. Comunicazione dei dati',
                    content:
                        'I dati personali non vengono comunicati a terze parti, salvo:\n\n'
                        '• Fornitori di servizi tecnici (hosting, cloud) che operano come responsabili del trattamento\n'
                        '• Autorità competenti in caso di obblighi di legge\n'
                        '• Con il consenso esplicito dell\'utente',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '8. Sicurezza dei dati',
                    content:
                        'Il Comune di Trento adotta misure tecniche e organizzative appropriate per proteggere i dati personali da accesso non autorizzato, perdita, distruzione o alterazione.',
                  ),
                  _buildSection(
                    isDark: isDark,
                    title: '9. Contatti',
                    content:
                        'Per esercitare i propri diritti o per richiedere informazioni sul trattamento dei dati, l\'utente può contattare:\n\n'
                        'Email: privacy@comune.trento.it\n'
                        'Telefono: +39 0461 123456\n'
                        'Indirizzo: Comune di Trento, Via Manci, 2 - 38122 Trento',
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

