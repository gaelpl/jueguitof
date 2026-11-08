abstract class LobbyEstado {
  const LobbyEstado();
}

class LobbyInicial extends LobbyEstado {
  const LobbyInicial();
}

class CreandoSala extends LobbyEstado {
  const CreandoSala();
}

class EsperandoRival extends LobbyEstado {
  final String codigo;

  const EsperandoRival({required this.codigo});
}

class UniendoASala extends LobbyEstado {
  const UniendoASala();
}

class PartidaLista extends LobbyEstado {
  final String codigo;
  final List<dynamic> jugadores;

  const PartidaLista({
    required this.codigo,
    required this.jugadores,
  });
}

class ErrorLobby extends LobbyEstado {
  final String mensaje;

  const ErrorLobby({required this.mensaje});
}
