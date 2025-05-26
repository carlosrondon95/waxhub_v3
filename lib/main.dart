// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'core/app_scroll_behavior.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/vinyl_provider.dart';
import 'providers/collection_provider.dart';
import 'providers/map_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/summary_provider.dart';

// Servicios
import 'services/notification_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar solo modo retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  runApp(const Bootstrap());
}

class Bootstrap extends StatelessWidget {
  const Bootstrap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VinylProvider()),
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => MapProvider()..init()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => SummaryProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = AppRouter.router(auth);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return ResponsiveBreakpoints.builder(
      breakpoints: const [
        Breakpoint(start: 0, end: 450, name: MOBILE),
        Breakpoint(start: 451, end: 800, name: TABLET),
        Breakpoint(start: 801, end: 1200, name: DESKTOP),
        Breakpoint(start: 1201, end: double.infinity, name: '4K'),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'WaxHub',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeService.mode,
        routerConfig: _router,
        scrollBehavior: AppScrollBehavior(),
      ),
    );
  }
}
