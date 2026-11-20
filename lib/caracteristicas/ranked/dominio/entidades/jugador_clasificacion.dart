class JugadorClasificacion {
  final int posicion;
  final int idUsuario;
  final String usuario;
  final String liga;
  final String division;
  final int rp;
  final int victorias;
  final int partidas;

  const JugadorClasificacion({
    required this.posicion,
    required this.idUsuario,
    required this.usuario,
    required this.liga,
    required this.division,
    required this.rp,
    required this.victorias,
    required this.partidas,
  });

  factory JugadorClasificacion.desdeJson(Map<String, dynamic> datos) {
    return JugadorClasificacion(
      posicion: _comoEntero(datos['posicion']) ?? 0,
      idUsuario: _comoEntero(datos['idUsuario']) ?? 0,
      usuario: datos['usuario']?.toString() ?? 'Jugador',
      liga: datos['liga']?.toString() ?? 'Bronce',
      division: datos['division']?.toString() ?? 'IV',
      rp: _comoEntero(datos['rp']) ?? 0,
      victorias: _comoEntero(datos['victorias']) ?? 0,
      partidas: _comoEntero(datos['partidas']) ?? 0,
    );
  }

  int get derrotas {
    final int calculadas = partidas - victorias;
    return calculadas > 0 ? calculadas : 0;
  }

  String get inicial {
    final String nombre = usuario.trim();
    if (nombre.isEmpty) return '?';
    return nombre[0].toUpperCase();
  }

  static int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }
}
