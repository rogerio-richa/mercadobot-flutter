import 'package:flutter/material.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/screen_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.text,
    this.onDrawerTap,
    this.showBackButton = false,
  });

  final String text;
  final Function()? onDrawerTap;
  final bool showBackButton;

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> {
  @override
  void initState() {
    super.initState();
  }

  String? getLocalizedText(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;

    switch (key) {
      case 'chat':
        return localizations.chat;
      case 'shoppingList':
        return localizations.shoppingList;
      case 'cart':
        return localizations.cart;
      case 'profile':
        return localizations.profile;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      leadingWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 50),
          child: Row(
            children: [
              if (widget.showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pushNamed(ScreenRoutes.chat);
                  },
                ),
              if (widget.text == 'chat')
                PopupMenuButton<int>(
                  icon: const Icon(Icons.menu),
                  iconSize: 20,
                  onSelected: (value) {
                    if (value == 0 && widget.onDrawerTap != null) {
                      widget.onDrawerTap?.call();
                    } else if (value == 1) {
                      CoreService()
                          .reconnect(null, AppLocalizations.of(context)!);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.history,
                              color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.chatHistory),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.clearConvo),
                        ],
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getLocalizedText(context, widget.text) ?? 'null',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    ValueListenableBuilder<ConnectivityStatus>(
                      valueListenable: CoreService().connectivityStatus,
                      builder: (context, status, child) {
                        switch (status) {
                          case ConnectivityStatus.connecting:
                            return Text(
                              AppLocalizations.of(context)!.connecting,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.orange),
                            );
                          case ConnectivityStatus.connected:
                            return const SizedBox();
                          case ConnectivityStatus.offline:
                            return Text(
                              AppLocalizations.of(context)!.offline,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.red),
                            );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(ScreenRoutes.cart);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(ScreenRoutes.list);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outlined),
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                Navigator.of(context).pushNamed(ScreenRoutes.profile);
              },
            ),
          ),
        ),
      ],
    );
  }
}
