import '../../../dominio/entidades/jugador_partida.dart';

abstract class LobbyEstado {
  const LobbyEstado();
}

class LobbyInicial extends LobbyEstado {
  const LobbyInicial();
}

class CreandoSala extends LobbyEstado {
  const CreandoSala();
}

class EsperandoJugadores extends LobbyEstado {
  final String codigo;
  final List<JugadorPartida> jugadores;
  final String? anfitrion;
  final String? tuIdSocket;
  final int? puntosParaGanar;

  const EsperandoJugadores({
    required this.codigo,
    this.jugadores = const [],
    this.anfitrion,
    this.tuIdSocket,
    this.puntosParaGanar,
  });
}

class IniciandoPartida extends EsperandoJugadores {
  const IniciandoPartida({
    required super.codigo,
    super.jugadores,
    super.anfitrion,
    super.tuIdSocket,
    super.puntosParaGanar,
  });
}

class UniendoASala extends LobbyEstado {
  const UniendoASala();
}

class PartidaLista extends LobbyEstado {
  final String codigo;
  final List<JugadorPartida> jugadores;
  final int puntosParaGanar;
  final String? anfitrion;
  final String? tuIdSocket;

  const PartidaLista({
    required this.codigo,
    required this.jugadores,
    required this.puntosParaGanar,
    this.anfitrion,
    this.tuIdSocket,
  });
}

class ErrorLobby extends LobbyEstado {
  final String mensaje;

  const ErrorLobby({required this.mensaje});
}
