import 'package:flutter/foundation.dart' show kIsWeb;

/// Cambia la URL si estamos en Web; en móvil la devuelve tal cual.
String proxiedImage(String? original) {
  if (!kIsWeb || original == null || original.isEmpty) return original ?? '';
  const proxy = 'https://us-central1-waxhub95.cloudfunctions.net/imageProxy';
  return '$proxy?url=${Uri.encodeComponent(original)}';
}
