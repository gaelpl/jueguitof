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
    }
  }

  void _onLimpiarSeleccionAncla(
    EventoLimpiarSeleccionAncla event,
    Emitter<JuegoTurnoEstado> emit,
  ) {
    emit(state.copyWith(limpiarAncla: true));
  }
}
