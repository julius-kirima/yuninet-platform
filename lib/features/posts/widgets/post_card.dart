import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yuninet_app/features/posts/widgets/image_post_widget.dart';
import 'package:yuninet_app/features/posts/widgets/video_post_widget.dart';
import 'package:yuninet_app/routes/app_routes.dart';

class PostCard extends StatefulWidget {
  final String url;
  final bool isVideo;
  final String postId;
  final String authorId;

  const PostCard({
    super.key,
    required this.url,
    required this.isVideo,
    required this.postId,
    required this.authorId,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final supabase = Supabase.instance.client;
  bool isLiked = false;
  bool isFollowing = false;
  int likeCount = 0;

  String get currentUserId => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadInitialStatus();
  }

  Future<void> _loadInitialStatus() async {
    if (currentUserId.isEmpty) return;

    final likeResponse = await supabase
        .from('likes')
        .select()
        .eq('post_id', widget.postId)
        .eq('user_id', currentUserId);

    final allLikes =
        await supabase.from('likes').select().eq('post_id', widget.postId);

    final followResponse = await supabase
        .from('follows')
        .select()
        .eq('follower_user_id', currentUserId)
        .eq('following_user_id', widget.authorId);

    setState(() {
      isLiked = likeResponse.isNotEmpty;
      isFollowing = followResponse.isNotEmpty;
      likeCount = allLikes.length;
    });
  }

  Future<void> _toggleLike() async {
    if (currentUserId.isEmpty) return;

    if (isLiked) {
      await supabase
          .from('likes')
          .delete()
          .match({'post_id': widget.postId, 'user_id': currentUserId});
    } else {
      await supabase.from('likes').insert({
        'post_id': widget.postId,
        'user_id': currentUserId,
      });
    }

    _loadInitialStatus();
  }

  Future<void> _toggleFollow() async {
    if (currentUserId.isEmpty || widget.authorId == currentUserId) return;

    if (isFollowing) {
      await supabase.from('follows').delete().match({
        'following_user_id': widget.authorId,
        'follower_user_id': currentUserId
      });
    } else {
      await supabase.from('follows').insert({
        'following_user_id': widget.authorId,
        'follower_user_id': currentUserId,
      });
    }

    _loadInitialStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: widget.isVideo
              ? VideoPostWidget(url: widget.url)
              : ImagePostWidget(url: widget.url),
        ),
        Positioned(
          right: 10,
          top: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSideButton(
                icon: Icons.favorite,
                label: '$likeCount',
                iconColor: isLiked ? Colors.red : Colors.white,
                onTap: _toggleLike,
              ),
              const SizedBox(height: 12),
              _buildSideButton(
                icon: Icons.person_add,
                label: isFollowing ? 'Following' : 'Follow',
                iconColor: isFollowing ? Colors.green : Colors.white,
                onTap: _toggleFollow,
              ),
              const SizedBox(height: 12),
              _buildSideButton(
                icon: Icons.comment,
                label: 'Comment',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.comments, arguments: {
                    'postId': widget.postId,
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildSideButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.share, arguments: {
                    'postId': widget.postId,
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildSideButton(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
              const SizedBox(height: 12),
              _buildSideButton(
                icon: Icons.notifications,
                label: 'Notify',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
