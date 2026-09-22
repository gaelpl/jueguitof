import 'dart:async';

import 'juego_logica.dart';

abstract class JuegoEstado {}

class JuegoEstadoInicial extends JuegoEstado {
  final int estrellasColocadas;
  JuegoEstadoInicial({this.estrellasColocadas = 0});
}

class JuegoEstadoTurno extends JuegoEstado {
  final String mensaje;
  JuegoEstadoTurno({this.mensaje = 'Turno activo'});
}

class JuegoEstadoFin extends JuegoEstado {
  final String motivo;
  JuegoEstadoFin({required this.motivo});
}

abstract class JuegoEvento {}

class EventoColocarNumeroInicial extends JuegoEvento {
  final int x;
  final int y;
  final int valor;
  EventoColocarNumeroInicial(this.x, this.y, this.valor);
}

class EventoAbandonar extends JuegoEvento {}

class JuegoBloc {
  final Tablero tablero;
  JuegoEstado _estado = JuegoEstadoInicial();

  final _controladorEstado = StreamController<JuegoEstado>.broadcast();
  Stream<JuegoEstado> get estadoStream => _controladorEstado.stream;
  JuegoEstado get estadoActual => _estado;

  JuegoBloc(this.tablero);

  void procesarEvento(JuegoEvento evento) {
    if (evento is EventoAbandonar) {
      _estado = JuegoEstadoFin(motivo: 'El jugador abandono la partida');
      _controladorEstado.add(_estado);
      return;
    }

    if (_estado is JuegoEstadoInicial) {
      if (evento is EventoColocarNumeroInicial) {
        final celda = tablero.obtenerCeldaEn(evento.x, evento.y);

        if (celda != null && celda.esEstrella) {
          celda.asignarValor(evento.valor);

          if (tablero.estanEstrellasCompletas()) {
            _estado = JuegoEstadoTurno(mensaje: 'Inicio completado');
          } else {
            final colocadas = tablero
                .obtenerCeldasEstrella()
                .where((c) => c.valor != null)
                .length;
            _estado = JuegoEstadoInicial(estrellasColocadas: colocadas);
          }
        }
      }
    }

    _controladorEstado.add(_estado);
  }

  void dispose() {
    _controladorEstado.close();
  }
}
