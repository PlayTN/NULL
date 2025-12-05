import 'package:flutter/cupertino.dart';
import 'package:app/core/theme/theme_manager.dart';
import 'package:app/core/notifications/notification_service.dart';
import 'package:app/core/storage/app_storage.dart';
import 'package:app/features/home/presentation/pages/home_page.dart';
import 'package:app/features/onboarding/presentation/pages/welcome_guide_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza il servizio di notifiche
  await NotificationService().initialize();
  
  // Leggi il tema di sistema PRIMA di creare l'app
  final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  final isSystemDark = brightness == Brightness.dark;
  
  runApp(MyApp(initialDarkMode: isSystemDark));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  
  const MyApp({
    super.key,
    required this.initialDarkMode,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeManager _themeManager;
  Widget? _initialHome;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Passa il tema di sistema al ThemeManager
    _themeManager = ThemeManager(initialDarkMode: widget.initialDarkMode);
    _determineInitialHome();
  }

  /// Determina quale pagina mostrare all'avvio (guida o home)
  Future<void> _determineInitialHome() async {
    final isFirstLaunch = await AppStorage.isFirstLaunch();
    final isGuideShown = await AppStorage.isGuideShown();

    // Mostra la guida solo se è la prima apertura E la guida non è stata ancora mostrata
    final shouldShowGuide = isFirstLaunch && !isGuideShown;

    if (mounted) {
      setState(() {
        _initialHome = shouldShowGuide
            ? WelcomeGuidePage(themeManager: _themeManager)
            : HomePage(themeManager: _themeManager);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _themeManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeManager,
      builder: (context, _) {
        return CupertinoApp(
          title: 'NULL',
          theme: CupertinoThemeData(
            brightness: _themeManager.isDarkMode
                ? Brightness.dark
                : Brightness.light,
            primaryColor: const Color(0xFF007AFF),
          ),
          home: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _initialHome ?? HomePage(themeManager: _themeManager),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
