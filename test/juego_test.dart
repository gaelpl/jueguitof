import 'package:flutter_test/flutter_test.dart';
import 'package:jueguitof/juego_logica.dart';

void main() {
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

  group('Función de Extracción de Celdas por Región', () {
    late List<Celda> tableroPrueba;

    setUp(() {
      tableroPrueba = [
        Celda(fila: 2, columna: 1, region: Region.rojoNoroeste, valor: 3),
        Celda(fila: 2, columna: 2, region: Region.rojoNoroeste, valor: 5),
        Celda(fila: 3, columna: 1, region: Region.rojoNoroeste, valor: null),
        Celda(fila: 0, columna: 0, region: Region.amarillo, valor: 1),
        Celda(fila: 4, columna: 4, region: Region.amarillo, valor: 6),
        Celda(fila: 6, columna: 6, region: Region.amarillo, valor: null),
        Celda(fila: 0, columna: 2, region: Region.azulNorte, valor: 4),
        Celda(fila: 0, columna: 3, region: Region.azulNorte, valor: 4),
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
  });

  group('Pruebas del Tablero 7x7 y Asignación de Valores', () {
    late Tablero tablero;

    setUp(() {
      final zonas = [Zona(region: Region.azulNorte, tipo: TipoAzul())];
      final celdas = [
        Celda(columna: 0, fila: 0, region: Region.azulNorte, esEstrella: true),
        Celda(columna: 6, fila: 6, region: Region.azulNorte),
      ];
      tablero = Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
    });

    test('Permite asignar un valor a una celda a través del Tablero', () {
      final exito = tablero.colocarValorEn(0, 0, 5);
      expect(exito, isTrue);
      expect(tablero.obtenerCeldaEn(0, 0)!.valor, equals(5));
    });

    test('Convierte coordenadas correctamente para un tablero 7x7', () {
      final puntoPantalla = Tablero.cartesianoAPantalla(0, 6, 7);
      expect(puntoPantalla, equals(const Punto2D(0, 0)));
    });
  });

  group('Pruebas de BLoC - Inicializacion de estados', () {
    late Tablero tablero;
    late JuegoBloc bloc;

    setUp(() {
      final zonas = [Zona(region: Region.azulNorte, tipo: TipoAzul())];
      final celdas = [
        Celda(columna: 0, fila: 0, region: Region.azulNorte, esEstrella: true),
      ];
      tablero = Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
      bloc = JuegoBloc(tablero);
    });

    test('el juego inicia correctamente en el estado inicial', () {
      expect(bloc.estadoActual, isA<JuegoEstadoInicial>());
    });
  });
}
