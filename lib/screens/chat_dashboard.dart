import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messaging_ui/core/chat_service.dart';
import 'package:messaging_ui/core/core_service.dart';
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
  int messageCount = 0;
  late AnimationController controller;
  bool isTextEmpty = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CoreService().chatManager.getChatManager.getMessageHistory();
    });

    chatScrollController = ScrollController();
    textEditingController = TextEditingController();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    textEditingController.addListener(() {
      setState(() {
        isTextEmpty = textEditingController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();

    _focusNode.dispose();
    textEditingController.dispose();
    chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<List<ChatEntry>>(
            stream: CoreService().chatManager.getChatManager.messages,
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
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 20.0, top: 1),
            child: TextField(
              maxLines: 1,
              focusNode: _focusNode,
              controller: textEditingController,
              style: TextStyle(
                //color: Theme.of(context).hintColor,
                fontSize: Theme.of(context).textTheme.displaySmall?.fontSize,
              ),
              decoration: InputDecoration.collapsed(
                hintText: AppLocalizations.of(context)!.typeAMessage,
                hintStyle: TextStyle(
                  fontSize: Theme.of(context).textTheme.displaySmall?.fontSize,
                ),
              ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatEntry.message.text,
              softWrap: true,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              _formatTimestamp(chatEntry.timestamp),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    DateTime localTime = timestamp.toLocal();
    String formattedTime = DateFormat.jm().format(localTime);

    return formattedTime;
  }
}
