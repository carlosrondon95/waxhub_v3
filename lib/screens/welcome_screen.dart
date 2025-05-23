import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    // Controlador de animación de 2s
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Fade-in suave
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    // Scale-in suave (de 0.8x a 1.0x)
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    // Inicia la animación
    _animController.forward();

    // Después de 5 s en total, navega a 'login'
    _timer = Timer(const Duration(seconds: 5), () {
      context.goNamed('login');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WAXHUB',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 42, // aumentado
                    letterSpacing: 6, // un poco más de espacio
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Image.asset(
                  'assets/images/waxhub.png',
                  height: 160, // logo más grande
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
