import 'dart:async';

import '../../datos/servicios/servicio_socket.dart';
import '../../dominio/logica/juego_logica.dart';

abstract class JuegoEstado {}

class JuegoEstadoInicial extends JuegoEstado {
  final int estrellasColocadas;
  JuegoEstadoInicial({this.estrellasColocadas = 0});
}

class JuegoEstadoTurno extends JuegoEstado {
  final String mensaje;
  JuegoEstadoTurno({this.mensaje = 'Turno activo'});
}

class JuegoEstadoFin extends JuegoEstado {
  final String motivo;
  JuegoEstadoFin({required this.motivo});
}

class JuegoGanadoPorAbandono extends JuegoEstado {}

class JuegoCanceladoDesconexion extends JuegoEstado {}

abstract class JuegoEvento {}

class EventoColocarNumeroInicial extends JuegoEvento {
  final int x;
  final int y;
  final int valor;
  EventoColocarNumeroInicial(this.x, this.y, this.valor);
}

class EventoMovimientoRecibido extends JuegoEvento {
  final int x;
  final int y;
  final int valor;
  EventoMovimientoRecibido(this.x, this.y, this.valor);
}

class EventoAbandonar extends JuegoEvento {}

class EventoConcederPartida extends JuegoEvento {}

class EventoRivalConcedio extends JuegoEvento {}

class EventoRivalDesconectado extends JuegoEvento {}

class JuegoBloc {
  final Tablero tablero;
  final ServicioSocket _servicioSocket;
  final String? _codigoSala;

  JuegoEstado _estado = JuegoEstadoInicial();

  final _controladorEstado = StreamController<JuegoEstado>.broadcast();
  Stream<JuegoEstado> get estadoStream => _controladorEstado.stream;
  JuegoEstado get estadoActual => _estado;

  late final StreamSubscription<Map<String, dynamic>> _suscripcionMovimiento;
  late final StreamSubscription<bool> _suscripcionRivalConcedio;
  late final StreamSubscription<bool> _suscripcionRivalDesconectado;

  JuegoBloc(this.tablero, {ServicioSocket? servicioSocket, String? codigoSala})
    : _servicioSocket = servicioSocket ?? ServicioSocket.instancia,
      _codigoSala = codigoSala {
    _suscripcionMovimiento = _servicioSocket.movimientoRecibido.listen((datos) {
      final int? x = _comoEntero(datos['x'] ?? datos['columna']);
      final int? y = _comoEntero(datos['y'] ?? datos['fila']);
      final int? valor = _comoEntero(datos['valor']);

      if (x == null || y == null || valor == null) return;

      procesarEvento(EventoMovimientoRecibido(x, y, valor));
    });

    _suscripcionRivalConcedio = _servicioSocket.rivalConcedio.listen(
      (_) => procesarEvento(EventoRivalConcedio()),
    );

    _suscripcionRivalDesconectado = _servicioSocket.rivalDesconectado.listen(
      (_) => procesarEvento(EventoRivalDesconectado()),
    );

    if (_codigoSala != null) {
      _servicioSocket.iniciarPartida();
    }
  }

  void procesarEvento(JuegoEvento evento) {
    if (evento is EventoConcederPartida) {
      _concederPartida();
      return;
    }

    if (evento is EventoRivalConcedio) {
      _servicioSocket.finalizarPartida();
      _estado = JuegoGanadoPorAbandono();
      _controladorEstado.add(_estado);
      return;
    }

    if (evento is EventoRivalDesconectado) {
      _servicioSocket.finalizarPartida();
      _estado = JuegoCanceladoDesconexion();
      _controladorEstado.add(_estado);
      return;
    }

    if (evento is EventoAbandonar) {
      _estado = JuegoEstadoFin(motivo: 'El jugador abandono la partida');
      _controladorEstado.add(_estado);
      return;
    }

    if (evento is EventoMovimientoRecibido) {
      final celda = tablero.obtenerCeldaEn(evento.x, evento.y);

      if (celda != null) {
        celda.asignarValor(evento.valor);
        _actualizarEstadoTrasMovimiento();
        _controladorEstado.add(_estado);
      }
      return;
    }

    if (_estado is JuegoEstadoInicial) {
      if (evento is EventoColocarNumeroInicial) {
        final celda = tablero.obtenerCeldaEn(evento.x, evento.y);

        if (celda != null && celda.esEstrella) {
          celda.asignarValor(evento.valor);
          _actualizarEstadoTrasMovimiento();
          _controladorEstado.add(_estado);
          _emitirMovimiento(evento.x, evento.y, evento.valor);
          return;
        }
      }
    }

    _controladorEstado.add(_estado);
  }

  void _actualizarEstadoTrasMovimiento() {
    if (tablero.estanEstrellasCompletas()) {
      _estado = JuegoEstadoTurno(mensaje: 'Inicio completado');
      return;
    }

    final colocadas = tablero
        .obtenerCeldasEstrella()
        .where((c) => c.valor != null)
        .length;

    _estado = _estado is JuegoEstadoInicial
        ? JuegoEstadoInicial(estrellasColocadas: colocadas)
        : JuegoEstadoTurno(mensaje: 'Movimiento recibido');
  }

  void _concederPartida() {
    if (_codigoSala == null || !_servicioSocket.conectado) return;

    try {
      _servicioSocket.concederPartida(_codigoSala);
    } catch (_) {
      return;
    }
  }

  void _emitirMovimiento(int x, int y, int valor) {
    if (_codigoSala == null || !_servicioSocket.conectado) return;

    try {
      _servicioSocket.enviarMovimiento(_codigoSala, {
        'x': x,
        'y': y,
        'valor': valor,
      });
    } catch (_) {
      return;
    }
  }

  int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }

  void dispose() {
    _suscripcionMovimiento.cancel();
    _suscripcionRivalConcedio.cancel();
    _suscripcionRivalDesconectado.cancel();
    if (_codigoSala != null) {
      _servicioSocket.finalizarPartida();
    }
    _controladorEstado.close();
  }
}
