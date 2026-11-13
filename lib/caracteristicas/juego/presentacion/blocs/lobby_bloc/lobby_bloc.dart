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
  late final StreamSubscription<bool> _suscripcionSesionInvalida;

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
          anfitrion: evento.tuIdSocket,
          tuIdSocket: evento.tuIdSocket,
        ),
      ),
    );
    on<SalaActualizadaRecibida>((evento, emitir) {
      if (evento.iniciada) return;

      final LobbyEstado estadoActual = state;
      final String? tuIdSocket = estadoActual is EsperandoJugadores
          ? estadoActual.tuIdSocket
          : null;

      if (estadoActual is IniciandoPartida) {
        emitir(
          IniciandoPartida(
            codigo: evento.codigo,
            jugadores: evento.jugadores,
            anfitrion: evento.anfitrion,
            tuIdSocket: tuIdSocket,
            puntosParaGanar: evento.puntosParaGanar,
            numeroMapa: evento.numeroMapa,
          ),
        );
        return;
      }

      emitir(
        EsperandoJugadores(
          codigo: evento.codigo,
          jugadores: evento.jugadores,
          anfitrion: evento.anfitrion,
          tuIdSocket: tuIdSocket,
          puntosParaGanar: evento.puntosParaGanar,
          numeroMapa: evento.numeroMapa,
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
          tuIdSocket: evento.tuIdSocket,
          numeroMapa: evento.numeroMapa,
        ),
      ),
    );
    on<ErrorSalaRecibido>(
      (evento, emitir) => emitir(ErrorLobby(mensaje: evento.mensaje)),
    );
    on<ErrorConexionRecibido>(
      (evento, emitir) => emitir(ErrorLobby(mensaje: evento.mensaje)),
    );
    on<SesionInvalidaRecibida>(
      (evento, emitir) => emitir(const SesionExpiradaLobby()),
    );

    _suscripcionSalaCreada = _servicioSocket.salaCreada.listen(
      (codigo) =>
          add(SalaCreadaRecibida(codigo, tuIdSocket: _servicioSocket.idActual)),
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
          numeroMapa: _comoEntero(datos['numeroMapa']) ?? 1,
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
          numeroMapa: _comoEntero(datos['numeroMapa']) ?? 1,
          anfitrion: datos['anfitrion']?.toString(),
          tuIdSocket: datos['tuSocketId']?.toString(),
        ),
      );
    });
    _suscripcionErrorSala = _servicioSocket.errorSala.listen(
      (mensaje) => add(ErrorSalaRecibido(mensaje)),
    );
    _suscripcionErrorConexion = _servicioSocket.errorConexion.listen(
      (mensaje) => add(ErrorConexionRecibido(mensaje)),
    );
    _suscripcionSesionInvalida = _servicioSocket.sesionInvalida.listen(
      (_) => add(const SesionInvalidaRecibida()),
    );
  }

  Future<void> _alSolicitarCrearSala(
    CrearSalaSolicitada evento,
    Emitter<LobbyEstado> emitir,
  ) async {
    emitir(const CreandoSala());

    try {
      await _servicioSocket.conectar();
      _servicioSocket.crearSala(numeroMapa: evento.numeroMapa);
    } on SesionNoActivaException {
      emitir(const SesionExpiradaLobby());
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
    } on SesionNoActivaException {
      emitir(const SesionExpiradaLobby());
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

    if (estadoActual.tuIdSocket != estadoActual.anfitrion) {
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
        tuIdSocket: estadoActual.tuIdSocket,
        puntosParaGanar: estadoActual.puntosParaGanar,
        numeroMapa: estadoActual.numeroMapa,
      ),
    );

    try {
      if (!_servicioSocket.conectado) {
        await _servicioSocket.conectar();
      }
      _servicioSocket.solicitarInicioPartida(estadoActual.codigo);
    } on SesionNoActivaException {
      emitir(const SesionExpiradaLobby());
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
    await _suscripcionSesionInvalida.cancel();
    return super.close();
  }
}
