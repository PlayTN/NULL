import 'dart:convert';
import 'api_client.dart';

class DonationService {
  /// Aggiorna lo stato di una donazione
  /// 
  /// [donationId] - ID della donazione
  /// [status] - Nuovo stato (daVisionare, inValutazione, accettata, rifiutata)
  /// [lockerId] - ID del locker (opzionale, se accettata)
  /// [cellId] - ID della cella (opzionale, se accettata)
  /// [isComunePickup] - Se il ritiro è al comune (opzionale)
  static Future<Map<String, dynamic>> updateDonationStatus({
    required String donationId,
    required String status,
    String? lockerId,
    String? cellId,
    bool? isComunePickup,
  }) async {
    try {
      final body = <String, dynamic>{
        'stato': status,
      };

      if (lockerId != null) {
        body['lockerId'] = lockerId;
      }
      if (cellId != null) {
        body['cellaId'] = cellId;
      }
      if (isComunePickup != null) {
        body['isComunePickup'] = isComunePickup;
      }

      final response = await ApiClient.put(
        '/donations/$donationId',
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'donation': data['data']['donation'],
        };
      } else {
        String errorMessage = 'Errore durante l\'aggiornamento della donazione';
        if (data['error'] != null && data['error'] is Map && data['error']['message'] != null) {
          errorMessage = data['error']['message'];
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Errore di connessione: ${e.toString()}',
      };
    }
  }
}

