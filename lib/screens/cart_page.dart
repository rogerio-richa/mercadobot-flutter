import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();

  static const String route = '/cart';
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  bool _isSelectMode = false;
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      final cartItems = await CoreService().apiService.fetchCartItems();
      setState(() {
        _cartItems = cartItems;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching cart items: $e');
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
            : _cartItems.isEmpty
                ? Stack(
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
                : Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = _cartItems[index];
                                  final isSelected =
                                      _selectedItems.contains(item['id']);

                                  return GestureDetector(
                                    onLongPress: () {
                                      setState(() {
                                        _isSelectMode = true;
                                        _selectedItems.add(item['id']);
                                      });
                                    },
                                    child: Dismissible(
                                      key: Key(item['id'].toString()),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        _deleteItem(item['id']);
                                      },
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        color: Colors.redAccent,
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: const Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              if (_isSelectMode)
                                                Checkbox(
                                                  value: isSelected,
                                                  onChanged: (bool? selected) {
                                                    setState(() {
                                                      if (selected == true) {
                                                        _selectedItems
                                                            .add(item['id']);
                                                      } else {
                                                        _selectedItems
                                                            .remove(item['id']);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ListTile(
                                                leading: Image.network(
                                                  item['image'],
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                title: Text(item['name']),
                                                subtitle: Text(
                                                    '${AppLocalizations.of(context)!.category} : ${item['category']}'),
                                                trailing: Text(
                                                    '\$${item['price'].toStringAsFixed(2)}'),
                                              ),
                                            ],
                                          ),
                                          if (index < _cartItems.length - 1)
                                            Divider(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              thickness: 0.5,
                                              height: 1,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          if (_isSelectMode)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: BottomAppBar(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
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
                    ],
                  ),
      ),
    );
  }

  Future<void> _deleteSelectedItems() async {
    final idsToDelete = _selectedItems.toList();
    // Perform deletion
    for (final id in idsToDelete) {
      await _deleteItem(id);
    }

    setState(() {
      _isSelectMode = false;
      _selectedItems.clear();
    });
  }

  Future<void> _deleteItem(String id) async {
    final isDeleted = await CoreService().apiService.deleteCartItem(id);
    if (isDeleted) {
      setState(() {
        _cartItems.removeWhere((item) => item['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context)!.deleted(id),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ));
    } else {
      // Handle failure (you can show a message, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error)),
      );
    }
  }
}
