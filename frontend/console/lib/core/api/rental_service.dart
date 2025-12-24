import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class RentalService {
  /// Crea un nuovo affitto per una cella commerciale
  static Future<Map<String, dynamic>> createRental({
    required String cellaId,
    required String lockerId,
    required String nomeAzienda,
    String? codiceFiscale,
    String? partitaIva,
    String? dataScadenza,
    String? note,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Non autenticato. Effettua il login prima di creare un affitto.');
      }

      final body = <String, dynamic>{
        'cellaId': cellaId,
        'lockerId': lockerId,
        'nomeAzienda': nomeAzienda,
      };

      if (codiceFiscale != null && codiceFiscale.isNotEmpty) {
        body['codiceFiscale'] = codiceFiscale;
      }
      if (partitaIva != null && partitaIva.isNotEmpty) {
        body['partitaIva'] = partitaIva;
      }
      if (dataScadenza != null && dataScadenza.isNotEmpty) {
        body['dataScadenza'] = dataScadenza;
      }
      if (note != null && note.isNotEmpty) {
        body['note'] = note;
      }

      print('RentalService: Chiamata POST /admin/rentals con body: $body');

      final response = await ApiClient.post('/admin/rentals', body: body);

      print('RentalService: Status Code: ${response.statusCode}');
      print('RentalService: Response Body: ${response.body}');

      if (response.body.isEmpty || response.body.trim().isEmpty) {
        throw Exception('Risposta vuota dal server (HTTP ${response.statusCode})');
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Risposta non valida dal server: ${e.toString()}');
      }

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'affitto': data['data']['affitto'],
        };
      } else {
        String errorMessage = 'Errore durante la creazione dell\'affitto';
        if (data['error'] != null) {
          if (data['error'] is Map && data['error']['message'] != null) {
            errorMessage = data['error']['message'];
          } else if (data['error'] is String) {
            errorMessage = data['error'];
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('RentalService: Errore durante createRental: $e');
      return {
        'success': false,
        'error': 'Errore: ${e.toString()}',
      };
    }
  }

  /// Ottiene l'affitto attivo per una cella
  static Future<Map<String, dynamic>?> getRentalByCellId(String cellId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Non autenticato. Effettua il login prima di recuperare un affitto.');
      }

      print('RentalService: Chiamata GET /admin/rentals/cell/$cellId');

      final response = await ApiClient.get('/admin/rentals/cell/$cellId');

      print('RentalService: Status Code: ${response.statusCode}');
      print('RentalService: Response Body: ${response.body}');

      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return null;
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data']['affitto'] as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      print('RentalService: Errore durante getRentalByCellId: $e');
      return null;
    }
  }

  /// Ottiene tutti gli affitti attivi per un locker
  static Future<List<Map<String, dynamic>>> getRentalsByLockerId(String lockerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Non autenticato. Effettua il login prima di recuperare gli affitti.');
      }

      print('RentalService: Chiamata GET /admin/rentals/locker/$lockerId');

      final response = await ApiClient.get('/admin/rentals/locker/$lockerId');

      print('RentalService: Status Code: ${response.statusCode}');
      print('RentalService: Response Body: ${response.body}');

      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return [];
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return [];
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final items = data['data']['items'] as List<dynamic>?;
        return items?.map((item) => item as Map<String, dynamic>).toList() ?? [];
      }

      return [];
    } catch (e) {
      print('RentalService: Errore durante getRentalsByLockerId: $e');
      return [];
    }
  }

  /// Termina un affitto
  static Future<Map<String, dynamic>> terminateRental(String rentalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Non autenticato. Effettua il login prima di terminare un affitto.');
      }

      print('RentalService: Chiamata PUT /admin/rentals/$rentalId/terminate');

      final response = await ApiClient.put('/admin/rentals/$rentalId/terminate', body: {});

      print('RentalService: Status Code: ${response.statusCode}');
      print('RentalService: Response Body: ${response.body}');

      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return {
          'success': false,
          'error': 'Risposta vuota dal server (HTTP ${response.statusCode})',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {
          'success': false,
          'error': 'Risposta non valida dal server: ${e.toString()}',
        };
      }

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'affitto': data['data']['affitto'],
        };
      } else {
        String errorMessage = 'Errore durante la terminazione dell\'affitto';
        if (data['error'] != null) {
          if (data['error'] is Map && data['error']['message'] != null) {
            errorMessage = data['error']['message'];
          } else if (data['error'] is String) {
            errorMessage = data['error'];
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('RentalService: Errore durante terminateRental: $e');
      return {
        'success': false,
        'error': 'Errore: ${e.toString()}',
      };
    }
  }
}

