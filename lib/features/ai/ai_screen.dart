import 'package:flutter/material.dart';
import 'package:yuninet_app/services/gemini_service.dart'; // ✅ Gemini AI Service

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;

  // ✅ Selected AI model
  String selectedModel = "gemini-1.5-flash";
  final List<String> models = ["gemini-1.5-flash", "gemini-pro"];

  /// ✅ Handles sending user input to the AI
  Future<void> sendMessage() async {
    final userInput = controller.text.trim();
    if (userInput.isEmpty || isLoading) return;

    setState(() {
      messages.add({"text": userInput, "isUser": true, "isError": false});
      controller.clear();
      isLoading = true;
    });

    _scrollToBottom();

    try {
      print("📤 Sending to AI ($selectedModel): $userInput");

      final response =
          await GeminiService.sendMessage(userInput, model: selectedModel);

      print("✅ AI Response: $response");

      setState(() {
        messages.add({"text": response, "isUser": false, "isError": false});
      });
    } catch (e, stack) {
      print("❌ ERROR in sendMessage: $e");
      print(stack);

      setState(() {
        messages.add({
          "text":
              "❌ Error: Unable to connect to AI.\n\nDetails: ${e.toString()}",
          "isUser": false,
          "isError": true,
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  /// ✅ Auto-scroll to the latest message
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI School Assistant 🤖"),
        backgroundColor: Colors.deepPurple,
        actions: [
          // ✅ Dropdown to pick Gemini model
          DropdownButton<String>(
            value: selectedModel,
            items: models.map((model) {
              return DropdownMenuItem(
                value: model,
                child: Text(model,
                    style: const TextStyle(fontSize: 14, color: Colors.white)),
              );
            }).toList(),
            dropdownColor: Colors.deepPurple[300],
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedModel = value;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Chat messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['isUser'] as bool;
                final isError = msg['isError'] as bool? ?? false;

                // ✅ Bubble styling logic
                Color? bubbleColor;
                Alignment alignment;

                if (isError) {
                  bubbleColor = Colors.red[300];
                  alignment = Alignment.centerLeft;
                } else if (isUser) {
                  bubbleColor = Colors.blue[300];
                  alignment = Alignment.centerRight;
                } else {
                  bubbleColor = Colors.grey[300];
                  alignment = Alignment.centerLeft;
                }

                return Align(
                  alignment: alignment,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SelectableText(
                      msg['text'],
                      style: TextStyle(
                        fontSize: 16,
                        color: isError ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Loading indicator
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),

          // ✅ Input field
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Ask your AI assistant...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
