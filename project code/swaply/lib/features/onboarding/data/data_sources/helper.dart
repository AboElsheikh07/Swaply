import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const _cloudName = 'dj4dhriow'; // from Cloudinary dashboard
  static const _uploadPreset = 'avatars'; // unsigned preset name

  static Future<String> uploadAvatar(File image, String uid) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] =
          uid // ← same uid every time = overwrites old image
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final body = jsonDecode(await response.stream.bytesToString());

    if (response.statusCode != 200) {
      throw Exception('Image upload failed: ${body['error']['message']}');
    }

    return body['secure_url'] as String;
  }
}
