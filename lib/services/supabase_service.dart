import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<dynamic> getUserData() async {
    try {
      // The `.execute()` method has been removed in newer versions
      final response = await _client.from('users').select();

      return response; // This is already the data in the new API
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }
}
