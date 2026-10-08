import '../juego_logica.dart';

class JuegoTurnoEstado {
  final Tablero tablero;
  final Dado? dado1;
  final Dado? dado2;
  final int? indiceDadoAncla; // 0 si dado1 es ancla, 1 si dado2 es ancla
  final Celda? celdaAncla;
  final List<Celda> celdasObjetivoValidas;
  final int puntuacionTotal;

  const JuegoTurnoEstado({
    required this.tablero,
    this.dado1,
    this.dado2,
    this.indiceDadoAncla,
    this.celdaAncla,
    this.celdasObjetivoValidas = const [],
    this.puntuacionTotal = 0,
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
    bool limpiarAncla = false,
    bool limpiarDados = false,
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
    );
  }
}
