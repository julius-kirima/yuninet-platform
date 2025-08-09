import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  final List<dynamic> users;
  const UserList({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CachedNetworkImage(imageUrl: users[index]['avatarUrl'] ?? ''),
          title: Text(users[index]['name'] ?? 'Unknown'),
        );
      },
    );
  }
}