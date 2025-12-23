import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/core/config/api_config.dart';
import 'package:app/core/api/api_exception.dart';
import 'package:app/core/auth/auth_service.dart';

/// Cliente API per comunicare con il backend
/// Gestisce JWT, refresh token automatico, errori e timeout
class ApiClient {
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;
  final AuthService _authService;
  bool _isRefreshing = false;

  ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
    required AuthService authService,
  })  : _client = client ?? http.Client(),
        _authService = authService;

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requireAuth = true,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    return _request('GET', uri, requireAuth: requireAuth);
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    final uri = _buildUri(endpoint);
    return _request('POST', uri, body: body, requireAuth: requireAuth);
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    return _request('PUT', uri, body: body, requireAuth: requireAuth);
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    return _request('DELETE', uri, requireAuth: requireAuth);
  }

  /// Esegue una richiesta HTTP
  Future<Map<String, dynamic>> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      // Prepara headers
      final headers = await _buildHeaders(requireAuth: requireAuth);

      // Prepara request
      http.Response response;
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(timeout);
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(timeout);
          break;
        default:
          throw ApiException(0, 'Metodo HTTP non supportato: $method');
      }

      // Gestisci risposta
      return await _handleResponse(response, method, uri, body, requireAuth);
    } on http.ClientException catch (e) {
      throw ConnectionException('Errore di connessione: ${e.message}', originalException: e);
    } on FormatException catch (e) {
      throw ApiException(0, 'Errore nel parsing della risposta: ${e.message}');
    } catch (e) {
      if (e is ApiException || e is ConnectionException) {
        rethrow;
      }
      throw ConnectionException('Errore sconosciuto: $e');
    }
  }

  /// Gestisce la risposta HTTP
  Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
    String method,
    Uri uri,
    Map<String, dynamic>? body,
    bool requireAuth,
  ) async {
    // Se 401 e richiede auth, prova refresh token
    if (response.statusCode == 401 && requireAuth && !_isRefreshing) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Riprova la richiesta originale
        return _request(method, uri, body: body, requireAuth: requireAuth);
      }
    }

    // Gestisci errori HTTP
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }

    // Parse JSON
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Backend restituisce { success: true, data: {...} }
      if (json['success'] == true && json.containsKey('data')) {
        return json['data'] as Map<String, dynamic>;
      }
      
      // Se non ha il formato standard, restituisci tutto il JSON
      return json;
    } catch (e) {
      throw ApiException(
        response.statusCode,
        'Errore nel parsing della risposta JSON: $e',
      );
    }
  }

  /// Costruisce gli header della richiesta
  Future<Map<String, String>> _buildHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = _authService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Tenta di fare refresh del token
  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    try {
      final refreshToken = _authService.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final uri = _buildUri('/auth/refresh');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json.containsKey('data')) {
          final data = json['data'] as Map<String, dynamic>;
          final accessToken = data['accessToken'] as String;
          final expiresIn = data['expiresIn'] as int? ?? 900;

          await _authService.updateAccessToken(
            accessToken: accessToken,
            expiresInSeconds: expiresIn,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Costruisce l'URI completo
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    // Rimuove slash iniziale se presente
    final cleanEndpoint = endpoint.startsWith('/') 
        ? endpoint.substring(1) 
        : endpoint;
    
    final url = '$baseUrl/api/${ApiConfig.apiVersion}/$cleanEndpoint';
    final uri = Uri.parse(url);
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    
    return uri;
  }

  /// Chiude il client HTTP
  void close() {
    _client.close();
  }
}
