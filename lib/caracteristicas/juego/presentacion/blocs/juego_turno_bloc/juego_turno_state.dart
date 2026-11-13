import '../../../dominio/entidades/jugador_partida.dart';
import '../../../dominio/logica/juego_logica.dart';

class JuegoTurnoEstado {
  final Tablero tablero;
  final Dado? dado1;
  final Dado? dado2;
  final int? indiceDadoAncla; // 0 si dado1 es ancla, 1 si dado2 es ancla
  final Celda? celdaAncla;
  final List<Celda> celdasObjetivoValidas;
  final int puntuacionTotal;
  final String? mensajeAyuda;
  final List<JugadorPartida> jugadores;
  final List<RegistroRegion> historialRegiones;
  final int? puntosParaGanar;
  final String? tuIdSocket;
  final String? anfitrion;
  final int numeroRonda;
  final bool rondaActiva;
  final bool accionTurnoCompletada;
  final bool esperandoDados;
  final int segundosRestantesRonda;
  final int duracionRondaSegundos;
  final bool todosListos;
  final int jugadoresListos;
  final int totalJugadores;

  const JuegoTurnoEstado({
    required this.tablero,
    this.dado1,
    this.dado2,
    this.indiceDadoAncla,
    this.celdaAncla,
    this.celdasObjetivoValidas = const [],
    this.puntuacionTotal = 0,
    this.mensajeAyuda,
    this.jugadores = const [],
    this.historialRegiones = const [],
    this.puntosParaGanar,
    this.tuIdSocket,
    this.anfitrion,
    this.numeroRonda = 0,
    this.rondaActiva = false,
    this.accionTurnoCompletada = false,
    this.esperandoDados = false,
    this.segundosRestantesRonda = 0,
    this.duracionRondaSegundos = 300,
    this.todosListos = false,
    this.jugadoresListos = 0,
    this.totalJugadores = 0,
  });

  bool get esMultijugador => anfitrion != null;

  bool get esAnfitrion =>
      esMultijugador && tuIdSocket != null && tuIdSocket == anfitrion;

  bool get esperandoJugadoresListos =>
      esMultijugador && esAnfitrion && !todosListos && !rondaActiva;

  bool get puedeLanzarDados =>
      !esMultijugador ||
      (esAnfitrion && !rondaActiva && !esperandoDados && todosListos);

  bool get puedeActuar =>
      !esMultijugador || (rondaActiva && !accionTurnoCompletada);

  bool get puedeSaltarTurno =>
      esMultijugador && rondaActiva && !accionTurnoCompletada;

  /// Dado elegido para buscar la casilla Ancla en el tablero.
  Dado? get dadoAncla {
    if (indiceDadoAncla == 0) return dado1;
    if (indiceDadoAncla == 1) return dado2;
    return null;
  }

  /// Dado cuyo valor se colocará en la casilla adyacente vacía.
  Dado? get dadoColocar {
    if (indiceDadoAncla == 0) return dado2;
    if (indiceDadoAncla == 1) return dado1;
    return null;
  }

