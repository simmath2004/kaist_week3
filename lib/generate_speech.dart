import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> generateSpeech(String text) async {
  var url =
      Uri.parse('https://api.resemble.ai/v1/project/YOUR_PROJECT_ID/generate');
  var response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer YOUR_API_KEY',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'text': text, 'voice_uuid': 'YOUR_VOICE_UUID'}),
  );

  if (response.statusCode == 200) {
    // Handle the successful response here
    print("Audio generated successfully.");
  } else {
    // Handle errors
    print("Failed to generate audio: ${response.body}");
  }
}
