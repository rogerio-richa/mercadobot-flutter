import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messaging_ui/core/chat_service.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/widgets/custom_checkbox.dart';
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
  bool showScrollToBottomButton = false; 

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CoreService()
          .chatManager
          .getChatManager
          .getMessageHistory(AppLocalizations.of(context)!);
      _scrollToBottom();

    });
    chatScrollController = ScrollController();
    chatScrollController.addListener(_onScroll);
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


  // void _onScroll() {
  //   final isAtBottom = chatScrollController.offset <=
  //       250;
  //   setState(() {
  //     showScrollToBottomButton = !isAtBottom;
  //   });
  // }

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    textEditingController.dispose();
    chatScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isAtBottom = chatScrollController.offset >=
        chatScrollController.position.maxScrollExtent - 100;
    print(isAtBottom);
    setState(() {
      showScrollToBottomButton = !isAtBottom;
    });
  }

  void _scrollToBottom() {
    if (chatScrollController.hasClients) {
      chatScrollController.animateTo(
        chatScrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<List<ChatEntry>>(
            stream: CoreService().chatManager.getChatManager.messages,
            builder: (context, snapshot) {
              final conversation = snapshot.data ?? [];
              final reversedConversation = conversation.reversed.toList();
              
              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children:[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                            reverse: true,
                            controller: chatScrollController,
                            itemCount: conversation.length,
                        itemBuilder: (context, index) {
                          final chatEntry = reversedConversation[index];
                          return ChatListItem(chatEntry: chatEntry);
                        },
                      ),
                    ),
                    if (showScrollToBottomButton)
                      Positioned(
                        bottom: 20.0,
                        right: 20.0,
                        child: ScrollDownButton(onTap: _scrollToBottom),
                      ),
                      ])
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                    height: 1,
                  ),
                  _buildMessageInput(),
                ],
              );
            },
          ),
        ),
        floatingActionButton: Visibility(
          // Add the scroll-to-bottom button
          visible:
              showScrollToBottomButton, // Show button when scrolled away from bottom
          child: FloatingActionButton(
            onPressed: _scrollToBottom,
            child: Icon(Icons.arrow_downward),
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
            padding: const EdgeInsets.only(bottom: 4.0, left: 20.0, top: 2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 100.0,
              ),
              child: TextField(
                focusNode: _focusNode,
                controller: textEditingController,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.displaySmall?.fontSize,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: AppLocalizations.of(context)!.typeAMessage,
                  hintStyle: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.displaySmall?.fontSize,
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textAlignVertical:
                    TextAlignVertical.top,
                onChanged: (_) {
                  setState(() {});
                },
                onSubmitted: (text) async {
                  await _sendMessage(text);
                  _focusNode.requestFocus();
                },
              ),
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
              _focusNode.requestFocus();
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

    final colorScheme = Theme.of(context).colorScheme;
    final isAlert = chatEntry.sender == 'alert';

  Alignment alignment;
  Color bubbleColor;
  switch (chatEntry.sender) {
    case 'user':
      bubbleColor = colorScheme.primary.withOpacity(0.4);
      alignment = Alignment.centerRight;
      break;
    case 'alert':
      bubbleColor = colorScheme.primary;
      alignment = Alignment.center;
      break;
    case 'assistant':
      bubbleColor = colorScheme.primaryContainer.withOpacity(0.3);
      alignment = Alignment.centerLeft;
      break;
    default:
      bubbleColor = Colors.black;
      alignment = Alignment.centerLeft;
  }

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: isAlert
            ? Text(
                chatEntry.message.text,
                softWrap: true,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
              )
            : Column(
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
