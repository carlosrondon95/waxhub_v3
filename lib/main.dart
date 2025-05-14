import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

import 'providers/auth_provider.dart';
import 'providers/vinyl_provider.dart';

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WaxHub',
        theme: AppTheme,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generate,
      ),
    );
  }
}
