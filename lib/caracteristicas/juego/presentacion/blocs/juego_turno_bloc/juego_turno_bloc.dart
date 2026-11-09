import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../datos/servicios/servicio_socket.dart';
import '../../../dominio/logica/juego_logica.dart';
import 'juego_turno_event.dart';
import 'juego_turno_state.dart';

export 'juego_turno_event.dart';
export 'juego_turno_state.dart';

class JuegoTurnoBloc extends Bloc<JuegoTurnoEvento, JuegoTurnoEstado> {
  final ServicioSocket _servicioSocket;
  final String? _codigoSala;

  late final StreamSubscription<Map<String, dynamic>> _suscripcionMovimiento;
  late final StreamSubscription<bool> _suscripcionRivalConcedio;
  late final StreamSubscription<bool> _suscripcionRivalDesconectado;

  JuegoTurnoBloc(
    Tablero tableroInicial, {
    ServicioSocket? servicioSocket,
    String? codigoSala,
  }) : _servicioSocket = servicioSocket ?? ServicioSocket.instancia,
       _codigoSala = codigoSala,
       super(
         JuegoTurnoEstado(
           tablero: tableroInicial,
           puntuacionTotal: calcularPuntuacionTotal(tableroInicial),
         ),
       ) {
    on<EventoLanzarDados>(_onLanzarDados);
    on<EventoSeleccionarDadoAncla>(_onSeleccionarDadoAncla);
    on<EventoSeleccionarAnclaTablero>(_onSeleccionarAnclaTablero);
    on<EventoColocarNumeroEnObjetivo>(_onColocarNumeroEnObjetivo);
    on<EventoLimpiarSeleccionAncla>(_onLimpiarSeleccionAncla);
    on<EventoMovimientoRemotoRecibido>(_onMovimientoRemotoRecibido);
    on<EventoRendirse>(_onRendirse);
    on<EventoRivalConcedio>(_onRivalConcedio);
    on<EventoRivalDesconectado>(_onRivalDesconectado);

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

    if (_codigoSala != null) {
      _servicioSocket.iniciarPartida();
    }
  }

  void _onLanzarDados(EventoLanzarDados event, Emitter<JuegoTurnoEstado> emit) {
    final d1 = event.dado1Forzado ?? Dado.lanzar();
    final d2 = event.dado2Forzado ?? Dado.lanzar();

    emit(state.copyWith(dado1: d1, dado2: d2, limpiarAncla: true));
  }

  void _onSeleccionarDadoAncla(
    EventoSeleccionarDadoAncla event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    if (state.dado1 != null && state.dado2 != null) {
      emit(
        state.copyWith(
          indiceDadoAncla: event.indiceDadoAncla,
          limpiarAncla: true, // Limpia el ancla anterior al cambiar de dado
        ),
      );
    }
  }

  void _onSeleccionarAnclaTablero(
    EventoSeleccionarAnclaTablero event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    // Si aún no se ha elegido explícitamente el dado de ancla, elegimos por defecto el dado 1
    int indiceAncla = state.indiceDadoAncla ?? 0;

    // Si la celda tocada coincide con el valor del dado 2 pero teníamos el dado 1,
    // auto-seleccionamos el dado que coincide con la celda tocada
    if (state.dado1 != null && state.dado2 != null) {
      if (event.celdaAncla.valor == state.dado2!.valor &&
          event.celdaAncla.valor != state.dado1!.valor) {
        indiceAncla = 1;
      } else if (event.celdaAncla.valor == state.dado1!.valor &&
          event.celdaAncla.valor != state.dado2!.valor) {
        indiceAncla = 0;
      }
    }

    final dAncla = indiceAncla == 0 ? state.dado1 : state.dado2;
    final dColocar = indiceAncla == 0 ? state.dado2 : state.dado1;

    if (dAncla != null &&
        dColocar != null &&
        event.celdaAncla.valor == dAncla.valor) {
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
        ),
      );
    }
  }

  void _onColocarNumeroEnObjetivo(
    EventoColocarNumeroEnObjetivo event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    final dColocar = state.dadoColocar;

    if (dColocar != null &&
        state.celdasObjetivoValidas.contains(event.celdaObjetivo)) {
      event.celdaObjetivo.asignarValor(dColocar.valor);

      final nuevoPuntaje = calcularPuntuacionTotal(state.tablero);

      emit(
        state.copyWith(
          tablero: state.tablero,
          puntuacionTotal: nuevoPuntaje,
          limpiarAncla: true,
          limpiarDados: true,
        ),
      );

      _emitirMovimiento(
        event.celdaObjetivo.columna,
        event.celdaObjetivo.fila,
        dColocar.valor,
      );
    }
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
        puntuacionTotal: calcularPuntuacionTotal(state.tablero),
      ),
    );
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
      ),
    );
  }

  void _onRivalDesconectado(
    EventoRivalDesconectado event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
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
      ),
    );
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
    await _suscripcionMovimiento.cancel();
    await _suscripcionRivalConcedio.cancel();
    await _suscripcionRivalDesconectado.cancel();
    if (_codigoSala != null) {
      _servicioSocket.finalizarPartida();
    }
    return super.close();
  }
}
