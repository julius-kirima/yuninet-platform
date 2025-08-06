import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostService {
  final supabase = Supabase.instance.client;

  Future<List<PostModel>> fetchPosts() async {
    final response = await supabase.from('posts').select().order('created_at', ascending: false);
    return (response as List).map((map) => PostModel.fromMap(map)).toList();
  }
}
