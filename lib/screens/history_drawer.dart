import 'package:flutter/material.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryDrawer extends StatefulWidget {
  const HistoryDrawer({Key? key}) : super(key: key);

  @override
  State<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer> {
  late Future<List<Map<String, dynamic>>> chatHistory;
  ScrollController drawerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatHistory = CoreService()
        .apiService
        .fetchChatHistory(); // Fetch chat history from CoreService
  }

  void _onChatSelected(String chatId) {
    CoreService().reconnect(chatId, null);
    Navigator.of(context).pop();
  }

  String _getTimeDifference(DateTime timestamp) {
    final now = DateTime.now();
    final duration = now.difference(timestamp);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    final parts = <String>[];

    if (days > 0) {
      parts.add(
          '${days} ${days > 1 ? AppLocalizations.of(context)!.days_plural : AppLocalizations.of(context)!.days}');
    }
    if (hours > 0) {
      parts.add(
          '${hours} ${hours > 1 ? AppLocalizations.of(context)!.hours_plural : AppLocalizations.of(context)!.hours}');
    }
    if (minutes > 0 || parts.isEmpty) {
      parts.add(
          '${minutes} ${minutes > 1 ? AppLocalizations.of(context)!.minutes_plural : AppLocalizations.of(context)!.minutes}');
    }

    return '${parts.join(', ')} ${AppLocalizations.of(context)!.ago}';
  }

  // Function to show confirmation dialog before deleting
  void _showDeleteDialog(String chatId) async {
    final bool? shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDeletion,
              style: Theme.of(context).textTheme.displaySmall),
          content: Text(AppLocalizations.of(context)!.chatHistoryConfirmDelete),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete,
                  style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteChatHistory(chatId);
    }
  }

  void _deleteChatHistory(String chatId) async {
    final isDeleted =
        await CoreService().apiService.deleteChatHistoryItem(chatId);
    if (isDeleted) {
      setState(() {
        chatHistory = CoreService().apiService.fetchChatHistory();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        width: 300,
        child: Column(
          children: [
            Container(
                height: 70,
                padding: const EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.chatHistory,
                    style: Theme.of(context).textTheme.displayMedium)),
            const Divider(
              thickness: .5,
              height: 1,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: chatHistory,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(AppLocalizations.of(context)!.error));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text(AppLocalizations.of(context)!
                                .noChatHistoryAvailable));
                      }

                      final chatList = snapshot.data!;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: chatList.length,
                        controller: drawerScrollController,
                        itemBuilder: (context, index) {
                          final chat = chatList[index];
                          final chatId = chat['chat_id'];
                          final lastMessageTimestamp =
                              DateTime.parse(chat['last_message_timestamp']);
                          final humanReadableTimestamp =
                              _getTimeDifference(lastMessageTimestamp);

                          return ListTile(
                            contentPadding: const EdgeInsets.only(left: 15),
                            title: Text(humanReadableTimestamp,
                                style: Theme.of(context).textTheme.bodyMedium),
                            onTap: () => _onChatSelected(chatId),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _showDeleteDialog(chatId),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
