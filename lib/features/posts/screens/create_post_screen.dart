import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  Uint8List? _mediaBytes;
  String? _mediaType; // 'image', 'video'
  String? _mediaFileName;
  bool _isUploading = false;

  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  Future<void> _pickMedia(ImageSource source, String type) async {
    try {
      final XFile? picked = (type == 'image')
          ? await picker.pickImage(source: source)
          : await picker.pickVideo(source: source);

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final name = picked.name;

        setState(() {
          _mediaBytes = bytes;
          _mediaType = type;
          _mediaFileName = name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick media: $e')),
      );
    }
  }

  Future<void> _uploadPost() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_contentController.text.trim().isEmpty && _mediaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some content or media to post.')),
      );
      return;
    }

    setState(() => _isUploading = true);
    String? uploadedUrl;

    try {
      if (_mediaBytes != null && _mediaFileName != null) {
        final id = const Uuid().v4();
        final path = 'posts/$id-$_mediaFileName';

        await supabase.storage.from('media').uploadBinary(
              path,
              _mediaBytes!,
              fileOptions: FileOptions(
                contentType: lookupMimeType(_mediaFileName!),
                cacheControl: '3600',
              ),
            );

        uploadedUrl = supabase.storage.from('media').getPublicUrl(path);
      }

      await supabase.from('posts').insert({
        'user_id': user.id,
        'content': _contentController.text.trim(),
        'file_url': uploadedUrl,
        'type': _mediaType ?? 'text',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What’s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_mediaBytes != null)
              _mediaType == 'image'
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_mediaBytes!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam, size: 40),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_mediaFileName ?? 'Video selected')),
                      ],
                    ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(ImageSource.gallery, 'image'),
                  icon: const Icon(Icons.image),
                  label: const Text('Image'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(ImageSource.gallery, 'video'),
                  icon: const Icon(Icons.videocam),
                  label: const Text('Video'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadPost,
                icon: const Icon(Icons.cloud_upload),
                label: _isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
