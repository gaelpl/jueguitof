import '../juego_logica.dart';

abstract class JuegoTurnoEvento {}

/// Evento para lanzar el dado al inicio del turno.
class EventoLanzarDado extends JuegoTurnoEvento {
  final Dado? dadoForzado;
  EventoLanzarDado({this.dadoForzado});
}

/// Evento al tocar una celda con valor para establecerla como Ancla.
class EventoSeleccionarAncla extends JuegoTurnoEvento {
  final Celda celdaAncla;
  EventoSeleccionarAncla(this.celdaAncla);
}

/// Evento al tocar una casilla vacía iluminada/válida para colocar el número del dado.
class EventoColocarNumeroEnObjetivo extends JuegoTurnoEvento {
  final Celda celdaObjetivo;
  EventoColocarNumeroEnObjetivo(this.celdaObjetivo);
}

/// Evento para deseleccionar el ancla actual.
class EventoLimpiarSeleccionAncla extends JuegoTurnoEvento {}