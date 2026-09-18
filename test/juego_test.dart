import 'package:flutter_test/flutter_test.dart';
import 'package:jueguitof/juego_logica.dart';

void main() {
  // ==========================================
  // PRUEBAS DE REGLAS POR COLOR
  // ==========================================

  group('Regla Rojo / Amarillo (todos diferentes)', () {
    test('permite insertar un valor no repetido en la lista', () {
      expect(esValidoRojoAmarillo([1, 2, 3], 4), isTrue);
    });

    test('rechaza insertar un valor que ya existe en la lista', () {
      expect(esValidoRojoAmarillo([1, 2, 3], 2), isFalse);
    });

    test('permite insertar en una lista vacía', () {
      expect(esValidoRojoAmarillo([], 5), isTrue);
    });
  });

  group('Regla Verde (comodín, sin restricciones)', () {
    test('permite cualquier valor en lista con elementos repetidos o no', () {
      expect(esValidoVerde([1, 2, 3], 2), isTrue);
      expect(esValidoVerde([4, 4, 4], 5), isTrue);
    });

    test('permite insertar en una lista vacía', () {
      expect(esValidoVerde([], 1), isTrue);
    });
  });

  group('Regla Azul (todos idénticos)', () {
    test('permite insertar el primer valor en una lista vacía', () {
      expect(esValidoAzul([], 4), isTrue);
    });

    test('permite insertar un número idéntico al que define la zona', () {
      expect(esValidoAzul([4, 4, 4], 4), isTrue);
    });

    test('rechaza insertar un número diferente al existente en la zona', () {
      expect(esValidoAzul([4, 4], 2), isFalse);
    });
  });

  group('Regla Lila (máximo dos valores diferentes)', () {
    test('permite el primer número en lista vacía (1 valor único)', () {
      expect(esValidoLila([], 3), isTrue);
    });

    test('permite agregar un segundo valor distinto (2 valores únicos)', () {
      expect(esValidoLila([3, 3], 5), isTrue);
    });

    test('permite repetir cualquiera de los dos valores ya existentes', () {
      expect(esValidoLila([3, 5, 3], 5), isTrue);
    });

    test('rechaza agregar un tercer valor distinto', () {
      expect(esValidoLila([3, 5, 3], 2), isFalse);
    });
  });

  // ==========================================
  // PRUEBAS DE EXTRACCIÓN
  // ==========================================

  group('Función de Extracción de Celdas por Región', () {
    late List<Celda> tableroPrueba;

    setUp(() {
      tableroPrueba = [
        // Bloque rojo noroeste
        Celda(fila: 2, columna: 1, region: Region.rojoNoroeste, valor: 3),
        Celda(fila: 2, columna: 2, region: Region.rojoNoroeste, valor: 5),
        Celda(fila: 3, columna: 1, region: Region.rojoNoroeste, valor: null),

        // Bloque amarillo (zona dispersa)
        Celda(fila: 0, columna: 0, region: Region.amarillo, valor: 1),
        Celda(fila: 4, columna: 4, region: Region.amarillo, valor: 6),
        Celda(fila: 7, columna: 7, region: Region.amarillo, valor: null),

        // Bloque azul norte
        Celda(fila: 0, columna: 2, region: Region.azulNorte, valor: 4),
        Celda(fila: 0, columna: 3, region: Region.azulNorte, valor: 4),

        // Bloque verde este (completamente vacío)
        Celda(fila: 3, columna: 6, region: Region.verdeEste, valor: null),
      ];
    });

    test('extrae solo los números asignados ignorando casillas vacías', () {
      final resultado = extraerValoresDeBloque(
        tableroPrueba,
        Region.rojoNoroeste,
      );
      expect(resultado, equals([3, 5]));
    });

    test(
      'extrae todos los números de la zona amarilla aunque estén separados',
      () {
        final resultado = extraerValoresDeBloque(
          tableroPrueba,
          Region.amarillo,
        );
        expect(resultado, equals([1, 6]));
      },
    );

    test(
      'retorna lista vacía si el bloque solo contiene casillas sin rellenar',
      () {
        final resultado = extraerValoresDeBloque(
          tableroPrueba,
          Region.verdeEste,
        );
        expect(resultado, isEmpty);
      },
    );

    test('retorna lista vacía si la región consultada no tiene celdas', () {
      final resultado = extraerValoresDeBloque(tableroPrueba, Region.lilaNorte);
      expect(resultado, isEmpty);
    });

    test('permite componer la extracción con una regla de validación', () {
      final valoresRojo = extraerValoresDeBloque(
        tableroPrueba,
        Region.rojoNoroeste,
      );
      final puedeInsertar3 = esValidoRojoAmarillo(valoresRojo, 3);
      final puedeInsertar4 = esValidoRojoAmarillo(valoresRojo, 4);

      expect(puedeInsertar3, isFalse);
      expect(puedeInsertar4, isTrue);
    });
  });

  // ==========================================
  // PRUEBAS DE LA CLASE TABLERO Y COORDENADAS
  // ==========================================

  group(
    'Pruebas de la clase Tablero y Conversión de Coordenadas (Y hacia abajo)',
    () {
      late Tablero tablero;
      late List<Zona> zonas;

      setUp(() {
        zonas = [
          Zona(region: Region.azulNorte, tipo: TipoAzul()),
          Zona(region: Region.rojoNoroeste, tipo: TipoRojoAmarillo()),
        ];

        final celdas = [
          Celda(
            columna: 0,
            fila: 0,
            region: Region.azulNorte,
            valor: 4,
          ), // Arriba-izquierda
          Celda(
            columna: 7,
            fila: 7,
            region: Region.rojoNoroeste,
            valor: 2,
          ), // Abajo-derecha
        ];

        tablero = Tablero(celdas: celdas, zonas: zonas);
      });

      test('El Tablero une y retorna la Zona asociada a una Region', () {
        final zonaAzul = tablero.obtenerZona(Region.azulNorte);
        expect(zonaAzul, isNotNull);
        expect(zonaAzul!.tipo, isA<TipoAzul>());
      });

      test('Obtiene una celda dada su posición X e Y en pantalla', () {
        final celda = tablero.obtenerCeldaEn(0, 0);
        expect(celda, isNotNull);
        expect(celda!.valor, equals(4));
      });

      test(
        'Convierte coordenadas cartesianas (Y arriba) a Pantalla (Y abajo)',
        () {
          // En tablero 8x8: punto cartesiano (0, 7) pasa a pantalla (0, 0)
          final puntoPantalla = Tablero.cartesianoAPantalla(0, 7, 8);
          expect(puntoPantalla, equals(const Point2D(0, 0)));
        },
      );

      test(
        'Convierte coordenadas de Pantalla (Y abajo) a Cartesianas (Y arriba)',
        () {
          // Punto de pantalla (0, 0) pasa a cartesiano (0, 7)
          final puntoCartesiano = Tablero.pantallaACartesiano(0, 0, 8);
          expect(puntoCartesiano, equals(const Point2D(0, 7)));
        },
      );
    },
  );
}
