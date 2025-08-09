import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<dynamic> getUserData() async {
    try {
      final response = await _client.from('users').select().execute();
      return response.data;
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }
}