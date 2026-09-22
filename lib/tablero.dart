import 'juego_logica.dart';

class Punto2D {
  final int x;
  final int y;
  const Punto2D(this.x, this.y);

  @override
  bool operator ==(Object otro) =>
      identical(this, otro) ||
      otro is Punto2D &&
          runtimeType == otro.runtimeType &&
          x == otro.x &&
          y == otro.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class Tablero {
  final int alto;
  final int ancho;
  final List<Celda> celdas;
  final Map<Region, Zona> mapaZonas;

  Tablero({
    this.alto = 7,
    this.ancho = 7,
    required this.celdas,
    required List<Zona> zonas,
  }) : mapaZonas = {for (var z in zonas) z.region: z};

  Zona? obtenerZona(Region region) => mapaZonas[region];

  Celda? obtenerCeldaEn(int x, int y) {
    try {
      return celdas.firstWhere((c) => c.columna == x && c.fila == y);
    } catch (_) {
      return null;
    }
  }

  bool colocarValorEn(int x, int y, int valor) {
    final celda = obtenerCeldaEn(x, y);
    if (celda == null) return false;
    return celda.asignarValor(valor);
  }

  List<Celda> obtenerCeldasEstrella() {
    return celdas.where((c) => c.esEstrella).toList();
  }

  bool estanEstrellasCompletas() {
    final estrellas = obtenerCeldasEstrella();
    if (estrellas.length != 6) return false;

    final valores = estrellas.map((e) => e.valor).whereType<int>().toSet();
    return valores.length == 6 && valores.every((v) => v >= 1 && v <= 6);
  }

  static Punto2D cartesianoAPantalla(
    int xCartesiano,
    int yCartesiano,
    int altoTablero,
  ) {
    return Punto2D(xCartesiano, (altoTablero - 1) - yCartesiano);
  }

  static Punto2D pantallaACartesiano(
    int xPantalla,
    int yPantalla,
    int altoTablero,
  ) {
    return Punto2D(xPantalla, (altoTablero - 1) - yPantalla);
  }
}
