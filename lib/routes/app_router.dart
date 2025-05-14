import 'package:flutter/material.dart';

import '../routes/fade_route.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/nuevo_disco_screen.dart';

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    late final Widget page;

    switch (settings.name) {
      case '/':
        page = const WelcomeScreen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/register':
        page = const RegisterScreen();
        break;
      case '/home':
        page = const HomeScreen();
        break;
      case '/nuevo_disco':
        page = const NuevoDiscoScreen();
        break;
      default:
        page = const WelcomeScreen();
    }

    return FadePageRoute(page: page);
  }
}
