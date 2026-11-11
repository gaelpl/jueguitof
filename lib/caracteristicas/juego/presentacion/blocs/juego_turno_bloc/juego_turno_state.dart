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
  final int? puntosParaGanar;
  final String? tuIdSocket;

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
    this.puntosParaGanar,
    this.tuIdSocket,
  });

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
    int? puntosParaGanar,
    String? tuIdSocket,
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
      puntosParaGanar: puntosParaGanar ?? this.puntosParaGanar,
      tuIdSocket: tuIdSocket ?? this.tuIdSocket,
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
    super.puntosParaGanar,
    super.tuIdSocket,
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
    super.puntosParaGanar,
    super.tuIdSocket,
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
    super.puntosParaGanar,
    super.tuIdSocket,
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
    super.puntosParaGanar,
    super.tuIdSocket,
    required this.idSocketGanador,
    required this.ganadorUsuario,
    required this.esGanadorLocal,
  });
}
