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
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return Dismissible(
                                key: Key(item['id'].toString()),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  _deleteItem(item['id']);
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
                                    InkWell(
                                      onTap: () {},
                                      hoverColor: Theme.of(context).hoverColor,
                                      splashColor:
                                          Theme.of(context).splashColor,
                                      highlightColor:
                                          Theme.of(context).highlightColor,
                                      child: ListTile(
                                        leading: Image.network(item['image'],
                                            width: 50, height: 50),
                                        title: Text(item['name']),
                                        subtitle: Text(
                                            '${AppLocalizations.of(context)!.category} : ${item['category']}'),
                                        trailing: Text(
                                            '\$${item['price'].toStringAsFixed(2)}'),
                                      ),
                                    ),
                                    if (index < _cartItems.length - 1)
                                      Divider(
                                        color: Theme.of(context).dividerColor,
                                        thickness: 0.5,
                                        height: 1,
                                      ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
      ),
    );
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
