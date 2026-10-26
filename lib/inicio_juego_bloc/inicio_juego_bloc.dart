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

      if (valorAColocar == null) return;

      final celdaObjetivo = tablero.obtenerCeldaEn(event.columna, event.fila);
      if (celdaObjetivo == null || !celdaObjetivo.esEstrella) return;

      // 1. Obtener la zona de la celda estrella
      final zona = tablero.obtenerZona(celdaObjetivo.region);

      // 2. Validar que la regla del tipo de zona permita este número
      if (zona != null) {
        final celdasDeZona = tablero.celdas.where(
          (c) => c.region == celdaObjetivo.region && c != celdaObjetivo,
        );
        final valoresActuales = celdasDeZona
            .map((c) => c.valor)
            .whereType<int>()
            .toList();

        // Si el número no cumple la regla de la zona se cancela
        if (!zona.tipo.esPosibleAgregar(valoresActuales, valorAColocar)) {
          return;
        }
      }

      // 3. Si el valor ya estaba en otra estrella, lo quitamos de ahí primero
      for (var celda in tablero.obtenerCeldasEstrella()) {
        if (celda.valor == valorAColocar) {
          celda.asignarValor(null);
        }
      }

      // 4. Asignamos el valor en la estrella seleccionada
      celdaObjetivo.asignarValor(valorAColocar);

      final listos = tablero.estanEstrellasCompletas();
      emit(state.copyWith(tablero: tablero, estanListasEstrellas: listos));
    });

    on<EventoConfirmarInicio>((event, emit) {
      if (state.estanListasEstrellas) {
        emit(state.copyWith(juegoIniciado: true));
      }
    });
  }
}