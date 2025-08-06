import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String caption;
  final String mediaUrl;
  final String? thumbnailUrl;
  final bool isImage;
  final String username;
  final DateTime timestamp;

  PostModel({
    required this.id,
    required this.caption,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.isImage,
    required this.username,
    required this.timestamp,
  });

  factory PostModel.fromMap(Map<String, dynamic> data) {
    return PostModel(
      id: data['id'] ?? '',
      caption: data['caption'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      isImage: data['isImage'] ?? true,
      username: data['username'] ?? 'Unknown',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caption': caption,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'isImage': isImage,
      'username': username,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
