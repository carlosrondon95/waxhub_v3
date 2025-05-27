import 'package:flutter/foundation.dart' show kIsWeb;

/// Convierte siempre HTTP→HTTPS y, si es Web, pasa por tu proxy CORS-friendly.
String proxiedImage(String? original) {
  if (original == null || original.isEmpty) {
    return '';
  }
  // 1) Forzamos HTTPS para evitar mixed-content o redirecciones inesperadas
  final secureUrl = original.replaceFirst(RegExp(r'^http:'), 'https:');
  // 2) Si estamos en Web, utilizamos el proxy europeo con CORS habilitado
  if (kIsWeb) {
    const proxy = 'https://europe-west1-waxhub95.cloudfunctions.net/imageProxy';
    return '$proxy?url=${Uri.encodeComponent(secureUrl)}';
  }
  // 3) En móvil, devolvemos la URL segura directamente
  return secureUrl;
}
