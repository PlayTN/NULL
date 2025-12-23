import 'package:app/core/api/api_client.dart';
import 'package:app/core/auth/auth_service.dart';
import 'package:app/core/config/api_config.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/cells/domain/repositories/cell_repository.dart';
import 'package:app/features/cells/data/repositories/cell_repository_mock.dart';
import 'package:app/features/lockers/data/repositories/locker_repository_impl.dart';
import 'package:app/features/lockers/data/repositories/locker_repository_mock.dart';
import 'package:app/features/lockers/domain/repositories/locker_repository.dart';

/// Dependency Injection per l'app
/// 
/// Gestisce l'inizializzazione e l'iniezione delle dipendenze
class AppDependencies {
  static const bool useMockData = false; // Usa repository reali

  // Singleton instances
  static ApiClient? _apiClient;
  static AuthService? _authService;
  static AuthRepository? _authRepository;

  /// Inizializza le dipendenze (chiamare all'avvio dell'app)
  static Future<void> initialize() async {
    if (!useMockData) {
      _authService = await AuthService.getInstance();
      _apiClient = ApiClient(
        baseUrl: ApiConfig.baseUrl,
        timeout: ApiConfig.timeout,
        authService: _authService!,
      );
      _authRepository = AuthRepositoryImpl(apiClient: _apiClient!);
    }
  }

  /// Repository per i lockers
  static LockerRepository get lockerRepository {
    if (useMockData) {
      return LockerRepositoryMock();
    } else {
      // In test o se initialize() non è stato chiamato, evita crash e usa mock.
      final client = _apiClient;
      if (client == null) {
        return LockerRepositoryMock();
      }
      return LockerRepositoryImpl(apiClient: client);
    }
  }

  /// Repository per l'autenticazione
  static AuthRepository? get authRepository {
    if (useMockData) {
      return null; // Mock auth non implementato
    }
    return _authRepository;
  }

  /// Servizio di autenticazione
  static AuthService? get authService {
    if (useMockData) {
      return null;
    }
    return _authService;
  }

  /// Client API
  static ApiClient? get apiClient {
    if (useMockData) {
      return null;
    }
    return _apiClient;
  }

  /// Repository per gestire le celle attive
  /// 
  /// **Nota**: Il repository mock è un singleton per mantenere i dati in memoria
  static CellRepository? get cellRepository {
    if (useMockData) {
      return CellRepositoryMock(); // Singleton, mantiene i dati tra le chiamate
    } else {
      // Il backend live attualmente non espone endpoint per "active cells"/storico/apertura.
      // Manteniamo quindi il mock *solo* per queste feature, evitando null crash nelle pagine.
      return CellRepositoryMock();
    }
  }
}

