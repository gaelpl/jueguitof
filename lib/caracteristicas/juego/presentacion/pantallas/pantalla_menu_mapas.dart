import 'package:flutter/material.dart';

import '../../../autenticacion/datos/servicios/servicio_autenticacion.dart';
import '../../../autenticacion/presentacion/pantallas/pantalla_login.dart';
import '../../datos/mapas_oficiales.dart';
import 'pantalla_lobby.dart';
import 'pantalla_reglas.dart';
import 'pantalla_seleccion_inicial.dart';

const Color _azulProfundo = Color(0xFF312E81);
const Color _cian = Color(0xFF0EA5E9);
const Color _fondoClaro = Color(0xFFF8FAFC);
const Color _textoPrincipal = Color(0xFF0F172A);
const Color _textoSecundario = Color(0xFF64748B);

class _OpcionMapa {
  final int numero;
  final String descripcion;
  final List<Color> colores;

  const _OpcionMapa(this.numero, this.descripcion, this.colores);
}

class PantallaMenuMapas extends StatelessWidget {
  const PantallaMenuMapas({super.key});

  static const List<_OpcionMapa> _opciones = [
    _OpcionMapa(1, 'Nivel 1', [Color(0xFF4F46E5), Color(0xFF0EA5E9)]),
    _OpcionMapa(2, 'Nivel 2', [Color(0xFF0F766E), Color(0xFF10B981)]),
    _OpcionMapa(3, 'Nivel 3', [Color(0xFFB45309), Color(0xFFF59E0B)]),
    _OpcionMapa(4, 'Nivel 4', [Color(0xFFBE123C), Color(0xFFF43F5E)]),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            _iconoDialogo(Icons.logout_rounded, _azulProfundo),
            const SizedBox(width: 12),
            const Expanded(child: Text('Cerrar sesión')),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas salir de tu cuenta?',
          style: TextStyle(color: _textoSecundario, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _azulProfundo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(contextoDialogo);

              await servicioAuth.cerrarSesion();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PantallaLogin()),
                (route) => false,
              );
            },
            child: const Text('Salir'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            _iconoDialogo(
              Icons.delete_forever_rounded,
              const Color(0xFFDC2626),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Borrar cuenta')),
          ],
        ),
        content: const Text(
          'Esta acción es irreversible y eliminará permanentemente todos tus datos. ¿Deseas continuar?',
          style: TextStyle(color: _textoSecundario, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(contextoDialogo);

              final resultado = await servicioAuth.eliminarCuenta();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resultado['mensaje']),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: resultado['exito'] == true
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );

              if (resultado['exito'] == true ||
                  resultado['sesionExpirada'] == true) {
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
      backgroundColor: _fondoClaro,
      body: Column(
        children: [
          _construirEncabezado(context),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _construirAccesoMultijugador(context),
                      const SizedBox(height: 16),
                      _construirAccesoReglas(context),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Selecciona un mapa',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _textoPrincipal,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _azulProfundo.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '4 niveles',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _azulProfundo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Elige un nivel para configurar sus estrellas y comenzar la partida.',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textoSecundario,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final int columnas = constraints.maxWidth >= 640
                              ? 2
                              : 1;
                          const double separacion = 16;
                          final double anchoTarjeta = columnas == 1
                              ? constraints.maxWidth
                              : (constraints.maxWidth - separacion) / 2;

                          return Wrap(
                            spacing: separacion,
                            runSpacing: separacion,
                            children: [
                              for (final opcion in _opciones)
                                SizedBox(
                                  width: anchoTarjeta,
                                  child: _TarjetaMapa(
                                    opcion: opcion,
                                    onTap: () =>
                                        _abrirMapa(context, opcion.numero),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAccesoMultijugador(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_azulProfundo, _cian],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _azulProfundo.withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PantallaLobby()));
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.groups_2_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jugar multijugador',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Crea una sala o únete con un código para jugar de 2 a 5 jugadores.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirAccesoReglas(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const PantallaReglas()));
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _azulProfundo,
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: const Icon(Icons.menu_book_rounded, size: 22),
      label: const Text(
        'Reglas del Juego',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _construirEncabezado(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), _azulProfundo, Color(0xFF0284C7)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x330F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.sports_esports_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BRILLIANT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            color: _cian,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tu aventura continúa',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Opciones de cuenta',
                    offset: const Offset(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
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
                            Icon(Icons.logout_rounded, color: _textoPrincipal),
                            SizedBox(width: 10),
                            Text('Cerrar sesión'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'borrar_cuenta',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever_rounded,
                              color: Color(0xFFDC2626),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Borrar mi cuenta',
                              style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Tu próximo desafío',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cuatro mapas, cuatro oportunidades para demostrar tu estrategia.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _iconoDialogo(IconData icono, Color color) {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icono, color: color, size: 24),
  );
}

class _TarjetaMapa extends StatelessWidget {
  final _OpcionMapa opcion;
  final VoidCallback onTap;

  const _TarjetaMapa({required this.opcion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: opcion.colores,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: opcion.colores.first.withValues(alpha: 0.32),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${opcion.numero}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mapa ${opcion.numero}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _textoPrincipal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opcion.descripcion,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _fondoClaro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: _textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
