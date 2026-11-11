import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../../../../nucleo/configuracion/entorno.dart';

class ServicioSocket {
  static const String _urlBase = Entorno.apiUrl;
  static const String _claveToken = 'token_jwt';

  ServicioSocket._interno();

  static final ServicioSocket instancia = ServicioSocket._interno();

  socket_io.Socket? _socket;
  String? _tokenActual;

  final StreamController<String> _controladorSalaCreada =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorPartidaLista =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorDadosLanzados =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorRondaLista =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _controladorErrorSala =
      StreamController<String>.broadcast();
  final StreamController<String> _controladorErrorConexion =
      StreamController<String>.broadcast();
  final StreamController<bool> _controladorRivalConcedio =
      StreamController<bool>.broadcast();
  final StreamController<bool> _controladorRivalDesconectado =
      StreamController<bool>.broadcast();
  final StreamController<bool> _controladorConexionInestable =
      StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorSalaActualizada =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>>
  _controladorPuntuacionesActualizadas =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorPartidaGanada =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorJugadorConcedio =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorJugadorDesconectado =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _enPartida = false;
  bool _conexionInestableActual = false;

  Stream<String> get salaCreada => _controladorSalaCreada.stream;
  Stream<Map<String, dynamic>> get partidaLista =>
      _controladorPartidaLista.stream;
  Stream<Map<String, dynamic>> get dadosLanzados =>
      _controladorDadosLanzados.stream;
  Stream<Map<String, dynamic>> get rondaLista => _controladorRondaLista.stream;
  Stream<String> get errorSala => _controladorErrorSala.stream;
  Stream<String> get errorConexion => _controladorErrorConexion.stream;
  Stream<bool> get rivalConcedio => _controladorRivalConcedio.stream;
  Stream<bool> get rivalDesconectado => _controladorRivalDesconectado.stream;
  Stream<bool> get conexionInestable => _controladorConexionInestable.stream;
  Stream<Map<String, dynamic>> get salaActualizada =>
      _controladorSalaActualizada.stream;
  Stream<Map<String, dynamic>> get puntuacionesActualizadas =>
      _controladorPuntuacionesActualizadas.stream;
  Stream<Map<String, dynamic>> get partidaGanada =>
      _controladorPartidaGanada.stream;
  Stream<Map<String, dynamic>> get jugadorConcedio =>
      _controladorJugadorConcedio.stream;
  Stream<Map<String, dynamic>> get jugadorDesconectado =>
      _controladorJugadorDesconectado.stream;
  bool get conexionInestableActual => _conexionInestableActual;
  String? get idActual => _socket?.id;

  void iniciarPartida() {
    _enPartida = true;
  }

  void finalizarPartida() {
    _enPartida = false;
    _actualizarConexionInestable(false);
  }

  void _actualizarConexionInestable(bool inestable) {
    _conexionInestableActual = inestable;
    _controladorConexionInestable.add(inestable);
  }

  bool get conectado => _socket?.connected ?? false;

