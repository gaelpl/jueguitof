import '../../datos/mapas_oficiales.dart';
import '../logica/juego_logica.dart';

class TableroRival {
  final Tablero tablero;
  final int numeroRonda;
  final DateTime actualizadoEn;

  const TableroRival({
    required this.tablero,
    this.numeroRonda = 0,
    required this.actualizadoEn,
  });

  factory TableroRival.desdeJson(Map<String, dynamic> datos) {
    final int numeroMapa = _comoEntero(datos['numeroMapa']) ?? 1;
    final Tablero tablero = CreadorMapas.obtenerMapa(numeroMapa);
    final dynamic celdas = datos['celdas'];

    if (celdas is List) {
      for (final dynamic valor in celdas) {
        if (valor is! Map) continue;
        final int? columna = _comoEntero(valor['columna']);
        final int? fila = _comoEntero(valor['fila']);
        if (columna == null || fila == null) continue;

        final Celda? celda = tablero.obtenerCeldaEn(columna, fila);
        celda?.asignarValor(_comoEntero(valor['valor']));
      }
    }

    final int? milisegundos = _comoEntero(datos['actualizadoEn']);

    return TableroRival(
      tablero: tablero,
      numeroRonda: _comoEntero(datos['numeroRonda']) ?? 0,
      actualizadoEn: milisegundos == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(milisegundos),
    );
  }

  static int? _comoEntero(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor);
    return null;
  }
}
