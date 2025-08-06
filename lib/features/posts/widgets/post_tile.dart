import 'package:flutter/material.dart';
import 'package:yuninet_app/features/posts/models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PostModel post =
        ModalRoute.of(context)!.settings.arguments as PostModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caption
            Text(
              post.caption,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Image or Video
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: post.isImage
                  ? Image.network(
                      post.mediaUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 240,
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          post.thumbnailUrl ?? post.mediaUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 240,
                        ),
                        const Icon(
                          Icons.play_circle_fill,
                          size: 64,
                          color: Colors.white70,
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // Username & Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted by: ${post.username}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  'At: ${post.timestamp}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
