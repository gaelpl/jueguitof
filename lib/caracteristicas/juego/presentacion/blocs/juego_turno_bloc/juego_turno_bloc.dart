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
  String? _tuIdSocket;
  final Set<String> _regionesReclamadas = {};
  Timer? _temporizadorMensajeAyuda;
  Timer? _temporizadorRonda;

  late final StreamSubscription<bool> _suscripcionRivalConcedio;
  late final StreamSubscription<bool> _suscripcionRivalDesconectado;
  late final StreamSubscription<Map<String, dynamic>> _suscripcionDadosLanzados;
  late final StreamSubscription<Map<String, dynamic>> _suscripcionRondaLista;
  late final StreamSubscription<Map<String, dynamic>>
  _suscripcionPuntuacionesActualizadas;
  late final StreamSubscription<Map<String, dynamic>> _suscripcionPartidaGanada;
  late final StreamSubscription<Map<String, dynamic>>
  _suscripcionJugadorConcedio;
  late final StreamSubscription<Map<String, dynamic>>
  _suscripcionJugadorDesconectado;
  late final StreamSubscription<Map<String, dynamic>> _suscripcionEstadoListos;

  JuegoTurnoBloc(
    Tablero tableroInicial, {
    ServicioSocket? servicioSocket,
    String? codigoSala,
    Duration? duracionMensajeAyuda,
    List<JugadorPartida> jugadores = const [],
    int? puntosParaGanar,
    String? tuIdSocket,
    String? anfitrion,
  }) : _servicioSocket = servicioSocket ?? ServicioSocket.instancia,
       _codigoSala = codigoSala,
       _tuIdSocket = tuIdSocket,
       _duracionMensajeAyuda =
           duracionMensajeAyuda ?? const Duration(seconds: 4),
       super(
         JuegoTurnoEstado(
           tablero: tableroInicial,
           puntuacionTotal: calcularPuntuacionTotal(tableroInicial),
           jugadores: jugadores,
           puntosParaGanar: puntosParaGanar,
           tuIdSocket: tuIdSocket,
           anfitrion: anfitrion,
         ),
       ) {
    on<EventoLanzarDados>(_onLanzarDados);
    on<EventoDadosLanzados>(_onDadosLanzados);
    on<EventoSaltarTurno>(_onSaltarTurno);
    on<EventoRondaLista>(_onRondaLista);
    on<EventoTickRonda>(_onTickRonda);
    on<EventoSeleccionarDadoAncla>(_onSeleccionarDadoAncla);
    on<EventoSeleccionarAnclaTablero>(_onSeleccionarAnclaTablero);
    on<EventoColocarNumeroEnObjetivo>(_onColocarNumeroEnObjetivo);
    on<EventoLimpiarSeleccionAncla>(_onLimpiarSeleccionAncla);
    on<EventoMovimientoInvalido>(_onMovimientoInvalido);
    on<EventoLimpiarMensajeAyuda>(_onLimpiarMensajeAyuda);
    on<EventoRendirse>(_onRendirse);
    on<EventoRivalConcedio>(_onRivalConcedio);
    on<EventoRivalDesconectado>(_onRivalDesconectado);
    on<EventoPuntuacionesActualizadas>(_onPuntuacionesActualizadas);
    on<EventoPartidaGanada>(_onPartidaGanada);
    on<EventoJugadorSalio>(_onJugadorSalio);
    on<EventoEstadoListos>(_onEstadoListos);

    _suscripcionRivalConcedio = _servicioSocket.rivalConcedio.listen(
      (_) => add(EventoRivalConcedio()),
    );

    _suscripcionRivalDesconectado = _servicioSocket.rivalDesconectado.listen(
      (_) => add(EventoRivalDesconectado()),
    );

    _suscripcionDadosLanzados = _servicioSocket.dadosLanzados.listen((datos) {
      final int? dado1 = _comoEntero(datos['dado1']);
      final int? dado2 = _comoEntero(datos['dado2']);

      if (dado1 == null || dado2 == null) return;

      add(
        EventoDadosLanzados(
          dado1: Dado(dado1),
          dado2: Dado(dado2),
          anfitrion: datos['anfitrion']?.toString(),
          numeroRonda: _comoEntero(datos['numeroRonda']) ?? 1,
          segundosRestantes:
              _comoEntero(datos['segundosRestantes']) ??
              _comoEntero(datos['duracionRondaSegundos']) ??
              300,
          duracionRondaSegundos:
              _comoEntero(datos['duracionRondaSegundos']) ?? 300,
        ),
      );
    });

    _suscripcionRondaLista = _servicioSocket.rondaLista.listen((datos) {
      add(
        EventoRondaLista(
          anfitrion: datos['anfitrion']?.toString(),
          numeroRonda: _comoEntero(datos['numeroRonda']) ?? 0,
          motivo: datos['motivo']?.toString() ?? 'completada',
        ),
      );
    });

    _suscripcionPuntuacionesActualizadas = _servicioSocket
        .puntuacionesActualizadas
        .listen((datos) {
          add(
            EventoPuntuacionesActualizadas(
              jugadores: _parsearJugadores(datos['jugadores']),
              puntosParaGanar: _comoEntero(datos['puntosParaGanar']),
              historialRegiones: _parsearHistorial(datos['historialRegiones']),
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
          idSocketGanador: ganadorMap?['socketId']?.toString(),
          ganadorUsuario: ganadorMap?['usuario']?.toString(),
          jugadores: _parsearJugadores(datos['jugadores']),
          puntosParaGanar: _comoEntero(datos['puntosParaGanar']),
          historialRegiones: _parsearHistorial(datos['historialRegiones']),
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
          anfitrion: datos['anfitrion']?.toString(),
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
              anfitrion: datos['anfitrion']?.toString(),
            ),
          );
        });

    _suscripcionEstadoListos = _servicioSocket.estadoListos.listen((datos) {
      add(
        EventoEstadoListos(
          todosListos: datos['todosListos'] == true,
          listos: _comoEntero(datos['listos']) ?? 0,
          total: _comoEntero(datos['total']) ?? 0,
        ),
      );
    });

    if (_codigoSala != null) {
      _servicioSocket.iniciarPartida();
      _tuIdSocket ??= _servicioSocket.idActual;
      try {
        _servicioSocket.consultarEstadoListos(_codigoSala);
      } catch (_) {}
    }
  }

  void _onLanzarDados(EventoLanzarDados event, Emitter<JuegoTurnoEstado> emit) {
    if (state.esMultijugador) {
      if (!state.esAnfitrion) {
        _mostrarMensajeAyuda('Solo el anfitrión puede lanzar los dados.', emit);
        return;
      }

      if (!state.puedeLanzarDados) return;

      if (_codigoSala == null || !_servicioSocket.conectado) {
        _mostrarMensajeAyuda(
          'No hay conexión con el servidor de partidas.',
          emit,
        );
        return;
      }

      emit(state.copyWith(esperandoDados: true, limpiarMensajeAyuda: true));

      try {
        _servicioSocket.lanzarDados(_codigoSala);
      } catch (_) {
        emit(state.copyWith(esperandoDados: false));
        _mostrarMensajeAyuda(
          'No se pudo solicitar el lanzamiento de dados.',
          emit,
        );
      }
      return;
    }

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

  void _onDadosLanzados(
    EventoDadosLanzados event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    _temporizadorRonda?.cancel();
    _temporizadorRonda = null;

    emit(
      state.copyWith(
        dado1: event.dado1,
        dado2: event.dado2,
        anfitrion: event.anfitrion ?? state.anfitrion,
        numeroRonda: event.numeroRonda,
        rondaActiva: true,
        accionTurnoCompletada: false,
        esperandoDados: false,
        segundosRestantesRonda: event.segundosRestantes,
        duracionRondaSegundos: event.duracionRondaSegundos,
        limpiarAncla: true,
        limpiarMensajeAyuda: true,
      ),
    );

    _iniciarTemporizadorRonda();
  }

  void _onSaltarTurno(EventoSaltarTurno event, Emitter<JuegoTurnoEstado> emit) {
    if (!state.puedeSaltarTurno) return;

    emit(
      state.copyWith(
        accionTurnoCompletada: true,
        limpiarAncla: true,
        limpiarMensajeAyuda: true,
      ),
    );

    _emitirAccionTurno();
  }

  void _onRondaLista(EventoRondaLista event, Emitter<JuegoTurnoEstado> emit) {
    _temporizadorRonda?.cancel();
    _temporizadorRonda = null;

    emit(
      state.copyWith(
        anfitrion: event.anfitrion ?? state.anfitrion,
        numeroRonda: event.numeroRonda,
        rondaActiva: false,
        accionTurnoCompletada: false,
        esperandoDados: false,
        segundosRestantesRonda: 0,
        limpiarDados: true,
        limpiarAncla: true,
        limpiarMensajeAyuda: true,
      ),
    );

    final String mensaje = event.motivo == 'tiempo'
        ? 'El tiempo de la ronda terminó. Se avanzó automáticamente.'
        : 'Ronda completada. El anfitrión puede lanzar los dados.';
    _mostrarMensajeAyuda(mensaje, emit);
  }

  void _onTickRonda(EventoTickRonda event, Emitter<JuegoTurnoEstado> emit) {
    if (!state.rondaActiva || state.segundosRestantesRonda <= 0) return;

    emit(
      state.copyWith(segundosRestantesRonda: state.segundosRestantesRonda - 1),
    );
  }

  void _iniciarTemporizadorRonda() {
    _temporizadorRonda?.cancel();
    _temporizadorRonda = null;

    if (!state.rondaActiva) return;

    _temporizadorRonda = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }

      final int restantes = state.segundosRestantesRonda;
      add(EventoTickRonda());

      if (restantes <= 1) {
        timer.cancel();
        _temporizadorRonda = null;
      }
    });
  }

  bool _bloquearSiNoPuedeActuar(Emitter<JuegoTurnoEstado> emit) {
    if (!state.esMultijugador || state.puedeActuar) return false;

    _mostrarMensajeAyuda(
      state.accionTurnoCompletada
          ? 'Ya completaste tu acción. Espera a los demás jugadores.'
          : 'Espera el lanzamiento de dados del anfitrión.',
      emit,
    );
    return true;
  }

  void _onSeleccionarDadoAncla(
    EventoSeleccionarDadoAncla event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (_bloquearSiNoPuedeActuar(emit)) return;

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
    if (_bloquearSiNoPuedeActuar(emit)) return;

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
    if (_bloquearSiNoPuedeActuar(emit)) return;

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

    if (state.esMultijugador) {
      emit(
        state.copyWith(
          tablero: state.tablero,
          accionTurnoCompletada: true,
          limpiarAncla: true,
          limpiarMensajeAyuda: true,
        ),
      );
      _reclamarRegionesCompletadas();
      _emitirAccionTurno();
      return;
    }

    final nuevoPuntaje = calcularPuntuacionTotal(state.tablero);

    emit(
      state.copyWith(
        tablero: state.tablero,
        puntuacionTotal: nuevoPuntaje,
        limpiarAncla: true,
        limpiarDados: true,
        limpiarMensajeAyuda: true,
      ),
    );
  }

  void _onMovimientoInvalido(
    EventoMovimientoInvalido event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (_bloquearSiNoPuedeActuar(emit)) return;

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
    if (state is JuegoRendicionLocal ||
        state is JuegoGanadoPorAbandono ||
        state is JuegoCanceladoDesconexion ||
        state is JuegoFinalizadoPorPuntos) {
      return;
    }

    _temporizadorRonda?.cancel();
    _temporizadorRonda = null;
    emit(
      JuegoRendicionLocal(
        tablero: state.tablero,
        dado1: state.dado1,
        dado2: state.dado2,
        indiceDadoAncla: state.indiceDadoAncla,
        celdaAncla: state.celdaAncla,
        celdasObjetivoValidas: state.celdasObjetivoValidas,
        puntuacionTotal: state.puntuacionTotal,
        mensajeAyuda: state.mensajeAyuda,
        jugadores: state.jugadores,
        historialRegiones: state.historialRegiones,
        puntosParaGanar: state.puntosParaGanar,
        tuIdSocket: state.tuIdSocket,
        anfitrion: state.anfitrion,
        numeroRonda: state.numeroRonda,
        rondaActiva: state.rondaActiva,
        accionTurnoCompletada: state.accionTurnoCompletada,
        esperandoDados: state.esperandoDados,
        segundosRestantesRonda: state.segundosRestantesRonda,
        duracionRondaSegundos: state.duracionRondaSegundos,
      ),
    );

    if (_codigoSala != null && _servicioSocket.conectado) {
      try {
        _servicioSocket.concederPartida(_codigoSala);
      } catch (_) {}
    }

    _servicioSocket.finalizarPartida();
  }

  void _onRivalConcedio(
    EventoRivalConcedio event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state is JuegoFinalizadoPorPuntos) return;

    _temporizadorRonda?.cancel();
    _temporizadorRonda = null;
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
        historialRegiones: state.historialRegiones,
        puntosParaGanar: state.puntosParaGanar,
        tuIdSocket: state.tuIdSocket,
        anfitrion: state.anfitrion,
        numeroRonda: state.numeroRonda,
        rondaActiva: state.rondaActiva,
        accionTurnoCompletada: state.accionTurnoCompletada,
        esperandoDados: state.esperandoDados,
        segundosRestantesRonda: state.segundosRestantesRonda,
        duracionRondaSegundos: state.duracionRondaSegundos,
      ),
    );
  }

  void _onRivalDesconectado(
    EventoRivalDesconectado event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state is JuegoFinalizadoPorPuntos) return;

    _temporizadorRonda?.cancel();
    _temporizadorRonda = null;
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
        historialRegiones: state.historialRegiones,
        puntosParaGanar: state.puntosParaGanar,
        tuIdSocket: state.tuIdSocket,
        anfitrion: state.anfitrion,
        numeroRonda: state.numeroRonda,
        rondaActiva: state.rondaActiva,
        accionTurnoCompletada: state.accionTurnoCompletada,
        esperandoDados: state.esperandoDados,
        segundosRestantesRonda: state.segundosRestantesRonda,
        duracionRondaSegundos: state.duracionRondaSegundos,
      ),
    );
  }

  void _onPuntuacionesActualizadas(
    EventoPuntuacionesActualizadas event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    final String? tuIdSocket = _tuIdSocket ?? state.tuIdSocket;
    final JugadorPartida? jugadorLocal = _buscarJugador(
      event.jugadores,
      tuIdSocket,
    );

    emit(
      state.copyWith(
        jugadores: event.jugadores,
        historialRegiones: event.historialRegiones,
        puntosParaGanar: event.puntosParaGanar ?? state.puntosParaGanar,
        tuIdSocket: tuIdSocket,
        puntuacionTotal: jugadorLocal?.puntuacion ?? state.puntuacionTotal,
      ),
    );
  }

  void _onPartidaGanada(
    EventoPartidaGanada event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    final String? tuIdSocket = _tuIdSocket ?? state.tuIdSocket;
    final bool esGanadorLocal =
        event.idSocketGanador != null && event.idSocketGanador == tuIdSocket;
    final List<JugadorPartida> jugadores = event.jugadores.isEmpty
        ? state.jugadores
        : event.jugadores;
    final JugadorPartida? jugadorLocal = _buscarJugador(jugadores, tuIdSocket);

    _temporizadorRonda?.cancel();
    _temporizadorRonda = null;
    _servicioSocket.finalizarPartida();
    emit(
      JuegoFinalizadoPorPuntos(
        tablero: state.tablero,
        dado1: state.dado1,
        dado2: state.dado2,
        indiceDadoAncla: state.indiceDadoAncla,
        celdaAncla: state.celdaAncla,
        celdasObjetivoValidas: state.celdasObjetivoValidas,
        puntuacionTotal: jugadorLocal?.puntuacion ?? state.puntuacionTotal,
        mensajeAyuda: state.mensajeAyuda,
        jugadores: jugadores,
        historialRegiones: event.historialRegiones.isEmpty
            ? state.historialRegiones
            : event.historialRegiones,
        puntosParaGanar: event.puntosParaGanar ?? state.puntosParaGanar,
        tuIdSocket: tuIdSocket,
        anfitrion: state.anfitrion,
        numeroRonda: state.numeroRonda,
        rondaActiva: state.rondaActiva,
        accionTurnoCompletada: state.accionTurnoCompletada,
        esperandoDados: state.esperandoDados,
        segundosRestantesRonda: state.segundosRestantesRonda,
        duracionRondaSegundos: state.duracionRondaSegundos,
        idSocketGanador: event.idSocketGanador,
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
    emit(
      state.copyWith(
        jugadores: jugadores,
        anfitrion: event.anfitrion ?? state.anfitrion,
        mensajeAyuda: mensaje,
      ),
    );
    _temporizadorMensajeAyuda = Timer(_duracionMensajeAyuda, () {
      if (!isClosed) {
        add(EventoLimpiarMensajeAyuda());
      }
    });
  }

  void _onEstadoListos(
    EventoEstadoListos event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    emit(
      state.copyWith(
        todosListos: event.todosListos,
        jugadoresListos: event.listos,
        totalJugadores: event.total,
      ),
    );
  }

  void _emitirAccionTurno() {
    if (_codigoSala == null || !_servicioSocket.conectado) return;

    try {
      _servicioSocket.completarAccionTurno(_codigoSala);
    } catch (_) {
      return;
    }
  }

  void _reclamarRegionesCompletadas() {
    if (_codigoSala == null || !_servicioSocket.conectado) return;

    for (final Region region in Region.values) {
      if (!estaRegionCompletada(state.tablero, region)) continue;
      if (!_regionesReclamadas.add(region.name)) continue;

      try {
        _servicioSocket.reclamarRegion(_codigoSala, region.name);
      } catch (_) {
        _regionesReclamadas.remove(region.name);
      }
    }
  }

  List<RegistroRegion> _parsearHistorial(dynamic valor) {
    if (valor is! List) return const [];

    final List<RegistroRegion> historial = [];
    for (final dynamic registro in valor.whereType<Map>()) {
      final Region? region = regionDesdeNombre(
        registro['region']?.toString() ?? '',
      );
      if (region == null) continue;

      historial.add(
        RegistroRegion(
          region: region,
          usuario: registro['usuario']?.toString() ?? '',
          socketId: registro['socketId']?.toString(),
          puesto: _comoEntero(registro['puesto']) ?? 0,
          puntos: _comoEntero(registro['puntos']) ?? 0,
          numeroRonda: _comoEntero(registro['numeroRonda']) ?? 0,
        ),
      );
    }

    return historial;
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
    String? idSocket,
  ) {
    if (idSocket == null) return null;

    for (final JugadorPartida jugador in jugadores) {
      if (jugador.idSocket == idSocket) return jugador;
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
    _temporizadorRonda?.cancel();
    _temporizadorRonda = null;
    await _suscripcionRivalConcedio.cancel();
    await _suscripcionRivalDesconectado.cancel();
    await _suscripcionDadosLanzados.cancel();
    await _suscripcionRondaLista.cancel();
    await _suscripcionPuntuacionesActualizadas.cancel();
    await _suscripcionPartidaGanada.cancel();
    await _suscripcionJugadorConcedio.cancel();
    await _suscripcionJugadorDesconectado.cancel();
    await _suscripcionEstadoListos.cancel();
    if (_codigoSala != null) {
      _servicioSocket.finalizarPartida();
    }
    return super.close();
  }
}
