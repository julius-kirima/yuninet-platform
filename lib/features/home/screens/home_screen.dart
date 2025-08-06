// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yuninet_app/features/ai/ai_screen.dart';
import '../../../../routes/app_routes.dart';

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
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _initVideoControllers() {
    _videoControllers = _posts
        .map((post) {
          final type = post['type'];
          if (type == 'video') {
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

  void _onPageChanged(int index) {
    setState(() => _currentPageIndex = index);

    for (var i = 0; i < _videoControllers.length; i++) {
      if (i == index) {
        _videoControllers[i].play();
      } else {
        _videoControllers[i].pause();
      }
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

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

  Widget _buildMainBody() {
    switch (_navIndex) {
      case 0:
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
      case 1:
        return const Center(
          child: Text("Chat", style: TextStyle(color: Colors.white)),
        );
      case 2:
        Future.microtask(() {
          if (mounted) {
            Navigator.pushNamed(context, AppRoutes.createPost);
            setState(() => _navIndex = 0);
          }
        });
        return const SizedBox();
      case 3:
        return const AIScreen(); // ✅ AI Screen
      case 4:
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
        onTap: (index) => setState(() => _navIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 48), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