  JuegoTurnoEstado copyWith({
    Tablero? tablero,
    Dado? dado1,
    Dado? dado2,
    int? indiceDadoAncla,
    Celda? celdaAncla,
    List<Celda>? celdasObjetivoValidas,
    int? puntuacionTotal,
    String? mensajeAyuda,
    List<JugadorPartida>? jugadores,
    List<RegistroRegion>? historialRegiones,
    int? puntosParaGanar,
    String? tuIdSocket,
    String? anfitrion,
    int? numeroRonda,
    bool? rondaActiva,
    bool? accionTurnoCompletada,
    bool? esperandoDados,
    int? segundosRestantesRonda,
    int? duracionRondaSegundos,
    bool? todosListos,
    int? jugadoresListos,
    int? totalJugadores,
    bool limpiarAncla = false,
    bool limpiarDados = false,
    bool limpiarMensajeAyuda = false,
  }) {
    return JuegoTurnoEstado(
      tablero: tablero ?? this.tablero,
      dado1: limpiarDados ? null : (dado1 ?? this.dado1),
      dado2: limpiarDados ? null : (dado2 ?? this.dado2),
      indiceDadoAncla: limpiarDados
          ? null
          : (indiceDadoAncla ?? this.indiceDadoAncla),
      celdaAncla: (limpiarDados || limpiarAncla)
          ? null
          : (celdaAncla ?? this.celdaAncla),
      celdasObjetivoValidas: (limpiarDados || limpiarAncla)
          ? const []
          : (celdasObjetivoValidas ?? this.celdasObjetivoValidas),
      puntuacionTotal: puntuacionTotal ?? this.puntuacionTotal,
      mensajeAyuda: limpiarMensajeAyuda
          ? null
          : (mensajeAyuda ?? this.mensajeAyuda),
      jugadores: jugadores ?? this.jugadores,
      historialRegiones: historialRegiones ?? this.historialRegiones,
      puntosParaGanar: puntosParaGanar ?? this.puntosParaGanar,
      tuIdSocket: tuIdSocket ?? this.tuIdSocket,
      anfitrion: anfitrion ?? this.anfitrion,
      numeroRonda: numeroRonda ?? this.numeroRonda,
      rondaActiva: rondaActiva ?? this.rondaActiva,
      accionTurnoCompletada:
          accionTurnoCompletada ?? this.accionTurnoCompletada,
      esperandoDados: esperandoDados ?? this.esperandoDados,
      segundosRestantesRonda:
          segundosRestantesRonda ?? this.segundosRestantesRonda,
      duracionRondaSegundos:
          duracionRondaSegundos ?? this.duracionRondaSegundos,
      todosListos: todosListos ?? this.todosListos,
      jugadoresListos: jugadoresListos ?? this.jugadoresListos,
      totalJugadores: totalJugadores ?? this.totalJugadores,
    );
  }
}

class JuegoGanadoPorAbandono extends JuegoTurnoEstado {
  const JuegoGanadoPorAbandono({
    required super.tablero,
    super.dado1,
    super.dado2,
    super.indiceDadoAncla,
    super.celdaAncla,
    super.celdasObjetivoValidas,
    super.puntuacionTotal,
    super.mensajeAyuda,
    super.jugadores,
    super.historialRegiones,
    super.puntosParaGanar,
    super.tuIdSocket,
    super.anfitrion,
    super.numeroRonda,
    super.rondaActiva,
    super.accionTurnoCompletada,
    super.esperandoDados,
    super.segundosRestantesRonda,
    super.duracionRondaSegundos,
  });
}

class JuegoRendicionLocal extends JuegoTurnoEstado {
  const JuegoRendicionLocal({
    required super.tablero,
    super.dado1,
    super.dado2,
    super.indiceDadoAncla,
    super.celdaAncla,
    super.celdasObjetivoValidas,
    super.puntuacionTotal,
    super.mensajeAyuda,
    super.jugadores,
    super.historialRegiones,
    super.puntosParaGanar,
    super.tuIdSocket,
    super.anfitrion,
    super.numeroRonda,
    super.rondaActiva,
    super.accionTurnoCompletada,
    super.esperandoDados,
    super.segundosRestantesRonda,
    super.duracionRondaSegundos,
  });
}

class JuegoCanceladoDesconexion extends JuegoTurnoEstado {
  const JuegoCanceladoDesconexion({
    required super.tablero,
    super.dado1,
    super.dado2,
    super.indiceDadoAncla,
    super.celdaAncla,
    super.celdasObjetivoValidas,
    super.puntuacionTotal,
    super.mensajeAyuda,
    super.jugadores,
    super.historialRegiones,
    super.puntosParaGanar,
    super.tuIdSocket,
    super.anfitrion,
    super.numeroRonda,
    super.rondaActiva,
    super.accionTurnoCompletada,
    super.esperandoDados,
    super.segundosRestantesRonda,
    super.duracionRondaSegundos,
  });
}

class JuegoFinalizadoPorPuntos extends JuegoTurnoEstado {
  final String? idSocketGanador;
  final String? ganadorUsuario;
  final bool esGanadorLocal;

  const JuegoFinalizadoPorPuntos({
    required super.tablero,
    super.dado1,
    super.dado2,
    super.indiceDadoAncla,
    super.celdaAncla,
    super.celdasObjetivoValidas,
    super.puntuacionTotal,
    super.mensajeAyuda,
    super.jugadores,
    super.historialRegiones,
    super.puntosParaGanar,
    super.tuIdSocket,
    super.anfitrion,
    super.numeroRonda,
    super.rondaActiva,
    super.accionTurnoCompletada,
    super.esperandoDados,
    super.segundosRestantesRonda,
    super.duracionRondaSegundos,
    required this.idSocketGanador,
    required this.ganadorUsuario,
    required this.esGanadorLocal,
  });
}
