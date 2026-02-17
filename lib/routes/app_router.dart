import 'package:flutter/material.dart';

import '../routes/fade_route.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/nuevo_disco_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/detalle_disco_screen.dart';
import '../screens/edit_disco_screen.dart';
import '../screens/map_screen.dart';
import '../models/vinyl_record.dart';

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
      case '/coleccion':
        page = const CollectionScreen();
        break;
      case '/mapa_tiendas':
        page = const MapScreen();
        break;
      case '/detalle_disco':
        final record = settings.arguments as VinylRecord;
        page = DetalleDiscoScreen(record: record);
        break;
      case '/editar_disco':
        final recordToEdit = settings.arguments as VinylRecord;
        page = EditDiscoScreen(record: recordToEdit);
        break;
      default:
        page = const WelcomeScreen();
    }

    return FadePageRoute(page: page);
  }
}
