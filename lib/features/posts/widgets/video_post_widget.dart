import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPostWidget extends StatefulWidget {
  final String url;
  const VideoPostWidget({super.key, required this.url});

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      }).catchError((_) {
        setState(() => _isError = true);
      });

    _controller.addListener(() {
      if (mounted) setState(() {}); // Update for progress
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _toggleVolume() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _goFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(
          controller: _controller,
          isMuted: _isMuted,
          togglePlayPause: _togglePlayPause,
          toggleVolume: _toggleVolume,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return const Center(child: Text('Failed to load video'));
    }

    return _controller.value.isInitialized
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: _togglePlayPause,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              if (!_controller.value.isPlaying)
                const Center(
                  child: Icon(Icons.play_circle_fill,
                      size: 64, color: Colors.white70),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildControls(),
              )
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildControls() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: position.inMilliseconds.toDouble(),
          max: duration.inMilliseconds.toDouble(),
          onChanged: (value) {
            _controller.seekTo(Duration(milliseconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position),
                  style: const TextStyle(color: Colors.white)),
              Text(_formatDuration(duration),
                  style: const TextStyle(color: Colors.white)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white),
                    onPressed: _toggleVolume,
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: () => _goFullScreen(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

class FullScreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isMuted;
  final VoidCallback togglePlayPause;
  final VoidCallback toggleVolume;

  const FullScreenVideoPlayer({
    super.key,
    required this.controller,
    required this.isMuted,
    required this.togglePlayPause,
    required this.toggleVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(29, 10, 10, 10),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: GestureDetector(
                onTap: togglePlayPause,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            if (!controller.value.isPlaying)
              const Center(
                child: Icon(Icons.play_circle_fill,
                    size: 80, color: Colors.white70),
              ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: controller.value.position.inMilliseconds.toDouble(),
                    max: controller.value.duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      controller.seekTo(Duration(milliseconds: value.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(controller.value.position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        _formatDuration(controller.value.duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white),
                        onPressed: toggleVolume,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
