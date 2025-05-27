// lib/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/nuevo_disco_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/map_screen.dart';
import '../screens/map_settings_screen.dart';

/* Ajustes generales */
import '../screens/settings_menu_screen.dart';
import '../screens/appearance_settings_screen.dart';
import '../screens/information_account_screen.dart';
import '../screens/notifications_settings_screen.dart';
import '../screens/informe_uso_screen.dart';
import '../screens/faq_screen.dart';
//import '../screens/help_support_screen.dart';
import '../screens/about_screen.dart';

/* Vinilos */
import '../screens/detalle_disco_screen.dart';
import '../screens/edit_disco_screen.dart';
import '../models/vinyl_record.dart';

class AppRouter {
  static GoRouter router(Listenable authProvider) {
    return GoRouter(
      navigatorKey: NotificationService.navigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final loggedIn = FirebaseAuth.instance.currentUser != null;
        final loc = state.uri.toString();
        const authPaths = ['/', '/login', '/register'];

        if (!loggedIn && !authPaths.contains(loc)) return '/login';
        if (loggedIn && authPaths.contains(loc)) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'welcome',
          builder: (ctx, st) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (ctx, st) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (ctx, st) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (ctx, st) => const HomeScreen(),
        ),

        GoRoute(
          path: '/nuevo_disco',
          name: 'nuevo_disco',
          builder: (ctx, st) => const NuevoDiscoScreen(),
        ),
        GoRoute(
          path: '/coleccion',
          name: 'coleccion',
          builder: (ctx, st) => const CollectionScreen(),
        ),
        GoRoute(
          path: '/detalle_disco',
          name: 'detalle_disco',
          builder: (ctx, st) {
            final record = st.extra as VinylRecord;
            return DetalleDiscoScreen(record: record);
          },
        ),
        GoRoute(
          path: '/editar_disco',
          name: 'editar_disco',
          builder: (ctx, st) {
            final record = st.extra as VinylRecord;
            return EditDiscoScreen(record: record);
          },
        ),

        // Mapa & ajustes de mapa
        GoRoute(
          path: '/mapa_tiendas',
          name: 'mapa_tiendas',
          builder: (ctx, st) => const MapScreen(),
        ),
        GoRoute(
          path: '/ajustes/mapa',
          name: 'mapSettings',
          builder: (ctx, st) => const MapSettingsScreen(),
        ),

        // Ajustes generales
        GoRoute(
          path: '/ajustes',
          name: 'ajustes',
          builder: (ctx, st) => const SettingsMenuScreen(),
        ),
        GoRoute(
          path: '/apariencia',
          name: 'apariencia',
          builder: (ctx, st) => const AppearanceSettingsScreen(),
        ),
        GoRoute(
          path: '/cuenta',
          name: 'cuenta',
          builder: (ctx, st) => const InformationAccountScreen(),
        ),
        GoRoute(
          path: '/ajustes/notificaciones',
          name: 'notificaciones',
          builder: (ctx, st) => const NotificationsSettingsScreen(),
        ),
        GoRoute(
          path: '/ajustes/informe_uso',
          name: 'informe_uso',
          builder: (ctx, st) => const InformeUsoScreen(),
        ),
        GoRoute(
          path: '/faq',
          name: 'faq',
          builder: (ctx, st) => const FaqScreen(),
        ),
        /*GoRoute(
          path: '/ayuda',
          name: 'help',
          builder: (ctx, st) => const HelpSupportScreen(),
        ),*/
        GoRoute(
          path: '/acerca',
          name: 'acerca',
          builder: (ctx, st) => const AboutScreen(),
        ),
      ],
      errorBuilder: (ctx, st) => const WelcomeScreen(),
    );
  }
}
