import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../datos/servicios/servicio_socket.dart';
import '../../../dominio/entidades/jugador_partida.dart';
import 'lobby_event.dart';
import 'lobby_state.dart';

export 'lobby_event.dart';
export 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvento, LobbyEstado> {
  final ServicioSocket _servicioSocket;

  late final StreamSubscription<String> _suscripcionSalaCreada;
  late final StreamSubscription<Map<String, dynamic>>
  _suscripcionSalaActualizada;
  late final StreamSubscription<Map<String, dynamic>> _suscripcionPartidaLista;
  late final StreamSubscription<String> _suscripcionErrorSala;
  late final StreamSubscription<String> _suscripcionErrorConexion;

  LobbyBloc({ServicioSocket? servicioSocket})
    : _servicioSocket = servicioSocket ?? ServicioSocket.instancia,
      super(const LobbyInicial()) {
    on<CrearSalaSolicitada>(_alSolicitarCrearSala);
    on<UnirseSalaSolicitada>(_alSolicitarUnirseSala);
    on<IniciarPartidaSolicitada>(_alSolicitarIniciarPartida);
    on<SalaCreadaRecibida>(
      (evento, emitir) => emitir(
        EsperandoJugadores(
          codigo: evento.codigo,
          anfitrion: evento.tuSocketId,
          tuSocketId: evento.tuSocketId,
        ),
      ),
    );
    on<SalaActualizadaRecibida>((evento, emitir) {
      if (evento.iniciada) return;

      final LobbyEstado estadoActual = state;
      final String? tuSocketId = estadoActual is EsperandoJugadores
          ? estadoActual.tuSocketId
          : null;

      if (estadoActual is IniciandoPartida) {
        emitir(
          IniciandoPartida(
            codigo: evento.codigo,
            jugadores: evento.jugadores,
            anfitrion: evento.anfitrion,
            tuSocketId: tuSocketId,
            puntosParaGanar: evento.puntosParaGanar,
          ),
        );
        return;
      }

      emitir(
        EsperandoJugadores(
          codigo: evento.codigo,
          jugadores: evento.jugadores,
          anfitrion: evento.anfitrion,
          tuSocketId: tuSocketId,
          puntosParaGanar: evento.puntosParaGanar,
        ),
      );
    });
    on<PartidaListaRecibida>(
      (evento, emitir) => emitir(
        PartidaLista(
          codigo: evento.codigo,
          jugadores: evento.jugadores,
          puntosParaGanar: evento.puntosParaGanar,
          anfitrion: evento.anfitrion,
          tuSocketId: evento.tuSocketId,
        ),
      ),
    );
    on<ErrorSalaRecibido>(
      (evento, emitir) => emitir(ErrorLobby(mensaje: evento.mensaje)),
    );
    on<ErrorConexionRecibido>(
      (evento, emitir) => emitir(ErrorLobby(mensaje: evento.mensaje)),
    );

    _suscripcionSalaCreada = _servicioSocket.salaCreada.listen(
      (codigo) =>
          add(SalaCreadaRecibida(codigo, tuSocketId: _servicioSocket.idActual)),
    );
    _suscripcionSalaActualizada = _servicioSocket.salaActualizada.listen((
      datos,
    ) {
      add(
        SalaActualizadaRecibida(
          codigo: datos['codigo']?.toString() ?? '',
          jugadores: _parsearJugadores(datos['jugadores']),
          anfitrion: datos['anfitrion']?.toString(),
          iniciada: datos['iniciada'] == true,
          puntosParaGanar: _comoEntero(datos['puntosParaGanar']),
        ),
      );
    });
    _suscripcionPartidaLista = _servicioSocket.partidaLista.listen((datos) {
      add(
        PartidaListaRecibida(
          codigo: datos['codigo']?.toString() ?? '',
          jugadores: _parsearJugadores(datos['jugadores']),
          puntosParaGanar: _comoEntero(datos['puntosParaGanar']) ?? 0,
          anfitrion: datos['anfitrion']?.toString(),
          tuSocketId: datos['tuSocketId']?.toString(),
        ),
      );
    });
    _suscripcionErrorSala = _servicioSocket.errorSala.listen(
      (mensaje) => add(ErrorSalaRecibido(mensaje)),
    );
    _suscripcionErrorConexion = _servicioSocket.errorConexion.listen(
      (mensaje) => add(ErrorConexionRecibido(mensaje)),
    );
  }

  Future<void> _alSolicitarCrearSala(
    CrearSalaSolicitada evento,
    Emitter<LobbyEstado> emitir,
  ) async {
    emitir(const CreandoSala());

    try {
      await _servicioSocket.conectar();
      _servicioSocket.crearSala();
    } catch (error) {
      emitir(ErrorLobby(mensaje: _limpiarMensajeError(error)));
    }
  }

  Future<void> _alSolicitarUnirseSala(
    UnirseSalaSolicitada evento,
    Emitter<LobbyEstado> emitir,
  ) async {
    final String codigo = evento.codigo.trim().toUpperCase();

    if (codigo.isEmpty) {
      emitir(const ErrorLobby(mensaje: 'Ingresa un código de sala válido.'));
      return;
    }

    emitir(const UniendoASala());

    try {
      await _servicioSocket.conectar();
      _servicioSocket.unirseSala(codigo);
    } catch (error) {
      emitir(ErrorLobby(mensaje: _limpiarMensajeError(error)));
    }
  }

  Future<void> _alSolicitarIniciarPartida(
    IniciarPartidaSolicitada evento,
    Emitter<LobbyEstado> emitir,
  ) async {
    final LobbyEstado estadoActual = state;

    if (estadoActual is! EsperandoJugadores) return;

    if (estadoActual.tuSocketId != estadoActual.anfitrion) {
      emitir(
        const ErrorLobby(
          mensaje: 'Solo el anfitrión puede iniciar la partida.',
        ),
      );
      return;
    }

    if (estadoActual.jugadores.length < 2) {
      emitir(
        const ErrorLobby(
          mensaje: 'Se necesitan al menos 2 jugadores para iniciar.',
        ),
      );
      return;
    }

    emitir(
      IniciandoPartida(
        codigo: estadoActual.codigo,
        jugadores: estadoActual.jugadores,
        anfitrion: estadoActual.anfitrion,
        tuSocketId: estadoActual.tuSocketId,
        puntosParaGanar: estadoActual.puntosParaGanar,
      ),
    );

    try {
      if (!_servicioSocket.conectado) {
        await _servicioSocket.conectar();
      }
      _servicioSocket.solicitarInicioPartida(estadoActual.codigo);
    } catch (error) {
      emitir(ErrorLobby(mensaje: _limpiarMensajeError(error)));
    }
  }

  List<JugadorPartida> _parsearJugadores(dynamic valor) {
    if (valor is! List) return const [];

    return valor
        .whereType<Map>()
        .map(
          (jugador) =>
              JugadorPartida.desdeJson(Map<String, dynamic>.from(jugador)),
        )
        .toList();
  }

  int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }

  String _limpiarMensajeError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('StateError: ', '');
  }

  @override
  Future<void> close() async {
    await _suscripcionSalaCreada.cancel();
    await _suscripcionSalaActualizada.cancel();
    await _suscripcionPartidaLista.cancel();
    await _suscripcionErrorSala.cancel();
    await _suscripcionErrorConexion.cancel();
    return super.close();
  }
}
