import 'package:flutter_bloc/flutter_bloc.dart';
import '../juego_logica.dart';
import 'inicio_juego_event.dart';
import 'inicio_juego_state.dart';

export 'inicio_juego_event.dart';
export 'inicio_juego_state.dart';

class InicioJuegoBloc extends Bloc<InicioJuegoEvento, InicioJuegoEstado> {
  InicioJuegoBloc(Tablero tableroInicial)
      : super(InicioJuegoEstado(tablero: tableroInicial)) {

    on<EventoSeleccionarNumero>((event, emit) {
      emit(state.copyWith(numeroSeleccionado: event.numero));
    });

    on<EventoColocarNumeroEnEstrella>((event, emit) {
      final valorAColocar = state.numeroSeleccionado;
      final tablero = state.tablero;

      for (var celda in tablero.obtenerCeldasEstrella()) {
        if (celda.valor == valorAColocar) {
          celda.asignarValor(null);
        }
      }

      final celdaObjetivo = tablero.obtenerCeldaEn(event.columna, event.fila);
      if (celdaObjetivo != null && celdaObjetivo.esEstrella) {
        celdaObjetivo.asignarValor(valorAColocar);
      }

      emit(state.copyWith(tablero: tablero));
    });
  }
}