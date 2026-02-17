import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vinyl_provider.dart';
import '../widgets/nuevo_disco_form.dart';

class NuevoDiscoScreen extends StatefulWidget {
  const NuevoDiscoScreen({super.key});

  @override
  State<NuevoDiscoScreen> createState() => _NuevoDiscoScreenState();
}

class _NuevoDiscoScreenState extends State<NuevoDiscoScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Limpia el formulario del provider al salir
    context.read<VinylProvider>().clearForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir disco')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: NuevoDiscoForm(formKey: _formKey),
        ),
      ),
    );
  }
}
