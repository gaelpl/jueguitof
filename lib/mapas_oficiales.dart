import 'juego_logica.dart';

class CreadorMapas {
  /// Retorna la instancia del tablero según el número de mapa seleccionado (1, 2, 3 o 4)
  static Tablero obtenerMapa(int numeroMapa) {
    switch (numeroMapa) {
      case 1:
        return mapa1();
      case 2:
        return mapa2();
      case 3:
        return mapa3();
      case 4:
        return mapa4();
      default:
        return mapa1();
    }
  }

  /// MAPA 1 (LEVEL 1)
  static Tablero mapa1() {
    final zonas = [
      Zona(region: Region.amarillo, tipo: TipoAmarillo()),
      Zona(region: Region.azulNorte, tipo: TipoAzul()),
      Zona(region: Region.lilaNorte, tipo: TipoMorado()),
      Zona(region: Region.rojoNoroeste, tipo: TipoRojo()),
      Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
      Zona(region: Region.verdeEste, tipo: TipoVerde()),
      Zona(region: Region.lilaSuroeste, tipo: TipoMorado()),
      Zona(region: Region.rojoSureste, tipo: TipoRojo()),
      Zona(region: Region.azulSureste, tipo: TipoAzul()),
    ];

    List<Celda> celdas = [];
    for (int fila = 0; fila < 7; fila++) {
      for (int columna = 0; columna < 7; columna++) {
        // Estrellas exactas del Mapa 1
        bool esEstrella =
            (columna == 2 && fila == 0) ||
            (columna == 5 && fila == 1) ||
            (columna == 1 && fila == 3) ||
            (columna == 4 && fila == 3) ||
            (columna == 2 && fila == 5) ||
            (columna == 4 && fila == 6);

        Region reg = _obtenerRegionMapa1(columna, fila);
        celdas.add(
          Celda(
            columna: columna,
            fila: fila,
            region: reg,
            esEstrella: esEstrella,
          ),
        );
      }
    }
    return Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
  }

  static Region _obtenerRegionMapa1(int col, int fila) {
    if ((col == 0 && fila == 0) ||
        (col == 6 && fila == 0) ||
        (col == 3 && fila == 3) ||
        (col == 0 && fila == 6) ||
        (col == 6 && fila == 6)) {
      return Region.amarillo;
    }
    if ((col == 2 && fila == 0) ||
        (col == 2 && fila == 1) ||
        (col == 3 && fila == 1) ||
        (col == 3 && fila == 2)) {
      return Region.azulNorte;
    }
    if ((col == 3 && fila == 0) ||
        (col == 4 && fila == 0) ||
        (col == 4 && fila == 1) ||
        (col == 4 && fila == 2) ||
        (col == 5 && fila == 0) ||
        (col == 5 && fila == 1)) {
      return Region.lilaNorte;
    }
    if ((col == 1 && fila == 2) ||
        (col == 2 && fila == 2) ||
        (col == 1 && fila == 3) ||
        (col == 1 && fila == 4) ||
        (col == 0 && fila == 5) ||
        (col == 1 && fila == 5)) {
      return Region.rojoNoroeste;
    }
    if ((col == 3 && fila == 4) ||
        (col == 2 && fila == 3) ||
        (col == 2 && fila == 4) ||
        (col == 2 && fila == 5) ||
        (col == 1 && fila == 6) ||
        (col == 2 && fila == 6)) {
      return Region.lilaSuroeste;
    }
    if ((col == 4 && fila == 4) ||
        (col == 5 && fila == 4) ||
        (col == 3 && fila == 5) ||
        (col == 4 && fila == 5) ||
        (col == 3 && fila == 6) ||
        (col == 4 && fila == 6)) {
      return Region.rojoSureste;
    }
    if ((col == 6 && fila == 4) ||
        (col == 5 && fila == 5) ||
        (col == 6 && fila == 5) ||
        (col == 5 && fila == 6)) {
      return Region.azulSureste;
    }
    if ((col == 5 && fila == 2) ||
        (col == 5 && fila == 3) ||
        (col == 6 && fila == 1) ||
        (col == 6 && fila == 2) ||
        (col == 6 && fila == 3)) {
      return Region.verdeEste;
    }
    return Region.verdeNoroeste;
  }

