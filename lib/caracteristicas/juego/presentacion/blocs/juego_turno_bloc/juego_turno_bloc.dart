import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../datos/servicios/servicio_socket.dart';
import '../../../dominio/entidades/jugador_partida.dart';
import '../../../dominio/logica/juego_logica.dart';
import 'juego_turno_event.dart';
import 'juego_turno_state.dart';

export 'juego_turno_event.dart';
export 'juego_turno_state.dart';

class JuegoTurnoBloc extends Bloc<JuegoTurnoEvento, JuegoTurnoEstado> {
  final ServicioSocket _servicioSocket;
  final String? _codigoSala;
  final Duration _duracionMensajeAyuda;
  String? _tuSocketId;
  Timer? _temporizadorMensajeAyuda;

  late final StreamSubscription<Map<String, dynamic>> _suscripcionMovimiento;
  late final StreamSubscription<bool> _suscripcionRivalConcedio;
  late final StreamSubscription<bool> _suscripcionRivalDesconectado;
  late final StreamSubscription<Map<String, dynamic>>
  _suscripcionPuntuacionesActualizadas;
  late final StreamSubscription<Map<String, dynamic>> _suscripcionPartidaGanada;
  late final StreamSubscription<Map<String, dynamic>>
  _suscripcionJugadorConcedio;
  late final StreamSubscription<Map<String, dynamic>>
  _suscripcionJugadorDesconectado;

  JuegoTurnoBloc(
    Tablero tableroInicial, {
    ServicioSocket? servicioSocket,
    String? codigoSala,
    Duration? duracionMensajeAyuda,
    List<JugadorPartida> jugadores = const [],
    int? puntosParaGanar,
    String? tuSocketId,
  }) : _servicioSocket = servicioSocket ?? ServicioSocket.instancia,
       _codigoSala = codigoSala,
       _tuSocketId = tuSocketId,
       _duracionMensajeAyuda =
           duracionMensajeAyuda ?? const Duration(seconds: 4),
       super(
         JuegoTurnoEstado(
           tablero: tableroInicial,
           puntuacionTotal: calcularPuntuacionTotal(tableroInicial),
           jugadores: jugadores,
           puntosParaGanar: puntosParaGanar,
           tuSocketId: tuSocketId,
         ),
       ) {
    on<EventoLanzarDados>(_onLanzarDados);
    on<EventoSeleccionarDadoAncla>(_onSeleccionarDadoAncla);
    on<EventoSeleccionarAnclaTablero>(_onSeleccionarAnclaTablero);
    on<EventoColocarNumeroEnObjetivo>(_onColocarNumeroEnObjetivo);
    on<EventoLimpiarSeleccionAncla>(_onLimpiarSeleccionAncla);
    on<EventoMovimientoRemotoRecibido>(_onMovimientoRemotoRecibido);
    on<EventoMovimientoInvalido>(_onMovimientoInvalido);
    on<EventoLimpiarMensajeAyuda>(_onLimpiarMensajeAyuda);
    on<EventoRendirse>(_onRendirse);
    on<EventoRivalConcedio>(_onRivalConcedio);
    on<EventoRivalDesconectado>(_onRivalDesconectado);
    on<EventoPuntuacionesActualizadas>(_onPuntuacionesActualizadas);
    on<EventoPartidaGanada>(_onPartidaGanada);
    on<EventoJugadorSalio>(_onJugadorSalio);

    _suscripcionMovimiento = _servicioSocket.movimientoRecibido.listen((datos) {
      final int? x = _comoEntero(datos['x'] ?? datos['columna']);
      final int? y = _comoEntero(datos['y'] ?? datos['fila']);
      final int? valor = _comoEntero(datos['valor']);

      if (x == null || y == null || valor == null) return;

      add(EventoMovimientoRemotoRecibido(x, y, valor));
    });

    _suscripcionRivalConcedio = _servicioSocket.rivalConcedio.listen(
      (_) => add(EventoRivalConcedio()),
    );

    _suscripcionRivalDesconectado = _servicioSocket.rivalDesconectado.listen(
      (_) => add(EventoRivalDesconectado()),
    );

    _suscripcionPuntuacionesActualizadas = _servicioSocket
        .puntuacionesActualizadas
        .listen((datos) {
          add(
            EventoPuntuacionesActualizadas(
              jugadores: _parsearJugadores(datos['jugadores']),
              puntosParaGanar: _comoEntero(datos['puntosParaGanar']),
            ),
          );
        });

    _suscripcionPartidaGanada = _servicioSocket.partidaGanada.listen((datos) {
      final dynamic ganador = datos['ganador'];
      final Map<String, dynamic>? ganadorMap = ganador is Map
          ? Map<String, dynamic>.from(ganador)
          : null;

      add(
        EventoPartidaGanada(
          ganadorSocketId: ganadorMap?['socketId']?.toString(),
          ganadorUsuario: ganadorMap?['usuario']?.toString(),
          jugadores: _parsearJugadores(datos['jugadores']),
          puntosParaGanar: _comoEntero(datos['puntosParaGanar']),
        ),
      );
    });

    _suscripcionJugadorConcedio = _servicioSocket.jugadorConcedio.listen((
      datos,
    ) {
      add(
        EventoJugadorSalio(
          usuario: _nombreJugador(datos),
          fueDesconexion: false,
          jugadores: _parsearJugadores(datos['jugadores']),
        ),
      );
    });

    _suscripcionJugadorDesconectado = _servicioSocket.jugadorDesconectado
        .listen((datos) {
          add(
            EventoJugadorSalio(
              usuario: _nombreJugador(datos),
              fueDesconexion: true,
              jugadores: _parsearJugadores(datos['jugadores']),
            ),
          );
        });

    if (_codigoSala != null) {
      _servicioSocket.iniciarPartida();
      _tuSocketId ??= _servicioSocket.idActual;
    }
  }

