import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/auth_provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  // Tamaños corporativos (icono + tipografía) ligeramente mayores
  static const double _iconSize = 24; // antes 20
  static const double _fontSize =
      18; // antes el labelLarge por defecto (~14‑16)

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return OutlinedButton(
      onPressed: () async {
        final err = await auth.signInWithGoogle();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err ?? 'Inicio de sesión con Google exitoso')),
        );
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50), // misma altura
        side: const BorderSide(color: Color(0xFFededed)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // No modificamos padding para que el botón no crezca horizontalmente
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono oficial multicolor "G" (SVG) ligeramente más grande
          SvgPicture.asset(
            'assets/icons/google_logo.svg',
            height: _iconSize,
            width: _iconSize,
          ),
          const SizedBox(width: 10),
          // Texto "Google" con colores corporativos y fuente un poco mayor
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
              ),
              children: const [
                TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
                TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))),
                TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))),
                TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
                TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))),
                TextSpan(text: 'e', style: TextStyle(color: Color(0xFFEA4335))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
