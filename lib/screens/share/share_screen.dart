import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void sharePost() {
      // ignore: deprecated_member_use
      Share.share(
        'Check out this awesome post from Yuninet!',
        subject: 'Yuninet Post',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Post'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: sharePost,
          icon: const Icon(Icons.share),
          label: const Text('Share Post'),
        ),
      ),
    );
  }
}
