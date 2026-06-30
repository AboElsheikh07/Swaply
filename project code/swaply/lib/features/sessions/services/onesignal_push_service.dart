// lib/features/sessions/services/onesignal_push_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class OneSignalPushService {
  static const _appId = "badf98d9-e2dd-4bde-8da7-9108d945ce6f";
  static const _restApiKey = "os_v2_app_xlpzrwpc3vf55dnhseensroon5yholjizeaehr5d5mcryddxan52v75zkohb4yjlqg3ylj5fhfhpbk3vqfoxpffckrxlsiqfgi5nxuq";

  static Future<void> sendToUser({
    required String externalUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await http.post(
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
        'data': ?data,
      }),
    );
  }

  /// Schedules a push to one or more users at a future time.
  /// Returns the OneSignal notification id (needed to cancel it later),
  /// or null if the request failed.
 
}