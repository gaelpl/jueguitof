import '../../../dominio/entidades/jugador_partida.dart';

abstract class LobbyEvento {
  const LobbyEvento();
}

class CrearSalaSolicitada extends LobbyEvento {
  final int numeroMapa;

  const CrearSalaSolicitada({this.numeroMapa = 1});
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
  final String? tuIdSocket;

  const SalaCreadaRecibida(this.codigo, {this.tuIdSocket});
}

class SalaActualizadaRecibida extends LobbyEvento {
  final String codigo;
  final List<JugadorPartida> jugadores;
  final String? anfitrion;
  final bool iniciada;
  final int numeroMapa;
  final int? puntosParaGanar;

  const SalaActualizadaRecibida({
    required this.codigo,
    required this.jugadores,
    this.anfitrion,
    this.iniciada = false,
    this.numeroMapa = 1,
    this.puntosParaGanar,
  });
}

class PartidaListaRecibida extends LobbyEvento {
  final String codigo;
  final List<JugadorPartida> jugadores;
  final int puntosParaGanar;
  final int numeroMapa;
  final String? anfitrion;
  final String? tuIdSocket;

  const PartidaListaRecibida({
    required this.codigo,
    required this.jugadores,
    required this.puntosParaGanar,
    this.numeroMapa = 1,
    this.anfitrion,
    this.tuIdSocket,
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

class SesionInvalidaRecibida extends LobbyEvento {
  const SesionInvalidaRecibida();
}
