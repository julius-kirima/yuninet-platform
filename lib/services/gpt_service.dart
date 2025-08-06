import 'dart:convert';
import 'package:http/http.dart' as http;

class GPTService {
  static const String _baseUrl = "http://127.0.0.1:8000";

  static Future<String> sendMessage(String message) async {
    final url = Uri.parse("$_baseUrl/ask");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "No response from AI.";
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      print("GPTService error: $e");
      throw Exception("Could not connect to the AI service.");
    }
  }
}
