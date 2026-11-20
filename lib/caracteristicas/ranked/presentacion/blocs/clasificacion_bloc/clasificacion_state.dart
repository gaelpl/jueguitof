import '../../../dominio/entidades/jugador_clasificacion.dart';

class ClasificacionEstado {
  final List<JugadorClasificacion> entradas;
  final JugadorClasificacion? usuarioActual;
  final int total;
  final int limite;
  final bool cargando;
  final String? error;

  const ClasificacionEstado({
    this.entradas = const [],
    this.usuarioActual,
    this.total = 0,
    this.limite = 10,
    this.cargando = false,
    this.error,
  });

  bool get tieneEntradas => entradas.isNotEmpty;

  ClasificacionEstado copyWith({
    List<JugadorClasificacion>? entradas,
    JugadorClasificacion? usuarioActual,
    bool limpiarUsuarioActual = false,
    int? total,
    int? limite,
    bool? cargando,
    String? error,
    bool limpiarError = false,
  }) {
    return ClasificacionEstado(
      entradas: entradas ?? this.entradas,
      usuarioActual: limpiarUsuarioActual
          ? null
          : (usuarioActual ?? this.usuarioActual),
      total: total ?? this.total,
      limite: limite ?? this.limite,
      cargando: cargando ?? this.cargando,
      error: limpiarError ? null : (error ?? this.error),
    );
  }
}
