import 'jugador_clasificacion.dart';

class ClasificacionRespuesta {
  final List<JugadorClasificacion> entradas;
  final JugadorClasificacion? usuarioActual;
  final int total;

  const ClasificacionRespuesta({
    required this.entradas,
    this.usuarioActual,
    this.total = 0,
  });

  factory ClasificacionRespuesta.desdeJson(Map<String, dynamic> datos) {
    final dynamic entradas = datos['entradas'];
    final List<JugadorClasificacion> lista = entradas is List
        ? entradas
              .whereType<Map>()
              .map(
                (entrada) => JugadorClasificacion.desdeJson(
                  Map<String, dynamic>.from(entrada),
                ),
              )
              .toList()
        : const [];

    final dynamic actual = datos['usuarioActual'];
    final JugadorClasificacion? usuarioActual = actual is Map
        ? JugadorClasificacion.desdeJson(Map<String, dynamic>.from(actual))
        : null;

    final int total = (datos['total'] is num)
        ? (datos['total'] as num).toInt()
        : (int.tryParse(datos['total']?.toString() ?? '') ?? lista.length);

    return ClasificacionRespuesta(
      entradas: lista,
      usuarioActual: usuarioActual,
      total: total,
    );
  }
}

class PerfilRanked {
  final int idUsuario;
  final String usuario;
  final int rp;
  final String liga;
  final String division;
  final double progreso;
  final int partidas;
  final int victorias;
  final int derrotas;

  const PerfilRanked({
    required this.idUsuario,
    required this.usuario,
    required this.rp,
    required this.liga,
    required this.division,
    required this.progreso,
    required this.partidas,
    required this.victorias,
    required this.derrotas,
  });

  factory PerfilRanked.desdeJson(Map<String, dynamic> datos) {
    return PerfilRanked(
      idUsuario: _comoEntero(datos['idUsuario']) ?? 0,
      usuario: datos['usuario']?.toString() ?? 'Jugador',
      rp: _comoEntero(datos['rp']) ?? 0,
      liga: datos['liga']?.toString() ?? 'Bronce',
      division: datos['division']?.toString() ?? 'IV',
      progreso: (datos['progreso'] is num)
          ? (datos['progreso'] as num).toDouble()
          : double.tryParse(datos['progreso']?.toString() ?? '') ?? 0.0,
      partidas: _comoEntero(datos['partidas']) ?? 0,
      victorias: _comoEntero(datos['victorias']) ?? 0,
      derrotas: _comoEntero(datos['derrotas']) ?? 0,
    );
  }

  static int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }
}
