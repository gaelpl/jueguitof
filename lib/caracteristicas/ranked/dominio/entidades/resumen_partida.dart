class EntradaResumenPartida {
  final int idUsuario;
  final String usuario;
  final int puesto;
  final int puntuacion;
  final int rpDelta;
  final String liga;

  const EntradaResumenPartida({
    required this.idUsuario,
    required this.usuario,
    required this.puesto,
    required this.puntuacion,
    required this.rpDelta,
    required this.liga,
  });

  factory EntradaResumenPartida.desdeJson(Map<String, dynamic> datos) {
    return EntradaResumenPartida(
      idUsuario: _comoEntero(datos['idUsuario']) ?? 0,
      usuario: datos['usuario']?.toString() ?? 'Jugador',
      puesto: _comoEntero(datos['puesto']) ?? 0,
      puntuacion: _comoEntero(datos['puntuacion']) ?? 0,
      rpDelta: _comoEntero(datos['rpDelta']) ?? 0,
      liga: datos['liga']?.toString() ?? 'Bronce',
    );
  }

  static int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }
}

class ResumenPartida {
  final String idPartida;
  final String codigo;
  final String motivoFin;
  final int puesto;
  final int posicionDesde;
  final int posicionHasta;
  final int puntuacion;
  final int rpAntes;
  final int rpDelta;
  final int rpDespues;
  final String ligaAntes;
  final String ligaDespues;
  final bool cambioLiga;
  final List<EntradaResumenPartida> clasificacion;

  const ResumenPartida({
    required this.idPartida,
    required this.codigo,
    required this.motivoFin,
    required this.puesto,
    required this.posicionDesde,
    required this.posicionHasta,
    required this.puntuacion,
    required this.rpAntes,
    required this.rpDelta,
    required this.rpDespues,
    required this.ligaAntes,
    required this.ligaDespues,
    required this.cambioLiga,
    required this.clasificacion,
  });

  factory ResumenPartida.desdeJson(Map<String, dynamic> datos) {
    final dynamic clasificacion = datos['clasificacion'];
    final List<EntradaResumenPartida> entradas = clasificacion is List
        ? clasificacion
              .whereType<Map>()
              .map(
                (entrada) => EntradaResumenPartida.desdeJson(
                  Map<String, dynamic>.from(entrada),
                ),
              )
              .toList()
        : const [];

    return ResumenPartida(
      idPartida: datos['idPartida']?.toString() ?? '',
      codigo: datos['codigo']?.toString() ?? '',
      motivoFin: datos['motivoFin']?.toString() ?? 'finalizada',
      puesto: _comoEntero(datos['puesto']) ?? 0,
      posicionDesde: _comoEntero(datos['posicionDesde']) ?? 0,
      posicionHasta: _comoEntero(datos['posicionHasta']) ?? 0,
      puntuacion: _comoEntero(datos['puntuacion']) ?? 0,
      rpAntes: _comoEntero(datos['rpAntes']) ?? 0,
      rpDelta: _comoEntero(datos['rpDelta']) ?? 0,
      rpDespues: _comoEntero(datos['rpDespues']) ?? 0,
      ligaAntes: datos['ligaAntes']?.toString() ?? 'Bronce',
      ligaDespues: datos['ligaDespues']?.toString() ?? 'Bronce',
      cambioLiga: datos['cambioLiga'] == true,
      clasificacion: entradas,
    );
  }

  String get tituloResultado {
    if (puesto == 1) return '¡Victoria!';
    if (motivoFin == 'abandono') return 'Partida abandonada';
    return 'Puesto #$puesto';
  }

  static int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }
}
