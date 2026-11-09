import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class ServicioSocket {
  static const String _urlBase = 'http://localhost:3000';
  static const String _claveToken = 'token_jwt';

  ServicioSocket._interno();

  static final ServicioSocket instancia = ServicioSocket._interno();

  socket_io.Socket? _socket;
  String? _tokenActual;

  final StreamController<String> _controladorSalaCreada =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorPartidaLista =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _controladorErrorSala =
      StreamController<String>.broadcast();
  final StreamController<String> _controladorErrorConexion =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _controladorMovimientoRecibido =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _controladorRivalConcedio =
      StreamController<bool>.broadcast();

  Stream<String> get salaCreada => _controladorSalaCreada.stream;
  Stream<Map<String, dynamic>> get partidaLista =>
      _controladorPartidaLista.stream;
  Stream<String> get errorSala => _controladorErrorSala.stream;
  Stream<String> get errorConexion => _controladorErrorConexion.stream;
  Stream<Map<String, dynamic>> get movimientoRecibido =>
      _controladorMovimientoRecibido.stream;
  Stream<bool> get rivalConcedio => _controladorRivalConcedio.stream;

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
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket.onConnect((_) {});

    socket.onConnectError((_) {
      _controladorErrorConexion.add(
        'No se pudo conectar con el servidor de partidas.',
      );
    });

    socket.onError((_) {
      _controladorErrorConexion.add(
        'Ocurrió un error en la conexión con el servidor.',
      );
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

    socket.on('error_sala', (datos) {
      _controladorErrorSala.add(
        _obtenerMensaje(datos, 'No se pudo unir a la sala.'),
      );
    });

    socket.on('movimiento_recibido', (datos) {
      if (datos is Map) {
        _controladorMovimientoRecibido.add(Map<String, dynamic>.from(datos));
      }
    });

    socket.on('rival_concedio', (_) {
      _controladorRivalConcedio.add(true);
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

  void enviarMovimiento(String codigoSala, Map<String, dynamic> datos) {
    final socket_io.Socket? socket = _socket;
    if (socket == null) {
      throw StateError('El socket no está inicializado.');
    }
    socket.emit('movimiento_tablero', {
      ...datos,
      'codigoSala': codigoSala.trim().toUpperCase(),
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