  Future<void> conectar() async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    final String? token = preferencias.getString(_claveToken);

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesión activa. Inicia sesión nuevamente.');
    }

    if (_socket != null && _tokenActual == token) {
      if (!_socket!.connected) {
        _socket!.connect();
      }
      return;
    }

    _socket?.dispose();
    _tokenActual = token;

    final socket_io.Socket socket = socket_io.io(
      _urlBase,
      socket_io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket.onConnect((_) {
      if (_enPartida) {
        _actualizarConexionInestable(false);
      }
    });

    socket.onConnectError((_) {
      _controladorErrorConexion.add(
        'No se pudo conectar con el servidor de partidas.',
      );
      if (_enPartida) {
        _actualizarConexionInestable(true);
      }
    });

    socket.onError((_) {
      _controladorErrorConexion.add(
        'Ocurrió un error en la conexión con el servidor.',
      );
    });

    socket.onDisconnect((_) {
      if (_enPartida) {
        _actualizarConexionInestable(true);
      }
    });

    socket.on('sala_creada', (datos) {
      if (datos is String && datos.isNotEmpty) {
        _controladorSalaCreada.add(datos);
      } else if (datos is Map && datos['codigo'] != null) {
        _controladorSalaCreada.add(datos['codigo'].toString());
      }
    });

    socket.on('partida_lista', (datos) {
      if (datos is Map) {
        _controladorPartidaLista.add(Map<String, dynamic>.from(datos));
      }
    });

    socket.on('dados_lanzados', (datos) {
      if (datos is Map) {
        _controladorDadosLanzados.add(Map<String, dynamic>.from(datos));
      }
    });

    socket.on('ronda_lista', (datos) {
      if (datos is Map) {
        _controladorRondaLista.add(Map<String, dynamic>.from(datos));
      }
    });

    socket.on('sala_actualizada', (datos) {
      if (datos is Map) {
        _controladorSalaActualizada.add(Map<String, dynamic>.from(datos));
      }
    });

    socket.on('puntuaciones_actualizadas', (datos) {
      if (datos is Map) {
        _controladorPuntuacionesActualizadas.add(
          Map<String, dynamic>.from(datos),
        );
      }
    });

    socket.on('partida_ganada', (datos) {
      if (datos is Map) {
        _controladorPartidaGanada.add(Map<String, dynamic>.from(datos));
      }
    });

    socket.on('jugador_concedio', (datos) {
      if (datos is Map) {
        _controladorJugadorConcedio.add(Map<String, dynamic>.from(datos));
      }
    });

    socket.on('jugador_desconectado', (datos) {
      if (datos is Map) {
        _controladorJugadorDesconectado.add(Map<String, dynamic>.from(datos));
      }
    });

    socket.on('error_sala', (datos) {
      _controladorErrorSala.add(
        _obtenerMensaje(datos, 'No se pudo unir a la sala.'),
      );
    });

    socket.on('rival_concedio', (_) {
      _controladorRivalConcedio.add(true);
    });

    socket.on('rival_desconectado', (_) {
      _controladorRivalDesconectado.add(true);
    });

    _socket = socket;
    socket.connect();
  }

  void crearSala() {
    final socket_io.Socket? socket = _socket;
    if (socket == null) {
      throw StateError('El socket no está inicializado.');
    }
    socket.emit('crear_sala');
  }

  void unirseSala(String codigo) {
    final socket_io.Socket? socket = _socket;
    if (socket == null) {
      throw StateError('El socket no está inicializado.');
    }
    socket.emit('unirse_sala', codigo.trim().toUpperCase());
  }

  void solicitarInicioPartida(String codigoSala) {
    final socket_io.Socket? socket = _socket;
    if (socket == null) {
      throw StateError('El socket no está inicializado.');
    }
    socket.emit('iniciar_partida', {
      'codigoSala': codigoSala.trim().toUpperCase(),
    });
  }

  void lanzarDados(String codigoSala) {
    final socket_io.Socket? socket = _socket;
    if (socket == null) {
      throw StateError('El socket no está inicializado.');
    }
    socket.emit('lanzar_dados', {
      'codigoSala': codigoSala.trim().toUpperCase(),
    });
  }

  void completarAccionTurno(String codigoSala) {
    final socket_io.Socket? socket = _socket;
    if (socket == null) {
      throw StateError('El socket no está inicializado.');
    }
    socket.emit('accion_turno_completada', {
      'codigoSala': codigoSala.trim().toUpperCase(),
    });
  }

  void actualizarPuntuacion(String codigoSala, int puntuacion) {
    final socket_io.Socket? socket = _socket;
    if (socket == null) {
      throw StateError('El socket no está inicializado.');
    }
    socket.emit('puntuacion_actualizada', {
      'codigoSala': codigoSala.trim().toUpperCase(),
      'puntuacion': puntuacion,
    });
  }

  void concederPartida(String codigoSala) {
    final socket_io.Socket? socket = _socket;
    if (socket == null) {
      throw StateError('El socket no está inicializado.');
    }
    socket.emit('conceder_partida', codigoSala.trim().toUpperCase());
  }

  Future<void> desconectar() async {
    finalizarPartida();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _tokenActual = null;
  }

  String _obtenerMensaje(dynamic datos, String mensajePorDefecto) {
    if (datos is Map && datos['mensaje'] != null) {
      return datos['mensaje'].toString();
    }
    if (datos is String && datos.isNotEmpty) {
      return datos;
    }
    return mensajePorDefecto;
  }
}
