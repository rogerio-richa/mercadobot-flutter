import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});
  static const String route = '/list';

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<String> _descriptions = [];
  bool _isLoading = true;

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
              ? Stack(
                  children: [
                    Center(
                      child: SvgPicture.asset('assets/empty_cart.svg',
                          alignment: Alignment.center,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(
                                    0.5)
                                : Colors.black.withOpacity(
                                    0.1),
                            BlendMode.srcIn,
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.cartEmpty,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.chatToBot,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
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

                          return Dismissible(
                            key: Key(description),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _deleteItem(description);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!
                                      .deleted(description),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surface,
                              ));
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              color: Colors.redAccent,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  hoverColor: Theme.of(context).hoverColor,
                                  splashColor: Theme.of(context).splashColor,
                                  highlightColor:
                                      Theme.of(context).highlightColor,
                                  child: ListTile(
                                      tileColor: Theme.of(context).brightness ==
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
                                if (index < _descriptions.length - 1)
                                  Divider(
                                    color: Theme.of(context)
                                        .dividerColor,
                                    thickness: 0.5,
                                    height: 1,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  void _deleteItem(String description) {
    setState(() {
      _descriptions.remove(description);
    });
  }
}
