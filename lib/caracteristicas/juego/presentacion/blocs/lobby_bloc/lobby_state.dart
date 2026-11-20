import '../../../dominio/entidades/jugador_partida.dart';
import '../../../dominio/entidades/modo_partida.dart';

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
  final int numeroMapa;
  final List<String> listosIds;
  final ModoPartida modo;

  const EsperandoJugadores({
    required this.codigo,
    this.jugadores = const [],
    this.anfitrion,
    this.tuIdSocket,
    this.puntosParaGanar,
    this.numeroMapa = 1,
    this.listosIds = const [],
    this.modo = ModoPartida.casual,
  });

  bool get todosListos =>
      jugadores.isNotEmpty &&
      jugadores.every(
        (jugador) => jugador.listo || listosIds.contains(jugador.idSocket),
      );
}

class IniciandoPartida extends EsperandoJugadores {
  const IniciandoPartida({
    required super.codigo,
    super.jugadores,
    super.anfitrion,
    super.tuIdSocket,
    super.puntosParaGanar,
    super.numeroMapa,
    super.listosIds,
    super.modo,
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
  final int numeroMapa;
  final ModoPartida modo;

  const PartidaLista({
    required this.codigo,
    required this.jugadores,
    required this.puntosParaGanar,
    this.anfitrion,
    this.tuIdSocket,
    this.numeroMapa = 1,
    this.modo = ModoPartida.casual,
  });
}

class ErrorLobby extends LobbyEstado {
  final String mensaje;

  const ErrorLobby({required this.mensaje});
}

class SesionExpiradaLobby extends LobbyEstado {
  const SesionExpiradaLobby();
}
