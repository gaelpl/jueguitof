import '../juego_logica.dart';

class JuegoTurnoEstado {
  final Tablero tablero;
  final Dado? dadoActual;
  final Celda? celdaAncla;
  final List<Celda> celdasObjetivoValidas;
  final int puntuacionTotal;

  const JuegoTurnoEstado({
    required this.tablero,
    this.dadoActual,
    this.celdaAncla,
    this.celdasObjetivoValidas = const [],
    this.puntuacionTotal = 0,
  });

  JuegoTurnoEstado copyWith({
    Tablero? tablero,
    Dado? dadoActual,
    Celda? celdaAncla,
    List<Celda>? celdasObjetivoValidas,
    int? puntuacionTotal,
    bool limpiarAncla = false,
  }) {
    return JuegoTurnoEstado(
      tablero: tablero ?? this.tablero,
      dadoActual: dadoActual ?? this.dadoActual,
      celdaAncla: limpiarAncla ? null : (celdaAncla ?? this.celdaAncla),
      celdasObjetivoValidas:
          limpiarAncla ? [] : (celdasObjetivoValidas ?? this.celdasObjetivoValidas),
      puntuacionTotal: puntuacionTotal ?? this.puntuacionTotal,
    );
  }
}