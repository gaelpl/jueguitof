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

class SalaCreadaRecibida extends LobbyEvento {
  final String codigo;

  const SalaCreadaRecibida(this.codigo);
}

class PartidaListaRecibida extends LobbyEvento {
  final String codigo;
  final List<dynamic> jugadores;

  const PartidaListaRecibida({
    required this.codigo,
    required this.jugadores,
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
