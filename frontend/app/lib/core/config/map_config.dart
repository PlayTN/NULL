class MapConfig {
  const MapConfig._();

  // Centro della mappa: Trento
  static const double centerLat = 46.0700;
  static const double centerLng = 11.1200;

  // Zoom levels
  static const double defaultZoom = 13.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;
  static const double userLocationZoom = 15.0;

  // Tile provider per light mode (CartoDB Positron - minimal e pulito)
  static const String tileUrlTemplateLight =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
  
  // Tile provider per dark mode (CartoDB Dark Matter - minimal e scuro)
  static const String tileUrlTemplateDark =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
  
  // Subdomains per il tile server (per distribuire il carico)
  static const List<String> tileSubdomains = ['a', 'b', 'c', 'd'];
  
  // User agent per richieste HTTP (compatibilità cross-platform)
  static const String userAgent = 'NULL App/1.0';
  
  // Timeout per caricamento tile (in secondi)
  static const Duration tileLoadTimeout = Duration(seconds: 10);
  
  // Ottiene il tile provider in base al tema
  static String getTileUrlTemplate(bool isDark) {
    return isDark ? tileUrlTemplateDark : tileUrlTemplateLight;
  }
}