  /// MAPA 2 (LEVEL 2 - Anillo con Blanco en esquinas)
  static Tablero mapa2() {
    final zonas = [
      Zona(region: Region.blanco, tipo: TipoBlanco()),
      Zona(region: Region.amarillo, tipo: TipoAmarillo()),
      Zona(region: Region.azulNorte, tipo: TipoAzul()),
      Zona(region: Region.azulSureste, tipo: TipoAzul()),
      Zona(region: Region.lilaNorte, tipo: TipoMorado()),
      Zona(region: Region.rojoNoroeste, tipo: TipoRojo()),
      Zona(region: Region.rojoSureste, tipo: TipoRojo()),
      Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
    ];

    List<Celda> celdas = [];
    for (int fila = 0; fila < 7; fila++) {
      for (int columna = 0; columna < 7; columna++) {
        // Estrellas exactas del Mapa 2 según la imagen
        bool esEstrella =
            (columna == 4 && fila == 0) ||
            (columna == 0 && fila == 2) ||
            (columna == 2 && fila == 3) ||
            (columna == 1 && fila == 5) ||
            (columna == 4 && fila == 6) ||
            (columna == 5 && fila == 4);

        Region reg = _obtenerRegionMapa2(columna, fila);
        celdas.add(
          Celda(
            columna: columna,
            fila: fila,
            region: reg,
            esEstrella: esEstrella,
          ),
        );
      }
    }
    return Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
  }

  static Region _obtenerRegionMapa2(int col, int fila) {
    // Casillas Blancas (Centro arriba, centro abajo y esquinas)
    if ((col == 3 && fila == 0) || (col == 3 && fila == 6)) {
      return Region.blanco;
    }
    // Casillas Amarillas
    if ((col == 1 && fila == 1) ||
        (col == 5 && fila == 1) ||
        (col == 3 && fila == 3) ||
        (col == 1 && fila == 5) ||
        (col == 5 && fila == 5)) {
      return Region.amarillo;
    }
    // Bloque Azul norte
    if ((col == 2 && fila == 1) ||
        (col == 3 && fila == 1) ||
        (col == 4 && fila == 1) ||
        (col == 3 && fila == 2) ||
        (col == 4 && fila == 2)) {
      return Region.azulNorte;
    }
    // Bloque Azul sur
    if ((col == 2 && fila == 4) ||
        (col == 3 && fila == 4) ||
        (col == 2 && fila == 5) ||
        (col == 3 && fila == 5) ||
        (col == 4 && fila == 5)) {
      return Region.azulNorte;
    }
    // Bloque Lila exterior
    if ((col == 1 && fila == 0) ||
        (col == 0 && fila == 0) ||
        (col == 2 && fila == 0) ||
        (col == 0 && fila == 1) ||
        (col == 0 && fila == 2) ||
        (col == 6 && fila == 4) ||
        (col == 6 && fila == 5) ||
        (col == 4 && fila == 6) ||
        (col == 5 && fila == 6) ||
        (col == 6 && fila == 6)) {
      return Region.lilaNorte;
    }
    // Bloque Rojo izquierda
    if ((col == 1 && fila == 2) ||
        (col == 1 && fila == 3) ||
        (col == 1 && fila == 4) ||
        (col == 2 && fila == 3) ||
        (col == 2 && fila == 2) ||
        (col == 0 && fila == 3)) {
      return Region.rojoNoroeste;
    }
    // Bloque Rojo derecha
    if ((col == 6 && fila == 3) ||
        (col == 4 && fila == 3) ||
        (col == 5 && fila == 2) ||
        (col == 5 && fila == 3) ||
        (col == 4 && fila == 4) ||
        (col == 5 && fila == 4)) {
      return Region.rojoNoroeste;
    }
    // Verde exterior
    return Region.verdeNoroeste;
  }

