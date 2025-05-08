// lib/services/email_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // URL de tu función en prod o en local
  static const _baseUrl =
    String.fromEnvironment('EMAIL_API_URL',
      defaultValue: 'https://us-central1-appemails-ef24c.cloudfunctions.net/sendBulkEmail'
    );

  /// Envía un email genérico a todos los suscriptores.
  /// Devuelve el número de correos enviados.
  static Future<int> sendBulkEmail({
    required String sender,
    required String subject,
    required String body,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final payload = {
      'sender':      sender,
      'subject':     subject,
      'htmlContent': body,
    };

    print('📤 POST $uri → $payload');
    final resp = await http.post(
      uri,
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode(payload),
    );

    print('📥 status=${resp.statusCode} body=${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data['success'] == true && data['count'] is int) {
      return data['count'] as int;
    } else {
      throw Exception('Respuesta inesperada: $data');
    }
  }
}
