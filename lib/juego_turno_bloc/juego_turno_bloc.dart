import 'package:flutter_bloc/flutter_bloc.dart';

import '../juego_logica.dart';
import 'juego_turno_event.dart';
import 'juego_turno_state.dart';

export 'juego_turno_event.dart';
export 'juego_turno_state.dart';

class JuegoTurnoBloc extends Bloc<JuegoTurnoEvento, JuegoTurnoEstado> {
  JuegoTurnoBloc(Tablero tableroInicial)
    : super(
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
          limpiarAncla: true,
        ),
      );
    }
  }

  void _onSeleccionarAnclaTablero(
    EventoSeleccionarAnclaTablero event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    final dAncla = state.dadoAncla;
    final dColocar = state.dadoColocar;

    // Solo permite seleccionar casillas cuyo valor coincida con el dado elegido como ancla
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
        ),
      );
    }
  }

  void _onLimpiarSeleccionAncla(
    EventoLimpiarSeleccionAncla event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    emit(state.copyWith(limpiarAncla: true));
  }
}