  /// MAPA 3 (LEVEL 3 - Filas y T de Morado con Blancas)
  static Tablero mapa3() {
    final zonas = [
      Zona(region: Region.amarillo, tipo: TipoAmarillo()),
      Zona(region: Region.blanco, tipo: TipoBlanco()),
      Zona(region: Region.lilaNorte, tipo: TipoMorado()),
      Zona(region: Region.lilaSuroeste, tipo: TipoMorado()),
      Zona(region: Region.lilaSureste, tipo: TipoMorado()),
      Zona(region: Region.rojoNoroeste, tipo: TipoRojo()),
      Zona(region: Region.rojoSureste, tipo: TipoRojo()),
      Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
      Zona(region: Region.azulNorte, tipo: TipoAzul()),
    ];

    List<Celda> celdas = [];
    for (int fila = 0; fila < 7; fila++) {
      for (int columna = 0; columna < 7; columna++) {
        bool esEstrella =
            (columna == 2 && fila == 1) ||
            (columna == 5 && fila == 1) ||
            (columna == 3 && fila == 3) ||
            (columna == 1 && fila == 4) ||
            (columna == 6 && fila == 4) ||
            (columna == 2 && fila == 6);

        Region reg = _obtenerRegionMapa3(columna, fila);
        celdas.add(
          Celda(
            columna: columna,
            fila: fila,
            region: reg,
            esEstrella: esEstrella,
          ),
        );
      }
    }
    return Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
  }

  static Region _obtenerRegionMapa3(int col, int fila) {
    // 1. Amarillos (Esquinas superiores)
    if ((col == 0 && fila == 0) ||
        (col == 1 && fila == 0) ||
        (col == 5 && fila == 0) ||
        (col == 6 && fila == 0) ||
        (col == 1 && fila == 1) ||
        (col == 5 && fila == 1)) {
      return Region.amarillo;
    }

    // 2. Blancos (Aislados)
    if ((col == 3 && fila == 0) ||
        (col == 0 && fila == 1) ||
        (col == 6 && fila == 1) ||
        (col == 3 && fila == 3) ||
        (col == 3 && fila == 6)) {
      return Region.blanco;
    }

    // 3. Lila T Superior (Filas 0, 1 y 2)
    if ((col == 2 && fila == 0) ||
        (col == 4 && fila == 0) ||
        (col == 2 && fila == 1) ||
        (col == 3 && fila == 1) ||
        (col == 4 && fila == 1) ||
        (col == 3 && fila == 2)) {
      return Region.lilaNorte;
    }

    // 4. Rojo Izquierda (Reutilizamos rojoNoroeste)
    if ((fila == 2 || fila == 3) && (col >= 0 && col <= 2)) {
      return Region.rojoNoroeste;
    }

    // 5. Rojo Derecha (Reutilizamos rojoSureste)
    if ((fila == 2 || fila == 3) && (col >= 4 && col <= 6)) {
      return Region.rojoSureste;
    }

    // 6. Azul Central (Fila 4)
    if (fila == 4 && (col >= 1 && col <= 5)) {
      return Region.azulNorte;
    }

    // 7. Lila Inferior Izquierda
    if (fila == 6 && col <= 2) {
      return Region.lilaSuroeste;
    }

    // 8. Lila Inferior Derecha (Nueva región añadida)
    if (fila == 6 && col >= 4) {
      return Region.lilaSureste;
    }

    // 9. Verde (Fila 4 laterales y Fila 5 completa)
    return Region.verdeNoroeste;
  }

