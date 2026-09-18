import 'juego_logica.dart';

/// Clase auxiliar para representar puntos o coordenadas en el plano.
class Point2D {
  final int x;
  final int y;
  const Point2D(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point2D &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// CLASE PRINCIPAL: Une el tablero con las Zonas del juego, administra las Celdas
/// y gestiona el plano cartesiano con eje Y invertido (hacia abajo).
class Tablero {
  final int alto;
  final int ancho;
  final List<Celda> celdas;
  final Map<Region, Zona> zonasMap;

  Tablero({
    this.alto = 8,
    this.ancho = 8,
    required this.celdas,
    required List<Zona> zonas,
  }) : zonasMap = {for (var z in zonas) z.region: z};

  /// Asocia y obtiene la Zona según la Región consultada.
  Zona? obtenerZona(Region region) => zonasMap[region];

  /// Obtiene la celda dada su posición X (columna) e Y (fila, hacia abajo).
  Celda? obtenerCeldaEn(int x, int y) {
    try {
      return celdas.firstWhere((c) => c.columna == x && c.fila == y);
    } catch (_) {
      return null;
    }
  }

  /// Convierte coordenadas cartesianas estándar (Y hacia arriba, origen abajo-izquierda)
  /// a coordenadas de pantalla (Y hacia abajo, origen arriba-izquierda).
  static Point2D cartesianoAPantalla(
    int xCartesiano,
    int yCartesiano,
    int altoTablero,
  ) {
    int xPantalla = xCartesiano;
    int yPantalla = (altoTablero - 1) - yCartesiano;
    return Point2D(xPantalla, yPantalla);
  }

  /// Convierte coordenadas de pantalla (Y hacia abajo) a cartesianas (Y hacia arriba).
  static Point2D pantallaACartesiano(
    int xPantalla,
    int yPantalla,
    int altoTablero,
  ) {
    int xCartesiano = xPantalla;
    int yCartesiano = (altoTablero - 1) - yPantalla;
    return Point2D(xCartesiano, yCartesiano);
  }
}
