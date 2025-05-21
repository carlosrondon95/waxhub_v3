// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/nuevo_disco_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/map_screen.dart';

/* Ajustes */
import '../screens/settings_menu_screen.dart';
import '../screens/information_account_screen.dart';
import '../screens/about_screen.dart';

/* Vinilos */
import '../screens/detalle_disco_screen.dart';
import '../screens/edit_disco_screen.dart';
import '../models/vinyl_record.dart';

class AppRouter {
  static GoRouter router(ChangeNotifier authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = FirebaseAuth.instance.currentUser != null;
        final loc = state.uri.toString();
        final goingToAuth = loc == '/' || loc == '/login' || loc == '/register';

        if (!loggedIn && !goingToAuth) return '/login';
        if (loggedIn && goingToAuth) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'welcome',
          pageBuilder: (_, s) => _fadePage(const WelcomeScreen(), s),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (_, s) => _fadePage(const LoginScreen(), s),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          pageBuilder: (_, s) => _fadePage(const RegisterScreen(), s),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (_, s) => _fadePage(const HomeScreen(), s),
        ),
        GoRoute(
          path: '/nuevo_disco',
          name: 'nuevo_disco',
          pageBuilder: (_, s) => _fadePage(const NuevoDiscoScreen(), s),
        ),
        GoRoute(
          path: '/coleccion',
          name: 'coleccion',
          pageBuilder: (_, s) => _fadePage(const CollectionScreen(), s),
        ),
        GoRoute(
          path: '/mapa_tiendas',
          name: 'mapa_tiendas',
          pageBuilder: (_, s) => _fadePage(const MapScreen(), s),
        ),
        GoRoute(
          path: '/detalle_disco',
          name: 'detalle_disco',
          pageBuilder: (_, s) {
            final record = s.extra as VinylRecord;
            return _fadePage(DetalleDiscoScreen(record: record), s);
          },
        ),
        GoRoute(
          path: '/editar_disco',
          name: 'editar_disco',
          pageBuilder: (_, s) {
            final record = s.extra as VinylRecord;
            return _fadePage(EditDiscoScreen(record: record), s);
          },
        ),

        /* Ajustes */
        GoRoute(
          path: '/ajustes',
          name: 'ajustes',
          pageBuilder: (_, s) => _fadePage(const SettingsMenuScreen(), s),
        ),
        GoRoute(
          path: '/cuenta',
          name: 'cuenta',
          pageBuilder: (_, s) => _fadePage(const InformationAccountScreen(), s),
        ),
        GoRoute(
          path: '/acerca',
          name: 'acerca',
          pageBuilder: (_, s) => _fadePage(const AboutScreen(), s),
        ),
      ],
      errorPageBuilder: (_, __) => MaterialPage(child: const WelcomeScreen()),
    );
  }

  static CustomTransitionPage<void> _fadePage(
    Widget child,
    GoRouterState state,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder:
          (context, anim, sec, child) =>
              FadeTransition(opacity: anim, child: child),
    );
  }
}
