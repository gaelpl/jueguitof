import '../juego_logica.dart';

abstract class InicioJuegoEvento {}

class EventoSeleccionarNumero extends InicioJuegoEvento {
  final int numero;
  EventoSeleccionarNumero(this.numero);
}

class EventoColocarNumeroEnEstrella extends InicioJuegoEvento {
  final int columna;
  final int fila;
  EventoColocarNumeroEnEstrella(this.columna, this.fila);
}