import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../datos/servicios/servicio_socket.dart';
import 'lobby_event.dart';
import 'lobby_state.dart';

export 'lobby_event.dart';
export 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvento, LobbyEstado> {
  final ServicioSocket _servicioSocket;

  late final StreamSubscription<String> _suscripcionSalaCreada;
  late final StreamSubscription<Map<String, dynamic>> _suscripcionPartidaLista;
  late final StreamSubscription<String> _suscripcionErrorSala;
  late final StreamSubscription<String> _suscripcionErrorConexion;

  LobbyBloc({ServicioSocket? servicioSocket})
      : _servicioSocket = servicioSocket ?? ServicioSocket.instancia,
        super(const LobbyInicial()) {
    on<CrearSalaSolicitada>(_alSolicitarCrearSala);
    on<UnirseSalaSolicitada>(_alSolicitarUnirseSala);
    on<SalaCreadaRecibida>(
      (evento, emitir) => emitir(EsperandoRival(codigo: evento.codigo)),
    );
    on<PartidaListaRecibida>(
      (evento, emitir) => emitir(
        PartidaLista(
          codigo: evento.codigo,
          jugadores: evento.jugadores,
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
      (codigo) => add(SalaCreadaRecibida(codigo)),
    );
    _suscripcionPartidaLista = _servicioSocket.partidaLista.listen((datos) {
      final List<dynamic> jugadores =
          datos['jugadores'] is List ? datos['jugadores'] as List<dynamic> : <dynamic>[];
      add(
        PartidaListaRecibida(
          codigo: datos['codigo']?.toString() ?? '',
          jugadores: jugadores,
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

  String _limpiarMensajeError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('StateError: ', '');
  }

  @override
  Future<void> close() async {
    await _suscripcionSalaCreada.cancel();
    await _suscripcionPartidaLista.cancel();
    await _suscripcionErrorSala.cancel();
    await _suscripcionErrorConexion.cancel();
    return super.close();
  }
}
