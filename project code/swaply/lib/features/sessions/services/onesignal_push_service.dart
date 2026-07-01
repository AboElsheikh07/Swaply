// lib/features/sessions/services/onesignal_push_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class OneSignalPushService {
  static const _appId = "badf98d9-e2dd-4bde-8da7-9108d945ce6f";

  static const _restApiKey = String.fromEnvironment('ONESIGNAL_REST_API_KEY');

  static Future<void> sendToUser({
    required String externalUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final response = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $_restApiKey',
      },
      body: jsonEncode({
        'app_id': _appId,
        'include_aliases': {
          'external_id': [externalUserId],
        },
        'target_channel': 'push',
        'headings': {'en': title},
        'contents': {'en': body},
        if (data != null) 'data': data,
      }),
    );
    print('OneSignal status: ${response.statusCode}');
    print('OneSignal body: ${response.body}');
  }
}
