import '../juego_logica.dart';

abstract class InicioJuegoEvento {}

class EventoSeleccionarNumero extends InicioJuegoEvento {
  final int numero;
  EventoSeleccionarNumero(this.numero);
}