  /// MAPA 4 (LEVEL 4 - Filas Naranjas 4-6 arriba y 1-3 abajo, 4 bloques rojos independientes)
  static Tablero mapa4() {
    final zonas = [
      Zona(
        region: Region.naranjaNorte,
        tipo: TipoNaranja(esFilaSuperior: true),
      ),
      Zona(region: Region.naranjaSur, tipo: TipoNaranja(esFilaSuperior: false)),
      Zona(region: Region.amarillo, tipo: TipoAmarillo()),
      Zona(region: Region.azulNorte, tipo: TipoAzul()),
      Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
      Zona(region: Region.rojoNoroeste, tipo: TipoRojo()),
      Zona(region: Region.rojoNoreste, tipo: TipoRojo()),
      Zona(region: Region.rojoSuroeste, tipo: TipoRojo()),
      Zona(region: Region.rojoSureste, tipo: TipoRojo()),
      Zona(region: Region.lilaNorte, tipo: TipoMorado()),
    ];

    List<Celda> celdas = [];

    // Fila 0 completa -> Naranja Norte (4-6)
    for (int col = 0; col < 7; col++) {
      celdas.add(
        Celda(
          columna: col,
          fila: 0,
          region: Region.naranjaNorte,
          esEstrella: (col == 4),
        ),
      );
    }

    // Filas intermedias 1 a 5
    for (int fila = 1; fila <= 5; fila++) {
      for (int col = 0; col < 7; col++) {
        bool esEstrella =
            (col == 2 && fila == 2) ||
            (col == 5 && fila == 2) ||
            (col == 0 && fila == 3) ||
            (col == 4 && fila == 5);

        Region reg = _obtenerRegionMapa4(col, fila);
        celdas.add(
          Celda(columna: col, fila: fila, region: reg, esEstrella: esEstrella),
        );
      }
    }

    // Fila 6 completa -> Naranja Sur (1-3)
    for (int col = 0; col < 7; col++) {
      celdas.add(
        Celda(
          columna: col,
          fila: 6,
          region: Region.naranjaSur,
          esEstrella: (col == 1),
        ),
      );
    }

    return Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
  }

  static Region _obtenerRegionMapa4(int col, int fila) {
    // Amarillos (Esquinas/Laterales alternados)
    if ((col == 0 && fila == 1) ||
        (col == 6 && fila == 1) ||
        (col == 0 && fila == 3) ||
        (col == 6 && fila == 3) ||
        (col == 0 && fila == 5) ||
        (col == 6 && fila == 5)) {
      return Region.amarillo;
    }

    // Azules
    if ((col == 2 && fila == 1) ||
        (col == 4 && fila == 1) ||
        (col == 2 && fila == 3) ||
        (col == 4 && fila == 3) ||
        (col == 2 && fila == 5) ||
        (col == 4 && fila == 5)) {
      return Region.azulNorte;
    }

    // Verdes
    if ((col == 3 && fila == 1) ||
        (col == 1 && fila == 3) ||
        (col == 5 && fila == 3) ||
        (col == 3 && fila == 5)) {
      return Region.verdeNoroeste;
    }

    // Morado central (Crux de 7 celdas)
    if ((col == 2 && fila == 2) ||
        (col == 3 && fila == 2) ||
        (col == 4 && fila == 2) ||
        (col == 3 && fila == 3) ||
        (col == 2 && fila == 4) ||
        (col == 3 && fila == 4) ||
        (col == 4 && fila == 4)) {
      return Region.lilaNorte;
    }

    // Bloque Rojo 1: Noroeste (3 celdas)
    if ((col == 1 && fila == 1) ||
        (col == 0 && fila == 2) ||
        (col == 1 && fila == 2)) {
      return Region.rojoNoroeste;
    }

    // Bloque Rojo 2: Noreste (3 celdas)
    if ((col == 5 && fila == 1) ||
        (col == 5 && fila == 2) ||
        (col == 6 && fila == 2)) {
      return Region.rojoNoreste;
    }

    // Bloque Rojo 3: Suroeste (3 celdas)
    if ((col == 0 && fila == 4) ||
        (col == 1 && fila == 4) ||
        (col == 1 && fila == 5)) {
      return Region.rojoSuroeste;
    }

    // Bloque Rojo 4: Sureste (3 celdas)
    return Region.rojoSureste;
  }
}
