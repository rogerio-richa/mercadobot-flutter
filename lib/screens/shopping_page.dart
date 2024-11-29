import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:messaging_ui/widgets/custom_checkbox.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});
  static const String route = '/list';

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<String> _descriptions = [];
  bool _isLoading = true;
  bool _isSelectMode = false;
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchDescriptions();
  }

  Future<void> _fetchDescriptions() async {
    try {
      final descriptions =
          await CoreService().apiService.fetchProductDescriptions();
      setState(() {
        _descriptions = descriptions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching descriptions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _descriptions.isEmpty
                ? Column(
                    children: [
                      Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          SvgPicture.asset(
                            'assets/empty_cart.svg',
                            width: 100,
                            alignment: Alignment.center,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).hintColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.cartEmpty,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                            textAlign: TextAlign.center,
                          ),
                        ]),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 50, left: 50, right: 50),
                          child: Text(
                            AppLocalizations.of(context)!.chatToBot,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _descriptions.length,
                          itemBuilder: (context, index) {
                            final description = _descriptions[index];
                            final isSelected =
                                _selectedItems.contains(description);

                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  _isSelectMode = true;
                                  _selectedItems.add(description);
                                });
                              },
                              child: Dismissible(
                                key: Key(description),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  _deleteItem([description]);
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  color: Colors.redAccent,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (_isSelectMode)
                                          CustomCheckBox(
                                            isSelected: isSelected,
                                            onTap: (bool? selected) {
                                              setState(() {
                                                if (selected == true) {
                                                  _selectedItems
                                                      .add(description);
                                                } else {
                                                  _selectedItems
                                                      .remove(description);
                                                }
                                              });
                                            },
                                          ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {},
                                            hoverColor:
                                                Theme.of(context).hoverColor,
                                            splashColor:
                                                Theme.of(context).splashColor,
                                            highlightColor: Theme.of(context)
                                                .highlightColor,
                                            child: ListTile(
                                              tileColor: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Theme.of(context).cardColor
                                                  : Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                              title: Text(description,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (index < _descriptions.length - 1)
                                      Divider(
                                        color: Theme.of(context).dividerColor,
                                        thickness: 0.5,
                                        height: 1,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_isSelectMode)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: BottomAppBar(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedItems.clear();
                                      _selectedItems.addAll(_descriptions);
                                    });
                                  },
                                  icon: const Icon(Icons.select_all),
                                  label: Text(
                                      AppLocalizations.of(context)!.selectAll),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isSelectMode = false;
                                      _selectedItems.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                  label: Text(
                                      AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton.icon(
                                  onPressed: () async {
                                    await _deleteSelectedItems();
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: Text(
                                      AppLocalizations.of(context)!.delete),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _deleteSelectedItems() async {
    await _deleteItem(_selectedItems.toList());

    setState(() {
      _isSelectMode = false;
      _selectedItems.clear();
    });
  }

  Future<void> _deleteItem(List<String> description) async {
    final isDeleted =
        await CoreService().apiService.deleteShoppingListItems(description);
    if (isDeleted) {
      CoreService()
          .chatManager
          .getChatManager
          .notifyOfRemovedItemFromShoppingList(AppLocalizations.of(context)!);

      setState(() {
        _descriptions.removeWhere((item) => description.contains(item));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(
          AppLocalizations.of(context)!.deleted(description.join(', ')),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: const Duration(seconds: 1),
            content: Text(AppLocalizations.of(context)!.error)),
      );
    }
  }
}