  void _onLanzarDados(EventoLanzarDados event, Emitter<JuegoTurnoEstado> emit) {
    final d1 = event.dado1Forzado ?? Dado.lanzar();
    final d2 = event.dado2Forzado ?? Dado.lanzar();

    emit(
      state.copyWith(
        dado1: d1,
        dado2: d2,
        limpiarAncla: true,
        limpiarMensajeAyuda: true,
      ),
    );
  }

  void _onSeleccionarDadoAncla(
    EventoSeleccionarDadoAncla event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state.dado1 != null && state.dado2 != null) {
      emit(
        state.copyWith(
          indiceDadoAncla: event.indiceDadoAncla,
          limpiarAncla: true,
          limpiarMensajeAyuda: true,
        ),
      );
    }
  }

  void _onSeleccionarAnclaTablero(
    EventoSeleccionarAnclaTablero event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state.dado1 == null || state.dado2 == null) {
      _mostrarMensajeAyuda(mensajeDadosNoLanzados(), emit);
      return;
    }

    if (event.celdaAncla.valor == null) {
      _mostrarMensajeAyuda(mensajeSeleccionaAncla(), emit);
      return;
    }

    int indiceAncla = state.indiceDadoAncla ?? 0;

    if (event.celdaAncla.valor == state.dado2!.valor &&
        event.celdaAncla.valor != state.dado1!.valor) {
      indiceAncla = 1;
    } else if (event.celdaAncla.valor == state.dado1!.valor &&
        event.celdaAncla.valor != state.dado2!.valor) {
      indiceAncla = 0;
    }

    final dAncla = indiceAncla == 0 ? state.dado1 : state.dado2;
    final dColocar = indiceAncla == 0 ? state.dado2 : state.dado1;

    if (dAncla == null ||
        dColocar == null ||
        event.celdaAncla.valor != dAncla.valor) {
      _mostrarMensajeAyuda(
        mensajeCasillaOcupada(
          event.celdaAncla.valor!,
          valorDado1: state.dado1?.valor,
          valorDado2: state.dado2?.valor,
        ),
        emit,
      );
      return;
    }

    final validas = obtenerCeldasObjetivoValidas(
      tablero: state.tablero,
      celdaAncla: event.celdaAncla,
      valorAColocar: dColocar.valor,
    );

    emit(
      state.copyWith(
        indiceDadoAncla: indiceAncla,
        celdaAncla: event.celdaAncla,
        celdasObjetivoValidas: validas,
        limpiarMensajeAyuda: validas.isNotEmpty,
      ),
    );

    if (validas.isEmpty) {
      _mostrarMensajeAyuda(mensajeAnclaSinOpciones(dColocar.valor), emit);
    }
  }

  void _onColocarNumeroEnObjetivo(
    EventoColocarNumeroEnObjetivo event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    final dColocar = state.dadoColocar;

    if (dColocar == null) {
      _mostrarMensajeAyuda(mensajeDadosNoLanzados(), emit);
      return;
    }

    if (!state.celdasObjetivoValidas.contains(event.celdaObjetivo)) {
      _mostrarMensajeAyuda(
        obtenerMensajeMovimientoInvalido(
          tablero: state.tablero,
          celda: event.celdaObjetivo,
          celdaAncla: state.celdaAncla,
          valorAColocar: dColocar.valor,
        ),
        emit,
      );
      return;
    }

    event.celdaObjetivo.asignarValor(dColocar.valor);

    final nuevoPuntaje = calcularPuntuacionTotal(state.tablero);
    final String? tuSocketId = _tuSocketId ?? state.tuSocketId;
    final List<JugadorPartida> jugadoresActualizados = state.jugadores
        .map(
          (jugador) => jugador.socketId == tuSocketId
              ? jugador.copyWith(puntuacion: nuevoPuntaje)
              : jugador,
        )
        .toList();

    emit(
      state.copyWith(
        tablero: state.tablero,
        puntuacionTotal: nuevoPuntaje,
        jugadores: jugadoresActualizados,
        limpiarAncla: true,
        limpiarDados: true,
        limpiarMensajeAyuda: true,
      ),
    );

    _emitirMovimiento(
      event.celdaObjetivo.columna,
      event.celdaObjetivo.fila,
      dColocar.valor,
    );
    _emitirPuntuacion(nuevoPuntaje);
  }

  void _onMovimientoRemotoRecibido(
    EventoMovimientoRemotoRecibido event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    final celda = state.tablero.obtenerCeldaEn(event.x, event.y);
    if (celda == null) return;

    celda.asignarValor(event.valor);

    emit(
      state.copyWith(
        tablero: state.tablero,
        puntuacionTotal: state.jugadores.isEmpty
            ? calcularPuntuacionTotal(state.tablero)
            : state.puntuacionTotal,
      ),
    );
  }

  void _onMovimientoInvalido(
    EventoMovimientoInvalido event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state.dado1 == null || state.dado2 == null) {
      _mostrarMensajeAyuda(mensajeDadosNoLanzados(), emit);
      return;
    }

    _mostrarMensajeAyuda(
      obtenerMensajeMovimientoInvalido(
        tablero: state.tablero,
        celda: event.celda,
        celdaAncla: state.celdaAncla,
        valorAColocar: state.dadoColocar?.valor,
      ),
      emit,
    );
  }

  void _onLimpiarMensajeAyuda(
    EventoLimpiarMensajeAyuda event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    _temporizadorMensajeAyuda?.cancel();
    _temporizadorMensajeAyuda = null;

    if (state.mensajeAyuda == null) return;

    emit(state.copyWith(limpiarMensajeAyuda: true));
  }

  void _mostrarMensajeAyuda(String mensaje, Emitter<JuegoTurnoEstado> emit) {
    _temporizadorMensajeAyuda?.cancel();
    emit(state.copyWith(mensajeAyuda: mensaje));
    _temporizadorMensajeAyuda = Timer(_duracionMensajeAyuda, () {
      if (!isClosed) {
        add(EventoLimpiarMensajeAyuda());
      }
    });
  }

  void _onLimpiarSeleccionAncla(
    EventoLimpiarSeleccionAncla event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    emit(state.copyWith(limpiarAncla: true));
  }

  void _onRendirse(EventoRendirse event, Emitter<JuegoTurnoEstado> emit) {
    if (_codigoSala == null || !_servicioSocket.conectado) return;

    try {
      _servicioSocket.concederPartida(_codigoSala);
    } catch (_) {
      return;
    }
  }

  void _onRivalConcedio(
    EventoRivalConcedio event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state is JuegoFinalizadoPorPuntos) return;

    _servicioSocket.finalizarPartida();
    emit(
      JuegoGanadoPorAbandono(
        tablero: state.tablero,
        dado1: state.dado1,
        dado2: state.dado2,
        indiceDadoAncla: state.indiceDadoAncla,
        celdaAncla: state.celdaAncla,
        celdasObjetivoValidas: state.celdasObjetivoValidas,
        puntuacionTotal: state.puntuacionTotal,
        mensajeAyuda: state.mensajeAyuda,
        jugadores: state.jugadores,
        puntosParaGanar: state.puntosParaGanar,
        tuSocketId: state.tuSocketId,
      ),
    );
  }

  void _onRivalDesconectado(
    EventoRivalDesconectado event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state is JuegoFinalizadoPorPuntos) return;

    _servicioSocket.finalizarPartida();
    emit(
      JuegoCanceladoDesconexion(
        tablero: state.tablero,
        dado1: state.dado1,
        dado2: state.dado2,
        indiceDadoAncla: state.indiceDadoAncla,
        celdaAncla: state.celdaAncla,
        celdasObjetivoValidas: state.celdasObjetivoValidas,
        puntuacionTotal: state.puntuacionTotal,
        mensajeAyuda: state.mensajeAyuda,
        jugadores: state.jugadores,
        puntosParaGanar: state.puntosParaGanar,
        tuSocketId: state.tuSocketId,
      ),
    );
  }

  void _onPuntuacionesActualizadas(
    EventoPuntuacionesActualizadas event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    final String? tuSocketId = _tuSocketId ?? state.tuSocketId;
    final JugadorPartida? jugadorLocal = _buscarJugador(
      event.jugadores,
      tuSocketId,
    );

    emit(
      state.copyWith(
        jugadores: event.jugadores,
        puntosParaGanar: event.puntosParaGanar ?? state.puntosParaGanar,
        tuSocketId: tuSocketId,
        puntuacionTotal: jugadorLocal?.puntuacion ?? state.puntuacionTotal,
      ),
    );
  }

  void _onPartidaGanada(
    EventoPartidaGanada event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    final String? tuSocketId = _tuSocketId ?? state.tuSocketId;
    final bool esGanadorLocal =
        event.ganadorSocketId != null && event.ganadorSocketId == tuSocketId;

    _servicioSocket.finalizarPartida();
    emit(
      JuegoFinalizadoPorPuntos(
        tablero: state.tablero,
        dado1: state.dado1,
        dado2: state.dado2,
        indiceDadoAncla: state.indiceDadoAncla,
        celdaAncla: state.celdaAncla,
        celdasObjetivoValidas: state.celdasObjetivoValidas,
        puntuacionTotal: state.puntuacionTotal,
        mensajeAyuda: state.mensajeAyuda,
        jugadores: event.jugadores.isEmpty ? state.jugadores : event.jugadores,
        puntosParaGanar: event.puntosParaGanar ?? state.puntosParaGanar,
        tuSocketId: tuSocketId,
        ganadorSocketId: event.ganadorSocketId,
        ganadorUsuario: event.ganadorUsuario,
        esGanadorLocal: esGanadorLocal,
      ),
    );
  }

  void _onJugadorSalio(
    EventoJugadorSalio event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state is JuegoFinalizadoPorPuntos) return;

    final List<JugadorPartida> jugadores = event.jugadores.isEmpty
        ? state.jugadores
        : event.jugadores;
    final String mensaje = event.fueDesconexion
        ? '${event.usuario} se desconectó. La partida continúa.'
        : '${event.usuario} se rindió. La partida continúa.';

    _temporizadorMensajeAyuda?.cancel();
    emit(state.copyWith(jugadores: jugadores, mensajeAyuda: mensaje));
    _temporizadorMensajeAyuda = Timer(_duracionMensajeAyuda, () {
      if (!isClosed) {
        add(EventoLimpiarMensajeAyuda());
      }
    });
  }

  void _emitirPuntuacion(int puntuacion) {
    if (_codigoSala == null || !_servicioSocket.conectado) return;

    try {
      _servicioSocket.actualizarPuntuacion(_codigoSala, puntuacion);
    } catch (_) {
      return;
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

  JugadorPartida? _buscarJugador(
    List<JugadorPartida> jugadores,
    String? socketId,
  ) {
    if (socketId == null) return null;

    for (final JugadorPartida jugador in jugadores) {
      if (jugador.socketId == socketId) return jugador;
    }

    return null;
  }

  String _nombreJugador(Map<String, dynamic> datos) {
    final dynamic jugador = datos['jugador'];
    if (jugador is Map && jugador['usuario'] != null) {
      return jugador['usuario'].toString();
    }
    return 'Un jugador';
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

  @override
  Future<void> close() async {
    _temporizadorMensajeAyuda?.cancel();
    _temporizadorMensajeAyuda = null;
    await _suscripcionMovimiento.cancel();
    await _suscripcionRivalConcedio.cancel();
    await _suscripcionRivalDesconectado.cancel();
    await _suscripcionPuntuacionesActualizadas.cancel();
    await _suscripcionPartidaGanada.cancel();
    await _suscripcionJugadorConcedio.cancel();
    await _suscripcionJugadorDesconectado.cancel();
    if (_codigoSala != null) {
      _servicioSocket.finalizarPartida();
    }
    return super.close();
  }
}
