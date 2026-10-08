import 'package:flutter_bloc/flutter_bloc.dart';
import '../juego_logica.dart';
import 'juego_turno_event.dart';
import 'juego_turno_state.dart';

export 'juego_turno_event.dart';
export 'juego_turno_state.dart';

class JuegoTurnoBloc extends Bloc<JuegoTurnoEvento, JuegoTurnoEstado> {
  JuegoTurnoBloc(Tablero tableroInicial)
      : super(JuegoTurnoEstado(
          tablero: tableroInicial,
          puntuacionTotal: calcularPuntuacionTotal(tableroInicial),
        )) {
    on<EventoLanzarDado>(_onLanzarDado);
    on<EventoSeleccionarAncla>(_onSeleccionarAncla);
    on<EventoColocarNumeroEnObjetivo>(_onColocarNumeroEnObjetivo);
    on<EventoLimpiarSeleccionAncla>(_onLimpiarSeleccionAncla);
  }

  void _onLanzarDado(EventoLanzarDado event, Emitter<JuegoTurnoEstado> emit) {
    final nuevoDado = event.dadoForzado ?? Dado.lanzar();
    emit(state.copyWith(
      dadoActual: nuevoDado,
      limpiarAncla: true,
    ));
  }

  void _onSeleccionarAncla(
      EventoSeleccionarAncla event, Emitter<JuegoTurnoEstado> emit) {
    if (event.celdaAncla.valor != null && state.dadoActual != null) {
      final validas = obtenerCeldasObjetivoValidas(
        tablero: state.tablero,
        celdaAncla: event.celdaAncla,
        valorAColocar: state.dadoActual!.valor,
      );

      emit(state.copyWith(
        celdaAncla: event.celdaAncla,
        celdasObjetivoValidas: validas,
      ));
    }
  }

  void _onColocarNumeroEnObjetivo(
      EventoColocarNumeroEnObjetivo event, Emitter<JuegoTurnoEstado> emit) {
    if (state.dadoActual != null &&
        state.celdasObjetivoValidas.contains(event.celdaObjetivo)) {
      event.celdaObjetivo.asignarValor(state.dadoActual!.valor);

      final nuevoPuntaje = calcularPuntuacionTotal(state.tablero);

      emit(state.copyWith(
        tablero: state.tablero,
        puntuacionTotal: nuevoPuntaje,
        limpiarAncla: true,
      ));
    }
  }

  void _onLimpiarSeleccionAncla(
      EventoLimpiarSeleccionAncla event, Emitter<JuegoTurnoEstado> emit) {
    emit(state.copyWith(limpiarAncla: true));
  }
}