import '../juego_logica.dart';

class InicioJuegoEstado {
  final Tablero tablero;
  final int numeroSeleccionado;

  InicioJuegoEstado({
    required this.tablero,
    this.numeroSeleccionado = 1,
  });

  InicioJuegoEstado copyWith({
    Tablero? tablero,
    int? numeroSeleccionado,
  }) {
    return InicioJuegoEstado(
      tablero: tablero ?? this.tablero,
      numeroSeleccionado: numeroSeleccionado ?? this.numeroSeleccionado,
    );
  }
}