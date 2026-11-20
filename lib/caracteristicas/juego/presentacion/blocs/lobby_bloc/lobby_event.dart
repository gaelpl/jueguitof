import '../../../dominio/entidades/jugador_partida.dart';
import '../../../dominio/entidades/modo_partida.dart';

abstract class LobbyEvento {
  const LobbyEvento();
}

class CrearSalaSolicitada extends LobbyEvento {
  final int numeroMapa;
  final ModoPartida modo;

  const CrearSalaSolicitada({
    this.numeroMapa = 1,
    this.modo = ModoPartida.casual,
  });
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
  final ModoPartida modo;

  const SalaCreadaRecibida(
    this.codigo, {
    this.tuIdSocket,
    this.modo = ModoPartida.casual,
  });
}

class SalaActualizadaRecibida extends LobbyEvento {
  final String codigo;
  final List<JugadorPartida> jugadores;
  final String? anfitrion;
  final bool iniciada;
  final int numeroMapa;
  final int? puntosParaGanar;
  final List<String> listosIds;
  final String? tuIdSocket;
  final ModoPartida modo;

  const SalaActualizadaRecibida({
    required this.codigo,
    required this.jugadores,
    this.anfitrion,
    this.iniciada = false,
    this.numeroMapa = 1,
    this.puntosParaGanar,
    this.listosIds = const [],
    this.tuIdSocket,
    this.modo = ModoPartida.casual,
  });
}

class PartidaListaRecibida extends LobbyEvento {
  final String codigo;
  final List<JugadorPartida> jugadores;
  final int puntosParaGanar;
  final int numeroMapa;
  final String? anfitrion;
  final String? tuIdSocket;
  final ModoPartida modo;

  const PartidaListaRecibida({
    required this.codigo,
    required this.jugadores,
    required this.puntosParaGanar,
    this.numeroMapa = 1,
    this.anfitrion,
    this.tuIdSocket,
    this.modo = ModoPartida.casual,
  });
}

class EstadoListosRecibido extends LobbyEvento {
  final String codigo;
  final List<String> listosIds;
  final bool todosListos;
  final String? tuIdSocket;

  const EstadoListosRecibido({
    required this.codigo,
    this.listosIds = const [],
    this.todosListos = false,
    this.tuIdSocket,
  });
}

class CambiarListoJugador extends LobbyEvento {
  final String codigo;
  final bool listo;

  const CambiarListoJugador({required this.codigo, required this.listo});
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
