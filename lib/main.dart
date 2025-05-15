// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/theme.dart';
import 'core/app_scroll_behavior.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

import 'providers/auth_provider.dart';
import 'providers/vinyl_provider.dart';
import 'providers/collection_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VinylProvider()),
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WaxHub',
        theme: AppTheme,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generate,
        scrollBehavior: AppScrollBehavior(),
        // ------------ Responsive Framework ------------
        builder:
            (context, child) => ResponsiveBreakpoints.builder(
              child: MaxWidthBox(
                maxWidth: 1200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: child!,
                ),
              ),
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 800, name: TABLET),
                Breakpoint(start: 801, end: 1200, name: DESKTOP),
                Breakpoint(start: 1201, end: double.infinity, name: '4K'),
              ],
            ),
      ),
    );
  }
}
