import 'package:shared_preferences/shared_preferences.dart';

/// Manager per gestire lo storage locale dell'applicazione
/// 
/// Utilizza SharedPreferences per salvare preferenze e stato dell'app
class AppStorage {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyGuideShown = 'guide_shown';

  /// Verifica se è la prima apertura dell'app
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Imposta che l'app è stata aperta almeno una volta
  static Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  /// Verifica se la guida è stata già mostrata
  static Future<bool> isGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGuideShown) ?? false;
  }

  /// Imposta che la guida è stata mostrata
  static Future<void> setGuideShown(bool shown) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGuideShown, shown);
  }
}

