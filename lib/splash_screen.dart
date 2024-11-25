import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/injection_container.dart';
import 'package:messaging_ui/screen_routes.dart';
import 'package:messaging_ui/theme/app_theme.dart';
import 'package:messaging_ui/widgets/title.dart';

class SplashScreen extends StatefulWidget {
  static const String route = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_initialized) {
      _checkElapsedTime();
    }
  }

  Future<void> _initializeApp() async {
    await getIt<CoreService>().init();

    _checkElapsedTime();
  }

  void _checkElapsedTime() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (await getIt<CoreService>().isUserAuthenticated) {
      Navigator.of(context).pushNamed(ScreenRoutes.chat);
    } else {
      Navigator.of(context).pushNamed(ScreenRoutes.signin);
    }

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemes.lightTheme(context),
      child: Scaffold(
        body: Center(
          child: title(),
        ),
      ),
    );
  }
}
