import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'icon': Icons.favorite,
        'title': 'Someone liked your post',
        'time': '2 mins ago'
      },
      {
        'icon': Icons.comment,
        'title': 'New comment on your post',
        'time': '10 mins ago'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (_, index) {
          final notification = notifications[index];
          return ListTile(
            leading: Icon(notification['icon']),
            title: Text(notification['title']),
            subtitle: Text(notification['time']),
            onTap: () {
              // Navigate or perform action
            },
          );
        },
      ),
    );
  }
}
