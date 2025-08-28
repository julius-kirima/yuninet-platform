// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:yuninet_app/features/ai/screens/ai_screen.dart';
import 'package:yuninet_app/screens/smart_hub_screen.dart';
import 'package:yuninet_app/routes/app_routes.dart'; // ✅ fixed import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _posts = [];
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  int _navIndex = 0;
  List<VideoPlayerController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  // 🔹 Fetch posts from Supabase
  Future<void> _fetchPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _posts = List<Map<String, dynamic>>.from(response);
      });

      _initVideoControllers();
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // 🔹 Initialize video players
  void _initVideoControllers() {
    _videoControllers = _posts
        .map((post) {
          if (post['type'] == 'video') {
            return VideoPlayerController.networkUrl(Uri.parse(post['file_url']))
              ..initialize().then((_) => setState(() {}));
          }
          return null;
        })
        .whereType<VideoPlayerController>()
        .toList();

    if (_videoControllers.isNotEmpty) {
      _videoControllers.first.play();
    }
  }

  // 🔹 Handle video page change
  void _onPageChanged(int index) {
    setState(() => _currentPageIndex = index);
    for (var i = 0; i < _videoControllers.length; i++) {
      i == index ? _videoControllers[i].play() : _videoControllers[i].pause();
    }
  }

  // 🔹 Sign out
  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // 🔹 Build post types
  Widget _buildPost(Map<String, dynamic> post, int index) {
    final type = post['type'] ?? 'text';
    final content = post['content'];
    final url = post['file_url'];

    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: type == 'video'
                ? _buildVideo(index)
                : type == 'image'
                    ? _buildImage(url)
                    : _buildOther(type, content, url),
          ),
        ),
        _buildOverlay(post),
        Positioned(
          top: 40,
          left: 20,
          child: Text(
            '${_currentPageIndex + 1}/${_posts.length}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildVideo(int index) {
    if (_videoControllers.length <= index) return const SizedBox.shrink();
    final controller = _videoControllers[index];

    return controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              setState(() {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200.0,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
                if (!controller.value.isPlaying)
                  const Icon(Icons.play_circle_fill,
                      size: 80, color: Colors.white70),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildImage(String? url) {
    return url == null
        ? const Icon(Icons.broken_image, size: 100, color: Colors.white38)
        : SizedBox(
            height: 200.0,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
          );
  }

  Widget _buildOther(String type, String? content, String? url) {
    switch (type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            content ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        );
      case 'pdf':
      case 'link':
        return ListTile(
          title: Text(
            type == 'pdf' ? '📄 PDF Document' : '🔗 Link',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            url ?? '',
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () {
            if (url != null) launchUrl(Uri.parse(url));
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // 🔹 Overlay actions (like, comment, share)
  Widget _buildOverlay(Map<String, dynamic> post) {
    final postId = post['id']?.toString() ?? '';
    final url = post['file_url'];

    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (AppRoutes.routes.containsKey(AppRoutes.profile)) {
                Navigator.pushNamed(context, AppRoutes.profile);
              }
            },
            child: const CircleAvatar(
              backgroundImage: NetworkImage("https://via.placeholder.com/150"),
              radius: 25,
            ),
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white, size: 32),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You liked this post!')),
              );
            },
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.comment, color: Colors.white, size: 32),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.comments,
                arguments: {'postId': postId},
              );
            },
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 32),
            onPressed: () {
              if (url != null && url.isNotEmpty) {
                Share.share('Check out this post: $url');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nothing to share')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 🔹 Switch between bottom navigation tabs
  Widget _buildMainBody() {
    switch (_navIndex) {
      case 0: // Home
        return _loading
            ? const Center(child: CircularProgressIndicator())
            : PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return _buildPost(_posts[index], index);
                },
              );
      case 1: // Chat
        return const Center(
          child: Text("Chat", style: TextStyle(color: Colors.white)),
        );
      case 2: // Create Post
        Future.microtask(() {
          if (mounted) {
            Navigator.pushNamed(context, AppRoutes.createPost);
            setState(() => _navIndex = 0);
          }
        });
        return const SizedBox();
      case 3: // AI Screen
        return const AIScreen();
      case 4: // Smart Hub
        return const SmartHubScreen(); // ✅ now works
      case 5: // Profile
        Future.microtask(() {
          if (mounted) {
            Navigator.pushNamed(context, AppRoutes.profile);
            setState(() => _navIndex = 0);
          }
        });
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Yuninet Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _buildMainBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.cyanAccent,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        iconSize: 28,
        type: BottomNavigationBarType.fixed, // ✅ supports 6 items
        onTap: (index) => setState(() => _navIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 48), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'SmartHub'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
