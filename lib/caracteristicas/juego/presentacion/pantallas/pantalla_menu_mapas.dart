import 'package:flutter/material.dart';

import '../../../autenticacion/datos/servicios/servicio_autenticacion.dart';
import '../../../autenticacion/presentacion/pantallas/pantalla_login.dart';
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

  void _confirmarCerrarSesion(BuildContext context) {
    final ServicioAutenticacion servicioAuth = ServicioAutenticacion();

    showDialog(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(contextoDialogo);

              // Limpiamos los datos locales (token)
              await servicioAuth.cerrarSesion();

              if (!context.mounted) return;

              // Redirigimos al Login eliminando el historial de pantallas
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PantallaLogin()),
                (route) => false,
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _confirmarBorrarCuenta(BuildContext context) {
    final ServicioAutenticacion servicioAuth = ServicioAutenticacion();

    showDialog(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Borrar cuenta'),
        content: const Text(
          'Esta acción es irreversible y eliminará permanentemente todos tus datos. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(contextoDialogo);

              // Llamada al servidor para eliminar la cuenta y limpiar token local
              final resultado = await servicioAuth.eliminarCuenta();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(resultado['mensaje'])));

              if (resultado['exito']) {
                // Redirigimos al Login eliminando el historial
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaLogin(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Sí, borrar cuenta'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brilliant - Mapas'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 28),
            onSelected: (opcion) {
              if (opcion == 'cerrar_sesion') {
                _confirmarCerrarSesion(context);
              } else if (opcion == 'borrar_cuenta') {
                _confirmarBorrarCuenta(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'cerrar_sesion',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black87),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'borrar_cuenta',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Borrar mi cuenta',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
