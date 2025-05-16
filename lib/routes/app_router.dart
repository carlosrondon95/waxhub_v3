// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/nuevo_disco_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/map_screen.dart';
import '../screens/detalle_disco_screen.dart';
import '../screens/edit_disco_screen.dart';
import '../models/vinyl_record.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        pageBuilder:
            (context, state) => _fadePage(const WelcomeScreen(), state),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _fadePage(const LoginScreen(), state),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder:
            (context, state) => _fadePage(const RegisterScreen(), state),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => _fadePage(const HomeScreen(), state),
      ),
      GoRoute(
        path: '/nuevo_disco',
        name: 'nuevo_disco',
        pageBuilder:
            (context, state) => _fadePage(const NuevoDiscoScreen(), state),
      ),
      GoRoute(
        path: '/coleccion',
        name: 'coleccion',
        pageBuilder:
            (context, state) => _fadePage(const CollectionScreen(), state),
      ),
      GoRoute(
        path: '/mapa_tiendas',
        name: 'mapa_tiendas',
        pageBuilder: (context, state) => _fadePage(const MapScreen(), state),
      ),
      GoRoute(
        path: '/detalle_disco',
        name: 'detalle_disco',
        pageBuilder: (context, state) {
          final record = state.extra as VinylRecord;
          return _fadePage(DetalleDiscoScreen(record: record), state);
        },
      ),
      GoRoute(
        path: '/editar_disco',
        name: 'editar_disco',
        pageBuilder: (context, state) {
          final record = state.extra as VinylRecord;
          return _fadePage(EditDiscoScreen(record: record), state);
        },
      ),
    ],
    errorPageBuilder:
        (context, state) => MaterialPage(child: const WelcomeScreen()),
  );

  // Helper para crear la página con FadeTransition
  static CustomTransitionPage<void> _fadePage(
    Widget child,
    GoRouterState state,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder:
          (context, animation, secondary, child) =>
              FadeTransition(opacity: animation, child: child),
    );
  }
}
