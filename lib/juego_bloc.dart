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

  void dispose() {
    _controladorEstado.close();
  }
}