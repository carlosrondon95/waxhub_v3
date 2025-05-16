import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vinyl_provider.dart';
import '../widgets/nuevo_disco_form.dart';

class NuevoDiscoScreen extends StatelessWidget {
  const NuevoDiscoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vinyl = context.watch<VinylProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Añadir disco')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(key: vinyl.formKey, child: const NuevoDiscoForm()),
      ),
    );
  }
}
