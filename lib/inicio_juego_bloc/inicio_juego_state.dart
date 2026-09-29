import '../juego_logica.dart';

class InicioJuegoEstado {
  final Tablero tablero;
  final int numeroSeleccionado;
  final bool estanListasEstrellas;
  final bool juegoIniciado;

  InicioJuegoEstado({
    required this.tablero,
    this.numeroSeleccionado = 1,
    this.estanListasEstrellas = false,
    this.juegoIniciado = false,
  });

  InicioJuegoEstado copyWith({
    Tablero? tablero,
    int? numeroSeleccionado,
    bool? estanListasEstrellas,
    bool? juegoIniciado,
  }) {
    return InicioJuegoEstado(
      tablero: tablero ?? this.tablero,
      numeroSeleccionado: numeroSeleccionado ?? this.numeroSeleccionado,
      estanListasEstrellas:
          estanListasEstrellas ?? this.estanListasEstrellas,
      juegoIniciado: juegoIniciado ?? this.juegoIniciado,
    );
  }
}