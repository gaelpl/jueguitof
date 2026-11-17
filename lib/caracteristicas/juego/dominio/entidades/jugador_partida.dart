class JugadorPartida {
  final String idSocket;
  final int idUsuario;
  final String usuario;
  final int puntuacion;
  final bool listo;

  const JugadorPartida({
    required this.idSocket,
    required this.idUsuario,
    required this.usuario,
    this.puntuacion = 0,
    this.listo = false,
  });

  factory JugadorPartida.desdeJson(Map<String, dynamic> datos) {
    return JugadorPartida(
      idSocket: datos['socketId']?.toString() ?? '',
      idUsuario: _comoEntero(datos['idUsuario']) ?? 0,
      usuario: datos['usuario']?.toString() ?? 'Jugador',
      puntuacion: _comoEntero(datos['puntuacion']) ?? 0,
      listo: datos['listo'] == true,
    );
  }

  JugadorPartida copiarCon({int? puntuacion, bool? listo}) {
    return JugadorPartida(
      idSocket: idSocket,
      idUsuario: idUsuario,
      usuario: usuario,
      puntuacion: puntuacion ?? this.puntuacion,
      listo: listo ?? this.listo,
    );
  }

  static int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }
}
