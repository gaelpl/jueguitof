class JugadorPartida {
  final String idSocket;
  final int idUsuario;
  final String usuario;
  final int puntuacion;

  const JugadorPartida({
    required this.idSocket,
    required this.idUsuario,
    required this.usuario,
    this.puntuacion = 0,
  });

  factory JugadorPartida.desdeJson(Map<String, dynamic> datos) {
    return JugadorPartida(
      idSocket: datos['socketId']?.toString() ?? '',
      idUsuario: _comoEntero(datos['idUsuario']) ?? 0,
      usuario: datos['usuario']?.toString() ?? 'Jugador',
      puntuacion: _comoEntero(datos['puntuacion']) ?? 0,
    );
  }

  JugadorPartida copiarCon({int? puntuacion}) {
    return JugadorPartida(
      idSocket: idSocket,
      idUsuario: idUsuario,
      usuario: usuario,
      puntuacion: puntuacion ?? this.puntuacion,
    );
  }

  static int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }
}
