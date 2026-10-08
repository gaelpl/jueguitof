import '../juego_logica.dart';

abstract class JuegoTurnoEvento {}

/// Evento para lanzar los 2 dados al inicio del turno.
class EventoLanzarDados extends JuegoTurnoEvento {
  final Dado? dado1Forzado;
  final Dado? dado2Forzado;

  EventoLanzarDados({this.dado1Forzado, this.dado2Forzado});
}

/// Evento para seleccionar cuál de los dos dados se usará como valor de Ancla.
/// El otro dado automáticamente se convertirá en el valor a colocar en el tablero.
class EventoSeleccionarDadoAncla extends JuegoTurnoEvento {
  final int indiceDadoAncla; // 0 para el dado 1, 1 para el dado 2
  EventoSeleccionarDadoAncla(this.indiceDadoAncla);
}

/// Evento al tocar una celda llena en el tablero que coincide con el dado de ancla.
class EventoSeleccionarAnclaTablero extends JuegoTurnoEvento {
  final Celda celdaAncla;
  EventoSeleccionarAnclaTablero(this.celdaAncla);
}

/// Evento al tocar una casilla vacía iluminada/válida para colocar el valor del otro dado.
class EventoColocarNumeroEnObjetivo extends JuegoTurnoEvento {
  final Celda celdaObjetivo;
  EventoColocarNumeroEnObjetivo(this.celdaObjetivo);
}

/// Evento para deseleccionar el ancla actual o reiniciar la selección.
class EventoLimpiarSeleccionAncla extends JuegoTurnoEvento {}