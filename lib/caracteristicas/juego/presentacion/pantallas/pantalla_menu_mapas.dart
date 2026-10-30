import 'package:flutter/material.dart';

import '../../datos/mapas_oficiales.dart';
import 'pantalla_seleccion_inicial.dart';

class _OpcionMapa {
  final int numero;
  final String descripcion;

  const _OpcionMapa(this.numero, this.descripcion);
}

class PantallaMenuMapas extends StatelessWidget {
  const PantallaMenuMapas({super.key});

  static const List<_OpcionMapa> _opciones = [
    _OpcionMapa(1, 'Nivel 1'),
    _OpcionMapa(2, 'Nivel 2'),
    _OpcionMapa(3, 'Nivel 3'),
    _OpcionMapa(4, 'Nivel 4'),
  ];

  void _abrirMapa(BuildContext context, int numeroMapa) {
    final tablero = CreadorMapas.obtenerMapa(numeroMapa);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PantallaSeleccionInicial(tablero: tablero, numeroMapa: numeroMapa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brilliant - Mapas'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'SELECCIONA UN MAPA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige un nivel para configurar sus estrellas y comenzar la partida.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  for (final opcion in _opciones)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 1,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary,
                          foregroundColor: Colors.white,
                          child: Text(
                            '${opcion.numero}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          'Mapa ${opcion.numero}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(opcion.descripcion),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrirMapa(context, opcion.numero),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
