import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart'; // Adjust path if needed

class ImagePostWidget extends StatelessWidget {
  final String url;

  const ImagePostWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Displaying the image with rounded corners
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 250,
                child: Center(child: Icon(Icons.broken_image, size: 50)),
              );
            },
          ),
        ),

        // PopupMenuButton with options
        Positioned(
          top: 8,
          right: 8,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'Settings':
                  Navigator.pushNamed(context, AppRoutes.settings);
                  break;
                case 'Comments':
                  Navigator.pushNamed(context, AppRoutes.comments);
                  break;
                case 'Share':
                  Navigator.pushNamed(context, AppRoutes.share);
                  break;
                case 'Notifications':
                  Navigator.pushNamed(context, AppRoutes.notifications);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Settings', child: Text('Settings')),
              PopupMenuItem(value: 'Comments', child: Text('Comments')),
              PopupMenuItem(value: 'Share', child: Text('Share')),
              PopupMenuItem(
                  value: 'Notifications', child: Text('Notifications')),
            ],
          ),
        ),
      ],
    );
  }
}
