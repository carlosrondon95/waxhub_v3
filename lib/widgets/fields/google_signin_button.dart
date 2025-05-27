import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/providers/auth_provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  static const double _iconSize = 24;
  static const double _fontSize = 18;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    Future<void> _showAlert({
      required BuildContext ctx,
      required String title,
      required String message,
      required IconData icon,
      required Color iconColor,
    }) {
      return showDialog(
        context: ctx,
        builder:
            (dialogCtx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
      );
    }

    return OutlinedButton(
      onPressed: () async {
        final err = await auth.signInWithGoogle();
        if (err == null) {
          await _showAlert(
            ctx: context,
            title: '¡Éxito!',
            message: 'Has iniciado sesión con Google correctamente.',
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
          );
        } else {
          await _showAlert(
            ctx: context,
            title: 'Error',
            message: err,
            icon: Icons.error_outline,
            iconColor: Colors.red,
          );
        }
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: Color(0xFFededed)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/google_logo.svg',
            height: _iconSize,
            width: _iconSize,
          ),
          const SizedBox(width: 10),
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
