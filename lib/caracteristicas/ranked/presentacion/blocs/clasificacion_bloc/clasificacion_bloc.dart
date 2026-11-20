import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../juego/datos/servicios/servicio_socket.dart';
import '../../../datos/servicios/servicio_ranked.dart';
import 'clasificacion_event.dart';
import 'clasificacion_state.dart';

export 'clasificacion_event.dart';
export 'clasificacion_state.dart';

class ClasificacionBloc extends Bloc<ClasificacionEvento, ClasificacionEstado> {
  final ServicioRanked _servicioRanked;
  final ServicioSocket _servicioSocket;
  late final StreamSubscription<void> _suscripcionActualizacion;

  ClasificacionBloc({
    ServicioRanked? servicioRanked,
    ServicioSocket? servicioSocket,
  }) : _servicioRanked = servicioRanked ?? ServicioRanked(),
       _servicioSocket = servicioSocket ?? ServicioSocket.instancia,
       super(const ClasificacionEstado()) {
    on<CargarClasificacion>(_alCargar);

    _suscripcionActualizacion = _servicioSocket.clasificacionActualizada.listen(
      (_) {
        if (!isClosed) add(CargarClasificacion(limite: state.limite));
      },
    );
  }

  Future<void> _alCargar(
    CargarClasificacion evento,
    Emitter<ClasificacionEstado> emitir,
  ) async {
    final int limite = evento.limite ?? state.limite;
    emitir(state.copyWith(cargando: true, limite: limite, limpiarError: true));

    try {
      final respuesta = await _servicioRanked.obtenerClasificacion(
        limite: limite,
      );
      emitir(
        state.copyWith(
          cargando: false,
          entradas: respuesta.entradas,
          usuarioActual: respuesta.usuarioActual,
          limpiarUsuarioActual: respuesta.usuarioActual == null,
          total: respuesta.total,
        ),
      );
    } catch (error) {
      emitir(
        state.copyWith(
          cargando: false,
          error: error
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('StateError: ', ''),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _suscripcionActualizacion.cancel();
    return super.close();
  }
}
