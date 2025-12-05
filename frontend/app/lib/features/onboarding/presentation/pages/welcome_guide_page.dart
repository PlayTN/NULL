import 'package:flutter/cupertino.dart';
import 'package:app/core/theme/theme_manager.dart';
import 'package:app/core/styles/app_colors.dart';
import 'package:app/core/styles/app_text_styles.dart';
import 'package:app/core/storage/app_storage.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';

/// Pagina di benvenuto e guida iniziale dell'applicazione
/// 
/// Mostra una breve guida che spiega il funzionamento dell'app.
/// Viene mostrata solo la prima volta che l'utente apre l'applicazione.
class WelcomeGuidePage extends StatefulWidget {
  final ThemeManager themeManager;

  const WelcomeGuidePage({
    super.key,
    required this.themeManager,
  });

  @override
  State<WelcomeGuidePage> createState() => _WelcomeGuidePageState();
}

class _WelcomeGuidePageState extends State<WelcomeGuidePage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<GuideStep> _steps = [
    GuideStep(
      icon: CupertinoIcons.map_fill,
      title: 'Trova i lockers',
      description: 'Esplora la mappa per trovare i lockers disponibili nella città di Trento. Tocca un marker per vedere i dettagli.',
    ),
    GuideStep(
      icon: CupertinoIcons.search,
      title: 'Cerca e filtra',
      description: 'Usa la barra di ricerca per trovare lockers specifici o filtra per categoria (sport, libri, giochi, ecc.).',
    ),
    GuideStep(
      icon: CupertinoIcons.lock_fill,
      title: 'Prenota una cella',
      description: 'Seleziona un locker e prenota una cella disponibile. Puoi usarla per depositare oggetti, prenderli in prestito o ritirare ordini.',
    ),
    GuideStep(
      icon: CupertinoIcons.bell_fill,
      title: 'Resta aggiornato',
      description: 'Ricevi notifiche su prenotazioni, scadenze e aggiornamenti. Tutto nella sezione Notifiche dell\'app.',
    ),
    GuideStep(
      icon: CupertinoIcons.person_crop_circle_fill,
      title: 'Gestisci il tuo profilo',
      description: 'Accedi per vedere lo storico delle tue prenotazioni, gestire le donazioni e accedere a tutte le funzionalità.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeGuide();
    }
  }

  void _skipGuide() {
    _completeGuide();
  }

  Future<void> _completeGuide() async {
    // Salva che la guida è stata mostrata
    await AppStorage.setGuideShown(true);
    await AppStorage.setFirstLaunchComplete();

    // Naviga alla home page
    if (mounted) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => HomePage(
            themeManager: widget.themeManager,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeManager,
      builder: (context, _) {
        final isDark = widget.themeManager.isDarkMode;

        return CupertinoPageScaffold(
          backgroundColor: AppColors.background(isDark),
          child: SafeArea(
            child: Column(
              children: [
                // Header con pulsante skip
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 60), // Spazio per centrare il logo
                      // Logo o titolo
                      Text(
                        'NULL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary(isDark),
                        ),
                      ),
                      // Pulsante Skip
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: _skipGuide,
                        child: Text(
                          'Salta',
                          style: TextStyle(
                            color: AppColors.primary(isDark),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // PageView con i passi della guida
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return _buildStepPage(step, isDark);
                    },
                  ),
                ),

                // Indicatori di pagina
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primary(isDark)
                              : AppColors.textSecondary(isDark).withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pulsante Avanti/Inizia
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _steps.length - 1
                            ? 'Inizia'
                            : 'Avanti',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepPage(GuideStep step, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icona
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary(isDark).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: AppColors.primary(isDark),
            ),
          ),
          const SizedBox(height: 48),
          
          // Titolo
          Text(
            step.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Descrizione
          Text(
            step.description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary(isDark),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Classe per rappresentare un passo della guida
class GuideStep {
  final IconData icon;
  final String title;
  final String description;

  GuideStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}

