import 'package:flutter/material.dart';
import 'package:messaging_ui/screens/cart_page.dart';
import 'package:messaging_ui/screens/chat_dashboard.dart';
import 'package:messaging_ui/screens/history_drawer.dart';
import 'package:messaging_ui/screens/shopping_page.dart';
import 'package:messaging_ui/widgets/top_bar.dart';

class HomeDashboard extends StatefulWidget {
  static const String chat = '/chat';

  final int selectedIndex;
  const HomeDashboard({super.key, required this.selectedIndex});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late int selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _navItems = [
    {
      'label': 'chat',
      'widget': const ChatDashboard(),
    },
    {
      'label': 'shoppingList',
      'backButton': true,
      'widget': const ListPage(),
    },
    {
      'label': 'cart',
      'backButton': true,
      'widget': const CartPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: false,
      appBar: TopBar(
        text: _navItems[selectedIndex]['label'],
        showBackButton: _navItems[selectedIndex]['backButton'] ?? false,
        onDrawerTap: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      body: Column(
        children: [
          const Divider(
            thickness: 1,
            color: Colors.orange,
            height: 1,
          ),
          Expanded(
            child: _navItems[selectedIndex]['widget'],
          ),
        ],
      ),
      endDrawer: const HistoryDrawer(),
    );
  }
}
