import '../../../dominio/entidades/jugador_partida.dart';

abstract class LobbyEvento {
  const LobbyEvento();
}

class CrearSalaSolicitada extends LobbyEvento {
  const CrearSalaSolicitada();
}

class UnirseSalaSolicitada extends LobbyEvento {
  final String codigo;

  const UnirseSalaSolicitada(this.codigo);
}

class IniciarPartidaSolicitada extends LobbyEvento {
  final String codigo;

  const IniciarPartidaSolicitada(this.codigo);
}

class SalaCreadaRecibida extends LobbyEvento {
  final String codigo;
  final String? tuSocketId;

  const SalaCreadaRecibida(this.codigo, {this.tuSocketId});
}

class SalaActualizadaRecibida extends LobbyEvento {
  final String codigo;
  final List<JugadorPartida> jugadores;
  final String? anfitrion;
  final bool iniciada;
  final int? puntosParaGanar;

  const SalaActualizadaRecibida({
    required this.codigo,
    required this.jugadores,
    this.anfitrion,
    this.iniciada = false,
    this.puntosParaGanar,
  });
}

class PartidaListaRecibida extends LobbyEvento {
  final String codigo;
  final List<JugadorPartida> jugadores;
  final int puntosParaGanar;
  final String? anfitrion;
  final String? tuSocketId;

  const PartidaListaRecibida({
    required this.codigo,
    required this.jugadores,
    required this.puntosParaGanar,
    this.anfitrion,
    this.tuSocketId,
  });
}

class ErrorSalaRecibido extends LobbyEvento {
  final String mensaje;

  const ErrorSalaRecibido(this.mensaje);
}

class ErrorConexionRecibido extends LobbyEvento {
  final String mensaje;

  const ErrorConexionRecibido(this.mensaje);
}
