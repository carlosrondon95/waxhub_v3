// lib/widgets/google_signin_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

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
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: Color(0xFFededed)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/google_logo.svg',
            height: 20,
            width: 20,
          ),
          const SizedBox(width: 8),
          const Text('Google'),
        ],
      ),
    );
  }
}
