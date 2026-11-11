import 'package:flutter/material.dart';

const Color _azulProfundo = Color(0xFF312E81);
const Color _cian = Color(0xFF0EA5E9);
const Color _fondoClaro = Color(0xFFF8FAFC);
const Color _textoPrincipal = Color(0xFF0F172A);
const Color _textoSecundario = Color(0xFF64748B);

class PantallaReglas extends StatelessWidget {
  const PantallaReglas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoClaro,
      appBar: AppBar(
        title: const Text('Reglas del Juego'),
        centerTitle: true,
        backgroundColor: _azulProfundo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _Encabezado(),
                SizedBox(height: 20),
                _Seccion(
                  icono: Icons.flag_rounded,
                  titulo: 'Objetivo',
                  child: _Parrafo(
                    'Completa regiones del tablero para sumar puntos. Gana '
                    'quien alcance primero la meta de puntos.',
                  ),
                ),
                _Seccion(
                  icono: Icons.grid_on_rounded,
                  titulo: 'El tablero',
                  child: _Lista(
                    items: [
                      'Es una cuadrícula de 7x7 dividida en regiones de '
                          'colores.',
                      'Hay 6 casillas especiales marcadas con una estrella.',
                      'Al empezar, cada jugador coloca los números del 1 al 6 '
                          '(una sola vez cada uno) en las estrellas, '
                          'respetando la regla de la región de cada casilla.',
                    ],
                  ),
                ),
                _Seccion(
                  icono: Icons.casino_rounded,
                  titulo: 'La tirada de dados y el dado ancla',
                  child: _Lista(
                    items: [
                      'Cada ronda el anfitrión lanza 2 dados.',
                      'Elige una casilla ya ocupada cuyo número coincida con '
                          'uno de los dados: esa es el ancla.',
                      'El otro dado es el número que colocarás.',
                      'Si ambos dados coinciden con el ancla, puedes elegir '
                          'cuál usar como ancla.',
                    ],
                  ),
                ),
                _Seccion(
                  icono: Icons.open_with_rounded,
                  titulo: 'Colocación adyacente',
                  child: _Lista(
                    items: [
                      'Solo puedes colocar el número en una casilla vacía que '
                          'sea adyacente (arriba, abajo, izquierda o derecha) '
                          'al ancla.',
                      'La casilla destino debe cumplir la regla de su región.',
                    ],
                  ),
                ),
                _Seccion(
                  icono: Icons.palette_rounded,
                  titulo: 'Regiones y sus reglas',
                  child: Column(
                    children: [
                      _ReglaRegion(
                        color: Color(0xFF2196F3),
                        nombre: 'Azul',
                        regla: 'Todos los números iguales',
                        puntos: '7',
                      ),
                      _ReglaRegion(
                        color: Color(0xFFECEFF1),
                        nombre: 'Blanco',
                        regla: 'Todos los números iguales',
                        puntos: '8',
                      ),
                      _ReglaRegion(
                        color: Color(0xFFE53935),
                        nombre: 'Rojo',
                        regla: 'Todos diferentes',
                        puntos: '6',
                      ),
                      _ReglaRegion(
                        color: Color(0xFFFFEB3B),
                        nombre: 'Amarillo',
                        regla: 'Todos diferentes',
                        puntos: '8',
                      ),
                      _ReglaRegion(
                        color: Color(0xFF9C27B0),
                        nombre: 'Morado',
                        regla: 'Máximo 2 números distintos',
                        puntos: '6',
                      ),
                      _ReglaRegion(
                        color: Color(0xFF4CAF50),
                        nombre: 'Verde',
                        regla: 'Cualquier número',
                        puntos: '4',
                      ),
                      _ReglaRegion(
                        color: Color(0xFFFF9800),
                        nombre: 'Naranja',
                        regla: 'Mitad superior solo 4-6; mitad inferior 1-3',
                        puntos: '6',
                        esUltima: true,
                      ),
                    ],
                  ),
                ),
                _Seccion(
                  icono: Icons.stars_rounded,
                  titulo: 'Puntuación',
                  child: _Parrafo(
                    'Una región otorga sus puntos solo cuando se completa al '
                    '100% de sus casillas.',
                  ),
                ),
                _Seccion(
                  icono: Icons.emoji_events_rounded,
                  titulo: 'Condiciones de victoria',
                  child: _Lista(
                    items: [
                      'Multijugador: gana quien alcance la meta de puntos.',
                      'Meta según jugadores: 2 jugadores = 26, 3 = 24, '
                          '4 = 22, 5 = 20.',
                      'También ganas si tu rival se rinde o pierde la conexión '
                          '(en partidas de 2 jugadores).',
                      'En partidas de 3 o más, si alguien se rinde o se '
                          'desconecta la partida continúa.',
                    ],
                  ),
                ),
                _Seccion(
                  icono: Icons.touch_app_rounded,
                  titulo: 'Controles',
                  child: _Lista(
                    items: [
                      'Lanzar 2 Dados: disponible para el anfitrión cuando '
                          'todos los jugadores están listos.',
                      'Saltar Turno: pasa tu acción de la ronda actual.',
                      'Rendirse: abandona la partida.',
                    ],
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

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_azulProfundo, _cian],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _azulProfundo.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
              Icons.menu_book_rounded,
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
                  'Brilliant',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cómo jugar y anotar puntos',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.icono,
    required this.titulo,
    required this.child,
  });

  final IconData icono;
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: _azulProfundo, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _textoPrincipal,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Parrafo extends StatelessWidget {
  const _Parrafo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14.5,
        height: 1.5,
        color: _textoSecundario,
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _cian,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i],
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: _textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReglaRegion extends StatelessWidget {
  const _ReglaRegion({
    required this.color,
    required this.nombre,
    required this.regla,
    required this.puntos,
    this.esUltima = false,
  });

  final Color color;
  final String nombre;
  final String regla;
  final String puntos;
  final bool esUltima;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: esUltima
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _textoPrincipal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  regla,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _azulProfundo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$puntos pts',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _azulProfundo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
