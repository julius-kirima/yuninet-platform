// lib/features/chat/screens/chat_screen.dart
// Corrected and consolidated ChatScreen file.

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;

  const ChatScreen({super.key, required this.chatId, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // messages list sorted ascending by created_at
  List<Map<String, dynamic>> messages = [];

  // streaming subscription
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSub;

  // ui state
  bool _loading = true;
  bool _showEmojiPicker = false;
  String _typingUserId = '';

  // pagination using offset/range
  static const int _pageSize = 30;
  bool _loadingMore = false;
  int _offset = 0;
  bool _hasMore = true;

  // encryption key (demo AES-256).
  // NOTE: For real E2E use per-user RSA keypairs + AES per-message key encryption.
  final encrypt.Key _aesKey = encrypt.Key.fromLength(32);
  final encrypt.IV _aesIv = encrypt.IV.fromLength(16);

  // image picker and uuid
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadInitialMessages();
    _subscribeToRealtimeMessages();
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // -------------------------
  // Data loading & pagination
  // -------------------------
  Future<void> _loadInitialMessages() async {
    try {
      setState(() {
        _loading = true;
        _offset = 0;
        _hasMore = true;
      });

      final res = await supabase
          .from('messages')
          .select()
          .eq('chat_id', widget.chatId)
          .order('created_at', ascending: false)
          .range(0, _pageSize - 1);

      final list =
          (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
      final asc = list.reversed.toList();
      setState(() {
        messages = asc;
        _offset = asc.length;
        _hasMore = list.length == _pageSize;
      });
    } catch (e, st) {
      debugPrint('loadInitialMessages error: $e\n$st');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final res = await supabase
          .from('messages')
          .select()
          .eq('chat_id', widget.chatId)
          .order('created_at', ascending: false)
          .range(_offset, _offset + _pageSize - 1);

      final list =
          (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
      if (list.isNotEmpty) {
        final asc = list.reversed.toList();
        setState(() {
          messages = [...asc, ...messages];
          _offset += asc.length;
          _hasMore = list.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e, st) {
      debugPrint('loadMoreMessages error: $e\n$st');
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 100) {
        // near top -> load earlier messages
        if (!_loadingMore && _hasMore) _loadMoreMessages();
      }
    });
  }

  // -------------------------
  // Realtime messages (stream)
  // -------------------------
  void _subscribeToRealtimeMessages() {
    try {
      final stream = supabase
          .from('messages')
          .stream(primaryKey: ['id']).eq('chat_id', widget.chatId);

      _messagesSub = stream.listen((List<Map<String, dynamic>> rows) {
        // Keep local messages ascending by created_at
        final copy = rows.map((r) => Map<String, dynamic>.from(r)).toList();
        copy.sort((a, b) => DateTime.parse(a['created_at'])
            .compareTo(DateTime.parse(b['created_at'])));
        setState(() {
          messages = copy;
        });
      }, onError: (e) {
        debugPrint('Realtime messages error: $e');
      });
    } catch (e, st) {
      debugPrint('subscribe realtime messages error: $e\n$st');
    }
  }

  // -------------------------
  // Encryption helpers
  // -------------------------
  String _encryptText(String plain) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_aesKey));
    final encrypted = encrypter.encrypt(plain, iv: _aesIv);
    return encrypted.base64;
  }

  String _decryptText(String base64Cipher) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_aesKey));
      final decrypted = encrypter.decrypt64(base64Cipher, iv: _aesIv);
      return decrypted;
    } catch (e) {
      return "[Encrypted]";
    }
  }

  // -------------------------
  // Sending messages + attachments
  // -------------------------
  Future<void> _sendTextMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final encrypted = _encryptText(text);
    try {
      await supabase.from('messages').insert({
        'chat_id': widget.chatId,
        'sender_id': widget.userId,
        'type': 'text',
        'encrypted_content': encrypted,
        'reactions': {}, // empty jsonb
        'status': 'sent',
        'created_at': DateTime.now().toIso8601String(),
      });
      // stream will update UI
    } catch (e) {
      debugPrint('sendTextMessage error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (picked == null) return;
      final file = File(picked.path);

      final remotePath =
          'chats/${widget.chatId}/${_uuid.v4()}.${picked.path.split('.').last}';
      final bucket = 'uploads';

      await supabase.storage.from(bucket).upload(remotePath, file);

      final publicUrlResp =
          supabase.storage.from(bucket).getPublicUrl(remotePath);
      String? publicUrl;

      // ignore: unnecessary_type_check
      if (publicUrlResp is String) {
        publicUrl = publicUrlResp;
      } else {
        try {
          final dynamic r = publicUrlResp;
          if (r is Map && r.containsKey('publicUrl')) {
            publicUrl = r['publicUrl'] as String?;
          } else if (r is Map && r.containsKey('public_url')) {
            publicUrl = r['public_url'] as String?;
          } else {
            publicUrl = r.toString();
          }
        } catch (_) {
          publicUrl = publicUrlResp.toString();
        }
      }

      if (publicUrl == null || publicUrl.isEmpty) {
        throw Exception('Failed to get public URL for uploaded file');
      }

      await supabase.from('messages').insert({
        'chat_id': widget.chatId,
        'sender_id': widget.userId,
        'type': 'image',
        'file_url': publicUrl,
        'reactions': {},
        'status': 'sent',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e, st) {
      debugPrint('pickAndSendImage error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send attachment')),
      );
    }
  }

  // -------------------------
  // Reactions
  // -------------------------
  Future<void> _toggleReaction(String messageId, String emoji) async {
    try {
      final resp = await supabase
          .from('messages')
          .select('reactions')
          .eq('id', messageId)
          .maybeSingle();

      Map current = {};
      if (resp != null) {
        // ignore: unnecessary_type_check
        if (resp is Map && resp.containsKey('reactions')) {
          current = Map<String, dynamic>.from(resp['reactions'] ?? {});
        } else
          current = Map<String, dynamic>.from(resp as Map);
      }

      final List<dynamic> reactors = List<dynamic>.from(current[emoji] ?? []);
      final me = widget.userId;

      if (reactors.contains(me)) {
        reactors.removeWhere((r) => r == me);
      } else {
        reactors.add(me);
      }

      final newMap = Map<String, dynamic>.from(current);
      newMap[emoji] = reactors;

      await supabase
          .from('messages')
          .update({'reactions': newMap}).eq('id', messageId);
    } catch (e) {
      debugPrint('toggleReaction error: $e');
    }
  }

  // -------------------------
  // UI building
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://via.placeholder.com/150')),
          const SizedBox(width: 8),
          const Expanded(child: Text('Chat')),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.group), onPressed: _openGroupManagement),
          IconButton(icon: const Icon(Icons.call), onPressed: _startVoiceCall),
          IconButton(
              icon: const Icon(Icons.videocam), onPressed: _startVideoCall),
        ],
      ),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _buildMessagesList()),
          if (_typingUserId.isNotEmpty) _buildTypingIndicator(),
          _buildInputArea(),
          if (_showEmojiPicker)
            SizedBox(height: 260, child: _buildEmojiPicker()),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return RefreshIndicator(
      onRefresh: _loadInitialMessages,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: messages.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (_loadingMore && index == 0) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ));
          }
          final adjustedIndex = _loadingMore ? index - 1 : index;
          final msg = messages[adjustedIndex];
          final isMe = msg['sender_id'] == widget.userId;

          final type = (msg['type'] ?? 'text') as String;
          String? decryptedText;
          if (type == 'text' && msg['encrypted_content'] != null) {
            try {
              decryptedText = _decryptText(msg['encrypted_content'] as String);
            } catch (_) {
              decryptedText = "[Encrypted]";
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: MessageBubble(
              message: msg,
              isMe: isMe,
              decryptedText: decryptedText,
              onLongPressReact: () => _showReactionPickerForMessage(msg),
              onTap: () {
                if (msg['type'] == 'image' && msg['file_url'] != null) {
                  _openFullImage(msg['file_url'] as String);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const SizedBox(width: 6),
          const Text('Typing...'),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {
                setState(() {
                  _showEmojiPicker = !_showEmojiPicker;
                  if (_showEmojiPicker) {
                    _focusNode.unfocus();
                  } else {
                    _focusNode.requestFocus();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickAndSendImage,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendTextMessage(),
                onChanged: (v) {},
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendTextMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        _controller
          ..text += emoji.emoji
          ..selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length));
      },
      config: const Config(
        columns: 8,
        emojiSizeMax: 32,
      ),
    );
  }

  // -------------------------
  // Small helpers
  // -------------------------
  void _openFullImage(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: Center(child: CachedNetworkImage(imageUrl: url)),
        ),
      ),
    );
  }

  void _showReactionPickerForMessage(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final emojis = ["👍", "❤️", "😂", "🔥", "😢", "👏", "🎉"];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emojis.map((e) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  final id =
                      (message['id'] ?? message['temp_id'] ?? '').toString();
                  if (id.isNotEmpty) _toggleReaction(id, e);
                },
                child: Text(e, style: const TextStyle(fontSize: 28)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // -------------------------
  // Placeholder call/group methods
  // -------------------------
  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Voice call placeholder (implement WebRTC)')),
    );
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Video call placeholder (implement WebRTC)')),
    );
  }

  void _openGroupManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group management placeholder')),
    );
  }
}

