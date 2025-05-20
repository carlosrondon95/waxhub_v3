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
import '../screens/user_options_screen.dart'; // ← import añadido
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
          pageBuilder: (_, state) => _fadePage(const WelcomeScreen(), state),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (_, state) => _fadePage(const LoginScreen(), state),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          pageBuilder: (_, state) => _fadePage(const RegisterScreen(), state),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (_, state) => _fadePage(const HomeScreen(), state),
        ),
        GoRoute(
          path: '/nuevo_disco',
          name: 'nuevo_disco',
          pageBuilder: (_, state) => _fadePage(const NuevoDiscoScreen(), state),
        ),
        GoRoute(
          path: '/coleccion',
          name: 'coleccion',
          pageBuilder: (_, state) => _fadePage(const CollectionScreen(), state),
        ),
        GoRoute(
          path: '/mapa_tiendas',
          name: 'mapa_tiendas',
          pageBuilder: (_, state) => _fadePage(const MapScreen(), state),
        ),
        GoRoute(
          path: '/opciones_usuario',
          name: 'opciones_usuario',
          pageBuilder:
              (_, state) => _fadePage(const UserOptionsScreen(), state),
        ), // ← ruta de Opciones de Usuario
        GoRoute(
          path: '/detalle_disco',
          name: 'detalle_disco',
          pageBuilder: (_, state) {
            final record = state.extra as VinylRecord;
            return _fadePage(DetalleDiscoScreen(record: record), state);
          },
        ),
        GoRoute(
          path: '/editar_disco',
          name: 'editar_disco',
          pageBuilder: (_, state) {
            final record = state.extra as VinylRecord;
            return _fadePage(EditDiscoScreen(record: record), state);
          },
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
