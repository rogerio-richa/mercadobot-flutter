import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:messaging_ui/core/chat_service.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/injection_container.dart';
import 'package:messaging_ui/widgets/record_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatDashboard extends StatefulWidget {
  const ChatDashboard({super.key});

  @override
  State<ChatDashboard> createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard>
    with SingleTickerProviderStateMixin {
  late ScrollController chatScrollController;
  late TextEditingController textEditingController;
  late Stream<List<ChatEntry>> conversationListStream;
  int messageCount = 0;
  late AnimationController controller;
  bool isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    conversationListStream =
        getIt.get<CoreService>().chatManager.getChatManager.messages;

    chatScrollController = ScrollController();
    textEditingController = TextEditingController();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    textEditingController.addListener(() {
      setState(() {
        isTextEmpty = textEditingController.text.isEmpty;
        print(textEditingController.text.isEmpty);
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    textEditingController.dispose();
    chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ChatEntry>>(
        stream: conversationListStream,
        builder: (context, snapshot) {
          final conversation = snapshot.data ?? [];

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (chatScrollController.hasClients) {
              chatScrollController
                  .jumpTo(chatScrollController.position.maxScrollExtent);
            }
          });

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    controller: chatScrollController,
                    itemCount: conversation.length,
                    itemBuilder: (context, index) {
                      final chatEntry = conversation[index];
                      return ChatListItem(chatEntry: chatEntry);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    bool isMobile = Platform.isAndroid || Platform.isIOS;

    return Padding(
      padding: isMobile ? const EdgeInsets.only(bottom: 20.0) : EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 20.0, top: 1),
              child: TextField(
                controller: textEditingController,
                style: TextStyle(
                  fontSize:
                      Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: AppLocalizations.of(context)!.typeAMessage,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize:
                        Theme.of(context).textTheme.bodyMedium?.fontSize ??
                            14.0,
                  ),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onSubmitted: (text) async {
                  await _sendMessage(text);
                },
              ),
            ),
          ),
          Offstage(
            offstage: isTextEmpty,
            child: IconButton(
              icon: Icon(Icons.send,
                  size: 30, color: Theme.of(context).colorScheme.primary),
              onPressed: () async {
                await _sendMessage(textEditingController.text);
              },
            ),
          ),
          Offstage(
            offstage: !isTextEmpty,
            child: RecordButton(controller: controller),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (await CoreService().chatManager.sendMessage(message: text.trim())) {
      textEditingController.clear();
    }
  }
}

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key, required this.chatEntry});

  final ChatEntry chatEntry;

  @override
  Widget build(BuildContext context) {
    final bool isUser = chatEntry.sender == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade100 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatEntry.message.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4.0),
            Text(
              _formatTimestamp(chatEntry.timestamp),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
