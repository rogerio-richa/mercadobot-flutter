import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/screen_routes.dart';
import 'package:messaging_ui/signIn.dart';
import 'package:messaging_ui/theme/app_theme.dart';
import 'package:messaging_ui/utils/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'injection_container.dart' as injection_container;
import 'package:window_size/window_size.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injection_container.init();
  injection_container.getIt.get<CoreService>().init();
  AppThemes.textScaleFactor = await CoreService().apiService.scaleFactor;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('MercadoBOT');

    double maxY = 700;
    double maxX = 500;
    setWindowMinSize(Size(maxX, maxY));
    setWindowMaxSize(Size(maxX, maxY));
    Future<void>.delayed(const Duration(seconds: 1), () {
      setWindowFrame(Rect.fromCenter(
          center: const Offset(300, 100), width: maxX, height: maxY));
    });
  }
  CoreService().themeService.loadThemeFromSecureStorage();

  runApp(MyApp(key: myAppKey));
}

final navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ValueNotifier<String?> notificationNotifier = ValueNotifier(null);
  final PanelController topNotificationController = PanelController();
  final CoreService coreService = injection_container.getIt<CoreService>();
  Key appKey = UniqueKey();

  void restartApp() {
    setState(() {
      appKey = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    coreService.closeWebSocket();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print('App is minimized or closed.');
        break;
      case AppLifecycleState.resumed:
        print('App is opened.');
        CoreService().connectWebSocket();
        break;
      case AppLifecycleState.hidden:
        print('App is hidden.');
        break;
      case AppLifecycleState.inactive:
        print('App is in the background.');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CoreService().themeService.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          key: appKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pt'),
          ],
          locale: const Locale('pt'),
          navigatorKey: navigatorKey,
          title: 'MercadoBot',
          debugShowCheckedModeBanner: false,
          initialRoute: ScreenRoutes.loading,
          theme: AppThemes.lightTheme(context),
          darkTheme: AppThemes.darkTheme(context),
          themeMode: themeMode,
          onGenerateRoute: (settings) {
            final builder = screenRoutes[settings.name];
            if (builder != null) {
              return NoAnimationPageRoute(
                builder: (context) => builder(context),
                settings: settings,
              );
            }
            return MaterialPageRoute(
              builder: (context) => const SignInPage(),
            );
          },
        );
      },
    );
  }
}
