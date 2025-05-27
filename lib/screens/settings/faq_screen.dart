// lib/screens/settings/faq_screen.dart

import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  static const _sections = [
    {
      'title': 'Colección de discos',
      'items': [
        {
          'q': '¿Cómo añado un nuevo disco?',
          'a':
              'En Colección, pulsa “+ Nuevo Disco”, completa los campos y toca Guardar.',
        },
        {
          'q': '¿Cómo edito o elimino un disco?',
          'a':
              'Toca el disco para abrir su ficha. Usa el icono de lápiz para editar y el menú ⋮ para eliminar.',
        },
        {
          'q': '¿Cómo filtro y ordeno mis discos?',
          'a':
              'Filtra con la búsqueda por título, artista o género, y ordena o muestra solo favoritos desde los filtros.',
        },
        {
          'q': '¿Cómo marco un disco como favorito?',
          'a': 'Toca el corazón junto al disco en la lista o en su ficha.',
        },
        {
          'q': '¿Puedo cambiar la vista?',
          'a':
              'Toca el icono de vista arriba en Colección para alternar entre lista y cuadrícula.',
        },
      ],
    },
    {
      'title': 'Modo sin conexión',
      'items': [
        {
          'q': '¿Qué pasa si no tengo internet?',
          'a':
              'La app funciona con los datos ya cargados y se sincroniza al reconectar.',
        },
      ],
    },
    {
      'title': 'Tiendas de vinilo',
      'items': [
        {
          'q': '¿Cómo veo tiendas cercanas?',
          'a':
              'Abre el menú y selecciona Mapa de tiendas para ver marcadores y lista de locales.',
        },
        {
          'q': '¿Cómo ajusto el radio y el tipo de mapa?',
          'a':
              'En Ajustes → Ajustes de mapa ajusta el radio (1–50 km) y elige Normal o Satélite.',
        },
        {
          'q': '¿Cómo refresco la lista de tiendas?',
          'a':
              'Arrastra hacia abajo en la lista para actualizar los resultados.',
        },
        {
          'q': '¿Cómo veo datos de una tienda?',
          'a': 'Toca su marcador o su nombre para ver nombre y dirección.',
        },
        {
          'q': '¿Y si deniego ubicación?',
          'a':
              'Verás “Permiso denegado”. Ve a los ajustes del teléfono y habilita ubicación.',
        },
      ],
    },
    {
      'title': 'Notificaciones y apariencia',
      'items': [
        {
          'q': '¿Cómo activo o desactivo notificaciones?',
          'a':
              'En Ajustes → Notificaciones usa el interruptor para encender o apagar.',
        },
        {
          'q': '¿Cómo funcionan las notificaciones?',
          'a':
              'Recibes aviso al entrar en el radio configurado alrededor de una tienda.',
        },
        {
          'q': '¿Cómo cambio el tema?',
          'a': 'En Ajustes → Tema y apariencia elige Claro, Oscuro o Sistema.',
        },
        {
          'q': '¿Puedo cambiar de idioma?',
          'a': 'En Ajustes → Idioma selecciona tu preferencia.',
        },
      ],
    },
    {
      'title': 'Informe de uso',
      'items': [
        {
          'q': '¿Cómo consulto mi informe?',
          'a':
              'En Ajustes → Informe de uso elige un periodo para ver tus estadísticas.',
        },
        {
          'q': '¿Qué incluye el informe?',
          'a':
              'Número de discos añadidos, artistas frecuentes, búsquedas y tiendas visitadas.',
        },
      ],
    },
    {
      'title': 'Ayuda y soporte',
      'items': [
        {
          'q': '¿Dónde envío dudas o problemas?',
          'a':
              'Ve a Ajustes → Ayuda y soporte, escribe tu mensaje y toca Enviar.',
        },
      ],
    },
    {
      'title': 'Cuenta',
      'items': [
        {
          'q': '¿Cómo recupero mi contraseña?',
          'a':
              'Toca “¿Olvidaste la contraseña?” en la pantalla de inicio de sesión.',
        },
        {
          'q': '¿Cómo cierro sesión?',
          'a': 'En Ajustes, al final, toca Cerrar sesión.',
        },
        {
          'q': '¿Dónde veo la versión y detalles?',
          'a': 'En Ajustes → Acerca de encontrarás la versión y enlaces.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    const maxWidth = 450.0;
    final bgColor = Theme.of(context).cardColor;
    final shColor = Theme.of(context).shadowColor.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(title: const Text('Preguntas frecuentes')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shColor,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListView.builder(
            itemCount: _sections.length,
            itemBuilder: (context, sIdx) {
              final section = _sections[sIdx];
              final items = section['items'] as List<Map<String, String>>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      section['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...items.map(
                    (faq) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: const Icon(Icons.help_outline),
                        title: Text(
                          faq['q']!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.text_snippet, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  faq['a']!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