/// Message bubble widget
class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final String? decryptedText;
  final VoidCallback? onLongPressReact;
  final VoidCallback? onTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.decryptedText,
    this.onLongPressReact,
    this.onTap,
  });

  Widget _statusIcon(String? status) {
    switch (status) {
      case 'sending':
        return const Icon(Icons.access_time, size: 14, color: Colors.grey);
      case 'sent':
        return const Icon(Icons.check, size: 14, color: Colors.grey);
      case 'delivered':
        return const Icon(Icons.done_all, size: 14, color: Colors.grey);
      case 'read':
        return const Icon(Icons.done_all, size: 14, color: Colors.blue);
      default:
        return const SizedBox(width: 14, height: 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = message['type'] ?? 'text';
    final reactionsRaw = message['reactions'];
    Map<String, dynamic> reactionsMap = {};
    if (reactionsRaw is Map) {
      reactionsMap = Map<String, dynamic>.from(reactionsRaw);
    }

    final reactionWidgets = reactionsMap.entries.map((e) {
      final emoji = e.key;
      final reactors = e.value;
      int count = 0;
      try {
        if (reactors is List)
          count = reactors.length;
        else if (reactors is int) count = reactors;
      } catch (_) {}
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: Colors.black26, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji),
          const SizedBox(width: 4),
          Text('$count', style: const TextStyle(fontSize: 12))
        ]),
      );
    }).toList();

    final avatarUrl = message['sender_avatar'] as String? ?? '';

    return GestureDetector(
      onLongPress: onLongPressReact,
      onTap: onTap,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[600] : Colors.grey[850],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 12),
                    ),
                  ),
                  child: _buildContent(type, message, decryptedText),
                ),
                if (reactionWidgets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(spacing: 6, children: reactionWidgets),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) _statusIcon(message['status'] as String?),
        ],
      ),
    );
  }

  Widget _buildContent(
      String type, Map<String, dynamic> message, String? decrypted) {
    switch (type) {
      case 'text':
        return Text(decrypted ?? "[Encrypted]",
            style: const TextStyle(color: Colors.white, fontSize: 16));
      case 'image':
        final url = message['file_url'] as String?;
        if (url != null && url.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
          );
        } else {
          return const Text('[Image]', style: TextStyle(color: Colors.white));
        }
      default:
        return Text('[${type}]', style: const TextStyle(color: Colors.white));
    }
  }
}
