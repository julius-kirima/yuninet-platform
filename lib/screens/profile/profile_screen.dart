import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import '../settings/settings_screen.dart';
import '../share/share_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../chat/chat_screen.dart';
import '../post/post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  String userId = '';
  bool isLoading = true;

  // User data
  String profileImage = '';
  String username = '';
  String bio = '';
  int followersCount = 0;
  int followingCount = 0;
  int viewersCount = 0;
  int totalLikes = 0;
  List<Map<String, dynamic>> userPosts = [];

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    if (user != null) {
      userId = user.id;
      _loadUserData();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userResp =
          await supabase.from('users').select().eq('id', userId).single();

      final followersResp =
          await supabase.from('follows').select().eq('followed_id', userId);

      final followingResp =
          await supabase.from('follows').select().eq('follower_id', userId);

      final postsResp =
          await supabase.from('posts').select().eq('user_id', userId);

      final postIds = postsResp.map<String>((p) => p['id'].toString()).toList();

      int likeCount = 0;

      if (postIds.isNotEmpty) {
        final likesResp = await supabase
            .from('likes')
            .select('id')
            .inFilter('post_id', postIds);

        likeCount = likesResp.length;
      }

      setState(() {
        profileImage = userResp['profile_image'] ?? '';
        username = userResp['username'] ?? 'No Name';
        bio = userResp['bio'] ?? '';
        viewersCount = userResp['viewers_count'] ?? 0;
        followersCount = followersResp.length;
        followingCount = followingResp.length;
        totalLikes = likeCount;
        userPosts = List<Map<String, dynamic>>.from(postsResp);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : const AssetImage('assets/images/default_user.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              icon: const Icon(Icons.edit, color: Colors.deepPurple),
              label: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            Text(username,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(bio, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Followers', followersCount),
                _buildStatColumn('Following', followingCount),
                _buildStatColumn('Viewers', viewersCount),
                _buildStatColumn('Likes', totalLikes),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileButton(
                  icon: Icons.message,
                  label: 'Message',
                  onPressed: () {
                    // Pass required chatId and userId
                    final chatId = "chat_${userId}_admin"; // example chatId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(chatId: chatId, userId: userId),
                      ),
                    );
                  },
                ),
                _buildProfileButton(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  ),
                ),
                _buildProfileButton(
                  icon: Icons.share,
                  label: 'Share',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShareScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Posts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userPosts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final post = userPosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PostDetailScreen(),
                        settings: RouteSettings(arguments: post),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.play_arrow_rounded, size: 32),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, int value) {
    return Column(
      children: [
        Text(value.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('Add Music (coming soon)'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Music upload coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await supabase.auth.signOut();
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
