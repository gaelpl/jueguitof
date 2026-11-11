import '../../../dominio/entidades/jugador_partida.dart';
import '../../../dominio/logica/juego_logica.dart';

abstract class JuegoTurnoEvento {}

/// Evento para lanzar los 2 dados al inicio del turno.
class EventoLanzarDados extends JuegoTurnoEvento {
  final Dado? dado1Forzado;
  final Dado? dado2Forzado;

  EventoLanzarDados({this.dado1Forzado, this.dado2Forzado});
}

class EventoDadosLanzados extends JuegoTurnoEvento {
  final Dado dado1;
  final Dado dado2;
  final String? anfitrion;
  final int numeroRonda;
  final int segundosRestantes;
  final int duracionRondaSegundos;

  EventoDadosLanzados({
    required this.dado1,
    required this.dado2,
    this.anfitrion,
    this.numeroRonda = 1,
    this.segundosRestantes = 300,
    this.duracionRondaSegundos = 300,
  });
}

class EventoSaltarTurno extends JuegoTurnoEvento {}

class EventoTickRonda extends JuegoTurnoEvento {}

class EventoRondaLista extends JuegoTurnoEvento {
  final String? anfitrion;
  final int numeroRonda;
  final String motivo;

  EventoRondaLista({
    this.anfitrion,
    this.numeroRonda = 0,
    this.motivo = 'completada',
  });
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

/// Evento al tocar una casilla que no es un ancla válida ni un objetivo permitido.
class EventoMovimientoInvalido extends JuegoTurnoEvento {
  final Celda celda;

  EventoMovimientoInvalido(this.celda);
}

/// Evento para limpiar el mensaje didáctico cuando expire su temporizador.
class EventoLimpiarMensajeAyuda extends JuegoTurnoEvento {}

class EventoRendirse extends JuegoTurnoEvento {}

class EventoRivalConcedio extends JuegoTurnoEvento {}

class EventoRivalDesconectado extends JuegoTurnoEvento {}

class EventoPuntuacionesActualizadas extends JuegoTurnoEvento {
  final List<JugadorPartida> jugadores;
  final int? puntosParaGanar;

  EventoPuntuacionesActualizadas({
    required this.jugadores,
    this.puntosParaGanar,
  });
}

class EventoPartidaGanada extends JuegoTurnoEvento {
  final String? idSocketGanador;
  final String? ganadorUsuario;
  final List<JugadorPartida> jugadores;
  final int? puntosParaGanar;

  EventoPartidaGanada({
    this.idSocketGanador,
    this.ganadorUsuario,
    this.jugadores = const [],
    this.puntosParaGanar,
  });
}

class EventoJugadorSalio extends JuegoTurnoEvento {
  final String usuario;
  final bool fueDesconexion;
  final List<JugadorPartida> jugadores;
  final String? anfitrion;

  EventoJugadorSalio({
    required this.usuario,
    required this.fueDesconexion,
    this.jugadores = const [],
    this.anfitrion,
  });
}
