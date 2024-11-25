import 'package:flutter/material.dart';
import 'package:messaging_ui/signIn.dart';
import 'package:messaging_ui/screens/cart_page.dart';
import 'package:messaging_ui/screens/profile_page.dart';
import 'package:messaging_ui/screens/shopping_page.dart';
import 'package:messaging_ui/splash_screen.dart';
import 'package:messaging_ui/home_dashboard.dart';

class ScreenRoutes {
  static const loading = SplashScreen.route;
  static const signin = SignInPage.route;
  static const chat = HomeDashboard.chat;
  static const profile = ProfilePage.route;
  static const cart = CartPage.route;
  static const list = ListPage.route;
  // static const contacts = HomeDashboard.contacts;
  // static const addContact = AddContact.route;
}

Map<String, Widget Function(BuildContext)> screenRoutes = {
  ScreenRoutes.signin: (context) => const SignInPage(),
  ScreenRoutes.loading: (context) => const SplashScreen(),
  ScreenRoutes.chat: (context) => const HomeDashboard(selectedIndex: 0),
  ScreenRoutes.profile: (context) => const ProfilePage(),
  ScreenRoutes.list: (context) => const HomeDashboard(selectedIndex: 1),
  ScreenRoutes.cart: (context) => const HomeDashboard(selectedIndex: 2),
  // ScreenRoutes.contacts: (context) => const HomeDashboard(selectedIndex: 1),
  // ScreenRoutes.addContact: (context) => const AddContact(),
};
