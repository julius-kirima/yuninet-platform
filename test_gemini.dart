import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  // 🔑 Replace with your actual API key
  const apiKey = "AIzaSyByef2wQlOG2mpeofKb6_waNyLnE9LOnz4";

  // Create a model instance
  final model = GenerativeModel(
    model: "gemini-1.5-flash", // Or "gemini-pro" depending on your SDK
    apiKey: apiKey,
  );

  // Create a prompt
  final prompt = "Explain what biology is in one short sentence.";

  try {
    final response = await model.generateContent([Content.text(prompt)]);

    // Print the AI's response
    print("✅ AI Response: ${response.text}");
  } catch (e) {
    print("❌ Error: $e");
  }
}
