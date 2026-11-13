import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jueguitof/caracteristicas/juego/datos/mapas_oficiales.dart';
import 'package:jueguitof/caracteristicas/juego/dominio/logica/juego_logica.dart';
import 'package:jueguitof/caracteristicas/juego/presentacion/blocs/inicio_juego_bloc/inicio_juego_bloc.dart';
import 'package:jueguitof/caracteristicas/juego/presentacion/blocs/juego_bloc.dart';
import 'package:jueguitof/caracteristicas/juego/presentacion/blocs/juego_turno_bloc/juego_turno_bloc.dart';
import 'package:jueguitof/nucleo/tema/colores_region.dart';

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

  group('Pruebas de BLoC - Validacion del Estado Inicial', () {
    late Tablero tablero;
    late JuegoBloc bloc;

    setUp(() {
      final zonas = [Zona(region: Region.azulNorte, tipo: TipoAzul())];

      final celdas = [
        Celda(columna: 0, fila: 0, region: Region.azulNorte, esEstrella: true),
        Celda(columna: 1, fila: 0, region: Region.azulNorte, esEstrella: true),
        Celda(columna: 2, fila: 0, region: Region.azulNorte, esEstrella: true),
        Celda(columna: 3, fila: 0, region: Region.azulNorte, esEstrella: true),
        Celda(columna: 4, fila: 0, region: Region.azulNorte, esEstrella: true),
        Celda(columna: 5, fila: 0, region: Region.azulNorte, esEstrella: true),
      ];

      tablero = Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
      bloc = JuegoBloc(tablero);
    });

    test('no permite avanzar de estado si faltan numeros iniciales', () {
      expect(bloc.estadoActual, isA<JuegoEstadoInicial>());

      bloc.procesarEvento(EventoColocarNumeroInicial(0, 0, 1));
      bloc.procesarEvento(EventoColocarNumeroInicial(1, 0, 2));

      expect(bloc.estadoActual, isA<JuegoEstadoInicial>());
    });

    test('avanza a estado turno únicamente cuando se completan los 6 números iniciales', () {
      bloc.procesarEvento(EventoColocarNumeroInicial(0, 0, 1));
      bloc.procesarEvento(EventoColocarNumeroInicial(1, 0, 2));
      bloc.procesarEvento(EventoColocarNumeroInicial(2, 0, 3));
      bloc.procesarEvento(EventoColocarNumeroInicial(3, 0, 4));
      bloc.procesarEvento(EventoColocarNumeroInicial(4, 0, 5));
      bloc.procesarEvento(EventoColocarNumeroInicial(5, 0, 6));

      expect(bloc.estadoActual, isA<JuegoEstadoTurno>());
    });

    test('cambia a estado fin cuando se procesa abandono', () {
      bloc.procesarEvento(EventoAbandonar());
      expect(bloc.estadoActual, isA<JuegoEstadoFin>());
    });
  });

  group('Pruebas del BLoC de Seleccion Inicial - Parte 1', () {
    late Tablero tablero;
    late InicioJuegoBloc bloc;

    setUp(() {
      final zonas = [Zona(region: Region.azulNorte, tipo: TipoAzul())];
      final celdas = [
        Celda(columna: 0, fila: 0, region: Region.azulNorte, esEstrella: true),
        Celda(columna: 1, fila: 0, region: Region.azulNorte, esEstrella: true),
      ];
      tablero = Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
      bloc = InicioJuegoBloc(tablero);
    });

    test('cambia el numero seleccionado en la paleta correctamente', () {
      bloc.add(EventoSeleccionarNumero(4));
      expect(
        bloc.stream,
        emitsThrough(
          predicate<InicioJuegoEstado>(
            (state) => state.numeroSeleccionado == 4,
          ),
        ),
      );
    });

    test(
      'reubica un numero si se asigna a otra estrella para evitar duplicados',
      () async {
        bloc.add(EventoSeleccionarNumero(2));
        bloc.add(EventoColocarNumeroEnEstrella(0, 0));
        await pumpEventQueue();

        bloc.add(EventoSeleccionarNumero(2));
        bloc.add(EventoColocarNumeroEnEstrella(1, 0));
        await pumpEventQueue();

        expect(tablero.obtenerCeldaEn(0, 0)!.valor, isNull);
        expect(tablero.obtenerCeldaEn(1, 0)!.valor, equals(2));
      },
    );

    test('habilita la bandera de estrellas completas cuando se llenan las casillas requeridas', () async {
      for (int i = 0; i < 2; i++) {
        bloc.add(EventoSeleccionarNumero(i + 1));
        bloc.add(EventoColocarNumeroEnEstrella(i, 0));
        await pumpEventQueue();
      }

      bloc.add(EventoConfirmarInicio());
      await pumpEventQueue();

      expect(bloc.state.juegoIniciado, isFalse);
    });
  });

  group('Pruebas del Modelo Dado', () {
    test('crea un dado con valor por defecto o especifico', () {
      const dadoDefecto = Dado();
      const dadoCinco = Dado(5);

      expect(dadoDefecto.valor, equals(1));
      expect(dadoCinco.valor, equals(5));
    });

    test('lanzar genera valores validos dentro del rango 1 a 6', () {
      for (int i = 0; i < 50; i++) {
        final dado = Dado.lanzar();
        expect(dado.valor, greaterThanOrEqualTo(1));
        expect(dado.valor, lessThanOrEqualTo(6));
      }
    });
  });

  group('Pruebas de Selección de Ancla y Adyacencias Válidas', () {
    late Tablero tablero;

    setUp(() {
      final zonas = [
        Zona(region: Region.azulNorte, tipo: TipoAzul()),
        Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
      ];
      final celdas = [
        Celda(
          columna: 0,
          fila: 0,
          region: Region.azulNorte,
          valor: 3,
        ), // Celda Ancla
        Celda(
          columna: 1,
          fila: 0,
          region: Region.azulNorte,
          valor: null,
        ), // Adyacente Derecha
        Celda(
          columna: 0,
          fila: 1,
          region: Region.verdeNoroeste,
          valor: null,
        ), // Adyacente Abajo
        Celda(
          columna: 3,
          fila: 3,
          region: Region.verdeNoroeste,
          valor: null,
        ), // Celda Distante
      ];
      tablero = Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
    });

    test('obtiene unicamente celdas adyacentes ortogonales al ancla', () {
      final ancla = tablero.obtenerCeldaEn(0, 0)!;
      final adyacentes = obtenerCeldasAdyacentes(tablero, ancla);

      expect(adyacentes.length, equals(2));
      expect(adyacentes.any((c) => c.columna == 1 && c.fila == 0), isTrue);
      expect(adyacentes.any((c) => c.columna == 0 && c.fila == 1), isTrue);
    });

    test(
      'identifica casillas objetivo validas para colocar el valor del dado',
      () {
        final ancla = tablero.obtenerCeldaEn(0, 0)!;
        final validas = obtenerCeldasObjetivoValidas(
          tablero: tablero,
          celdaAncla: ancla,
          valorAColocar: 3,
        );

        expect(validas.length, equals(2));
      },
    );
  });

  group('Pruebas del Sistema de Puntuación', () {
    test('calcula correctamente la puntuacion total acumulada del tablero', () {
      final zonas = [Zona(region: Region.azulNorte, tipo: TipoAzul())];
      final celdas = [
        Celda(columna: 0, fila: 0, region: Region.azulNorte, valor: 3),
      ];
      final tablero = Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);

      final puntaje = calcularPuntuacionTotal(tablero);
      expect(
        puntaje,
        equals(7), // Para TipoAzul otorga 7 pts al completarse
      );
    });
  });

  group('Progreso de zonas para la leyenda', () {
    test('marca una zona incompleta y conserva sus puntos', () {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [
          Celda(columna: 0, fila: 0, region: Region.azulNorte, valor: 3),
          Celda(columna: 1, fila: 0, region: Region.azulNorte),
        ],
        zonas: [Zona(region: Region.azulNorte, tipo: TipoAzul())],
      );

      final progreso = calcularProgresoZonas(tablero).single;

      expect(progreso.totalCeldas, 2);
      expect(progreso.celdasCompletadas, 1);
      expect(progreso.puntos, 7);
      expect(progreso.completada, isFalse);
    });

    test('marca una zona completa cuando todas sus celdas tienen valor', () {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [
          Celda(columna: 0, fila: 0, region: Region.azulNorte, valor: 3),
          Celda(columna: 1, fila: 0, region: Region.azulNorte, valor: 3),
        ],
        zonas: [Zona(region: Region.azulNorte, tipo: TipoAzul())],
      );

      final progreso = calcularProgresoZonas(tablero).single;

      expect(progreso.celdasCompletadas, 2);
      expect(progreso.completada, isTrue);
    });

    test('omite zonas declaradas sin celdas en el tablero', () {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [
          Celda(columna: 0, fila: 0, region: Region.azulNorte, valor: 3),
        ],
        zonas: [
          Zona(region: Region.azulNorte, tipo: TipoAzul()),
          Zona(region: Region.rojoSureste, tipo: TipoRojo()),
        ],
      );

      final progresos = calcularProgresoZonas(tablero);

      expect(progresos, hasLength(1));
      expect(progresos.single.region, Region.azulNorte);
    });
  });

  group('Nombres base de la leyenda', () {
    test('usa solo el color base para todas las regiones', () {
      expect(nombreDeRegion(Region.rojoNoroeste), 'Rojo');
      expect(nombreDeRegion(Region.rojoSureste), 'Rojo');
      expect(nombreDeRegion(Region.azulNorte), 'Azul');
      expect(nombreDeRegion(Region.azulSureste), 'Azul');
      expect(nombreDeRegion(Region.verdeNoroeste), 'Verde');
      expect(nombreDeRegion(Region.verdeEste), 'Verde');
      expect(nombreDeRegion(Region.lilaNorte), 'Morado');
      expect(nombreDeRegion(Region.lilaSuroeste), 'Morado');
      expect(nombreDeRegion(Region.amarillo), 'Amarillo');
      expect(nombreDeRegion(Region.naranjaNorte), 'Naranja');
      expect(nombreDeRegion(Region.blanco), 'Blanco');
    });
  });

  group('Resumen de regiones por tipo', () {
    test('agrupa bloques del mismo tipo y cuenta los completados', () {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [
          Celda(columna: 0, fila: 0, region: Region.rojoNoroeste, valor: 1),
          Celda(columna: 1, fila: 0, region: Region.rojoNoroeste, valor: 2),
          Celda(columna: 0, fila: 1, region: Region.rojoSureste, valor: 3),
          Celda(columna: 1, fila: 1, region: Region.rojoSureste),
        ],
        zonas: [
          Zona(region: Region.rojoNoroeste, tipo: TipoRojo()),
          Zona(region: Region.rojoSureste, tipo: TipoRojo()),
        ],
      );

      final resumen = calcularResumenRegiones(tablero);
      final rojo = resumen.singleWhere(
        (region) => region.tipo.identificador == 'rojo',
      );

      expect(rojo.nombre, 'Rojo');
      expect(rojo.totalBloques, 2);
      expect(rojo.bloquesCompletados, 1);
      expect(rojo.puntosPorPuesto, [6, 4, 2]);
      expect(estaRegionCompletada(tablero, Region.rojoNoroeste), isTrue);
      expect(estaRegionCompletada(tablero, Region.rojoSureste), isFalse);
    });

    test('nombra cada bloque y recupera la región desde el servidor', () {
      expect(regionDesdeNombre('rojoNoreste'), Region.rojoNoreste);
      expect(regionDesdeNombre('inexistente'), isNull);
      expect(nombreBloqueRegion(Region.rojoNoroeste), 'Noroeste');
      expect(nombreBloqueRegion(Region.rojoNoreste), 'Noreste');
      expect(nombreBloqueRegion(Region.rojoSuroeste), 'Suroeste');
      expect(nombreBloqueRegion(Region.rojoSureste), 'Sureste');
      expect(nombreBloqueRegion(Region.naranjaNorte), 'Norte');
      expect(nombreBloqueRegion(Region.naranjaSur), 'Sur');
      expect(nombreBloqueRegion(Region.amarillo), '');
    });
  });

  group('Rondas multijugador de JuegoTurnoBloc', () {
    test('sincroniza dados, acción y ronda lista', () async {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [Celda(columna: 0, fila: 0, region: Region.amarillo, valor: 3)],
        zonas: [Zona(region: Region.amarillo, tipo: TipoAmarillo())],
      );
      final bloc = JuegoTurnoBloc(
        tablero,
        tuIdSocket: 'socket-ana',
        anfitrion: 'socket-ana',
      );

      bloc.add(EventoEstadoListos(todosListos: true, listos: 1, total: 1));
      await pumpEventQueue();

      expect(bloc.state.puedeLanzarDados, isTrue);

      bloc.add(
        EventoDadosLanzados(
          dado1: const Dado(3),
          dado2: const Dado(5),
          anfitrion: 'socket-ana',
          numeroRonda: 1,
          segundosRestantes: 300,
        ),
      );
      await pumpEventQueue();

      expect(bloc.state.rondaActiva, isTrue);
      expect(bloc.state.puedeLanzarDados, isFalse);
      expect(bloc.state.puedeSaltarTurno, isTrue);
      expect(bloc.state.dado1?.valor, 3);
      expect(bloc.state.dado2?.valor, 5);
      expect(bloc.state.segundosRestantesRonda, 300);

      bloc.add(EventoSaltarTurno());
      await pumpEventQueue();

      expect(bloc.state.accionTurnoCompletada, isTrue);
      expect(bloc.state.puedeSaltarTurno, isFalse);

      bloc.add(
        EventoRondaLista(
          anfitrion: 'socket-ana',
          numeroRonda: 1,
          motivo: 'completada',
        ),
      );
      await pumpEventQueue();

      expect(bloc.state.rondaActiva, isFalse);
      expect(bloc.state.accionTurnoCompletada, isFalse);
      expect(bloc.state.dado1, isNull);
      expect(bloc.state.dado2, isNull);
      expect(bloc.state.puedeLanzarDados, isTrue);

      await bloc.close();
    });

    test('un jugador que no es anfitrión no puede lanzar dados', () async {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [Celda(columna: 0, fila: 0, region: Region.amarillo, valor: 3)],
        zonas: [Zona(region: Region.amarillo, tipo: TipoAmarillo())],
      );
      final bloc = JuegoTurnoBloc(
        tablero,
        tuIdSocket: 'socket-luis',
        anfitrion: 'socket-ana',
      );

      expect(bloc.state.esAnfitrion, isFalse);
      expect(bloc.state.puedeLanzarDados, isFalse);

      await bloc.close();
    });
  });

  group('Rendición local de JuegoTurnoBloc', () {
    test('emite JuegoRendicionLocal sin código de sala', () async {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [
          Celda(columna: 0, fila: 0, region: Region.azulNorte, valor: 3),
        ],
        zonas: [Zona(region: Region.azulNorte, tipo: TipoAzul())],
      );
      final bloc = JuegoTurnoBloc(tablero);

      bloc.add(EventoRendirse());
      await pumpEventQueue();

      expect(bloc.state, isA<JuegoRendicionLocal>());

      await bloc.close();
    });
  });

  group('Pruebas de JuegoTurnoBloc con 2 Dados', () {
    late Tablero tablero;
    late JuegoTurnoBloc bloc;

    setUp(() {
      final zonas = [
        Zona(region: Region.azulNorte, tipo: TipoAzul()),
        Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
      ];
      final celdas = [
        Celda(columna: 0, fila: 0, region: Region.azulNorte, valor: 3), // Ancla
        Celda(
          columna: 1,
          fila: 0,
          region: Region.verdeNoroeste,
          valor: null,
        ), // Adyacente Verde (acepta cualquier número)
      ];
      tablero = Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
      bloc = JuegoTurnoBloc(tablero);
    });

    tearDown(() {
      bloc.close();
    });

    test('lanzar dados genera 2 dados en el estado', () async {
      bloc.add(
        EventoLanzarDados(
          dado1Forzado: const Dado(3),
          dado2Forzado: const Dado(5),
        ),
      );
      await pumpEventQueue();

      expect(bloc.state.dado1, equals(const Dado(3)));
      expect(bloc.state.dado2, equals(const Dado(5)));
    });

    test(
      'seleccionar dado ancla establece los roles de ancla y colocacion',
      () async {
        bloc.add(
          EventoLanzarDados(
            dado1Forzado: const Dado(3),
            dado2Forzado: const Dado(5),
          ),
        );
        await pumpEventQueue();

        bloc.add(EventoSeleccionarDadoAncla(0)); // Dado 1 (valor 3) es ancla
        await pumpEventQueue();

        expect(bloc.state.dadoAncla?.valor, equals(3));
        expect(bloc.state.dadoColocar?.valor, equals(5));
      },
    );

    test(
      'seleccionar casilla ancla valida que coincida con el dado ancla',
      () async {
        bloc.add(
          EventoLanzarDados(
            dado1Forzado: const Dado(3),
            dado2Forzado: const Dado(5),
          ),
        );
        await pumpEventQueue();

        bloc.add(EventoSeleccionarDadoAncla(0));
        await pumpEventQueue();

        final celdaTres = tablero.obtenerCeldaEn(0, 0)!;
        bloc.add(EventoSeleccionarAnclaTablero(celdaTres));
        await pumpEventQueue();

        expect(bloc.state.celdaAncla, equals(celdaTres));
        expect(bloc.state.celdasObjetivoValidas.length, equals(1));
      },
    );

    test(
      'colocar numero consume la jugada y limpia los dados del estado',
      () async {
        bloc.add(
          EventoLanzarDados(
            dado1Forzado: const Dado(3),
            dado2Forzado: const Dado(5),
          ),
        );
        await pumpEventQueue();

        bloc.add(EventoSeleccionarDadoAncla(0));
        await pumpEventQueue();

        final celdaTres = tablero.obtenerCeldaEn(0, 0)!;
        bloc.add(EventoSeleccionarAnclaTablero(celdaTres));
        await pumpEventQueue();

        final objetivo = bloc.state.celdasObjetivoValidas.first;
        bloc.add(EventoColocarNumeroEnObjetivo(objetivo));
        await pumpEventQueue();

        expect(objetivo.valor, equals(5));
        expect(bloc.state.dado1, isNull);
        expect(bloc.state.dado2, isNull);
        expect(bloc.state.celdaAncla, isNull);
        expect(bloc.state.celdasObjetivoValidas, isEmpty);
      },
    );
  });

  group('Mensajes didácticos de JuegoTurnoBloc', () {
    late Tablero tablero;
    late JuegoTurnoBloc bloc;

    setUp(() {
      final zonas = [
        Zona(region: Region.azulNorte, tipo: TipoAzul()),
        Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
      ];
      final celdas = [
        Celda(columna: 0, fila: 0, region: Region.azulNorte, valor: 3),
        Celda(columna: 1, fila: 0, region: Region.azulNorte),
        Celda(columna: 0, fila: 1, region: Region.verdeNoroeste),
        Celda(columna: 2, fila: 0, region: Region.verdeNoroeste, valor: 1),
        Celda(columna: 3, fila: 3, region: Region.verdeNoroeste),
      ];
      tablero = Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
      bloc = JuegoTurnoBloc(
        tablero,
        duracionMensajeAyuda: const Duration(milliseconds: 40),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    Future<void> lanzarDados() async {
      bloc.add(
        EventoLanzarDados(
          dado1Forzado: const Dado(3),
          dado2Forzado: const Dado(5),
        ),
      );
      await pumpEventQueue();
    }

    test('avisa que primero debe lanzar los dados', () async {
      bloc.add(EventoMovimientoInvalido(tablero.obtenerCeldaEn(1, 0)!));
      await pumpEventQueue();

      expect(bloc.state.mensajeAyuda, mensajeDadosNoLanzados());
    });

    test('explica la regla de las casillas azules', () async {
      await lanzarDados();

      bloc.add(EventoSeleccionarDadoAncla(0));
      await pumpEventQueue();

      bloc.add(EventoSeleccionarAnclaTablero(tablero.obtenerCeldaEn(0, 0)!));
      await pumpEventQueue();

      bloc.add(EventoMovimientoInvalido(tablero.obtenerCeldaEn(1, 0)!));
      await pumpEventQueue();

      expect(bloc.state.mensajeAyuda, contains('azules'));
      expect(bloc.state.mensajeAyuda, contains('iguales'));
    });

    test('explica que una casilla ocupada no coincide con los dados', () async {
      await lanzarDados();

      bloc.add(EventoSeleccionarAnclaTablero(tablero.obtenerCeldaEn(2, 0)!));
      await pumpEventQueue();

      expect(bloc.state.mensajeAyuda, contains('Casilla ocupada'));
      expect(bloc.state.mensajeAyuda, contains('1'));
    });

    test('explica que solo se puede colocar junto al ancla', () async {
      await lanzarDados();

      bloc.add(EventoSeleccionarDadoAncla(0));
      await pumpEventQueue();

      bloc.add(EventoSeleccionarAnclaTablero(tablero.obtenerCeldaEn(0, 0)!));
      await pumpEventQueue();

      bloc.add(EventoMovimientoInvalido(tablero.obtenerCeldaEn(3, 3)!));
      await pumpEventQueue();

      expect(bloc.state.mensajeAyuda, contains('adyacente'));
    });

    test('limpia automáticamente el mensaje de ayuda', () async {
      bloc.add(EventoMovimientoInvalido(tablero.obtenerCeldaEn(1, 0)!));
      await pumpEventQueue();

      expect(bloc.state.mensajeAyuda, isNotNull);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await pumpEventQueue();

      expect(bloc.state.mensajeAyuda, isNull);
    });
  });

  group('Regla Blanco (todos idénticos, 8/6/4 pts)', () {
    final tipo = TipoBlanco();

    test(
      'permite colocar si la lista está vacía o si el número es idéntico',
      () {
        expect(tipo.esPosibleAgregar([], 5), isTrue);
        expect(tipo.esPosibleAgregar([5, 5], 5), isTrue);
        expect(tipo.esPosibleAgregar([5, 5], 3), isFalse);
      },
    );

    test('puntuación otorga 8 pts al completar 1.er lugar', () {
      expect(tipo.puntuaciones[1], equals(8));
    });
  });

  group('Regla Naranja (4-6 arriba / 1-3 abajo, 6/4/3 pts)', () {
    final tipoArriba = TipoNaranja(esFilaSuperior: true);
    final tipoAbajo = TipoNaranja(esFilaSuperior: false);

    test('fila superior solo permite 4, 5 y 6', () {
      expect(tipoArriba.esPosibleAgregar([], 4), isTrue);
      expect(tipoArriba.esPosibleAgregar([], 6), isTrue);
      expect(tipoArriba.esPosibleAgregar([], 3), isFalse);
    });

    test('fila inferior solo permite 1, 2 y 3', () {
      expect(tipoAbajo.esPosibleAgregar([], 1), isTrue);
      expect(tipoAbajo.esPosibleAgregar([], 3), isTrue);
      expect(tipoAbajo.esPosibleAgregar([], 4), isFalse);
    });

    test('puntuación otorga 6 pts al completar 1.er lugar', () {
      expect(tipoArriba.puntuaciones[1], equals(6));
    });
  });

  group('CreadorMapas (Fabrica de Mapas 1-4)', () {
    test(
      'genera los 4 mapas oficiales con 49 celdas y 6 estrellas cada uno',
      () {
        for (int i = 1; i <= 4; i++) {
          final tablero = CreadorMapas.obtenerMapa(i);
          expect(tablero.celdas.length, equals(49));
          expect(tablero.obtenerCeldasEstrella().length, equals(6));
        }
      },
    );
    test(
      'Mapa 4 configura adecuadamente sus 4 bloques rojos y 2 zonas naranjas',
      () {
        final mapa4 = CreadorMapas.mapa4();

        expect(mapa4.obtenerZona(Region.naranjaNorte), isNotNull);
        expect(mapa4.obtenerZona(Region.naranjaSur), isNotNull);
        expect(mapa4.obtenerZona(Region.rojoNoroeste), isNotNull);
        expect(mapa4.obtenerZona(Region.rojoNoreste), isNotNull);
        expect(mapa4.obtenerZona(Region.rojoSuroeste), isNotNull);
        expect(mapa4.obtenerZona(Region.rojoSureste), isNotNull);
      },
    );
  });

  group('InicioJuegoBloc (Restricciones de Zona en Estrellas)', () {
    test('bloquea la asignacion de un numero invalido en la estrella de Naranja Norte', () {
      final tableroMapa4 = CreadorMapas.mapa4();
      final bloc = InicioJuegoBloc(tableroMapa4);

      // Intentar asignar 1 (inválido para Naranja Norte que requiere 4-6)
      bloc.add(EventoSeleccionarNumero(1));
      bloc.add(EventoColocarNumeroEnEstrella(5, 0));

      expect(bloc.state.tablero.obtenerCeldaEn(5, 0)?.valor, isNull);
    });
  });

  group('Llenado aleatorio y limpieza de estrellas', () {
    test('asigna los números del 1 al 6 respetando las reglas de zona', () {
      final tablero = CreadorMapas.mapa4();

      final exito = asignarEstrellasAleatorias(tablero, generador: Random(7));

      expect(exito, isTrue);
      expect(tablero.estanEstrellasCompletas(), isTrue);

      final estrellas = tablero.obtenerCeldasEstrella();
      final valores = estrellas
          .map((estrella) => estrella.valor)
          .whereType<int>()
          .toList();

      expect(valores.toSet(), equals({1, 2, 3, 4, 5, 6}));

      for (final estrella in estrellas) {
        final zona = tablero.obtenerZona(estrella.region);
        expect(zona, isNotNull);

        final valoresDeLaZona = estrellas
            .where((otra) => otra != estrella && otra.region == estrella.region)
            .map((otra) => otra.valor)
            .whereType<int>()
            .toList();

        expect(
          zona!.tipo.esPosibleAgregar(valoresDeLaZona, estrella.valor!),
          isTrue,
        );
      }
    });

    test('limpiarEstrellas deja todas las estrellas vacías', () {
      final tablero = CreadorMapas.mapa1();
      asignarEstrellasAleatorias(tablero, generador: Random(3));

      limpiarEstrellas(tablero);

      expect(
        tablero.obtenerCeldasEstrella().every(
          (estrella) => estrella.valor == null,
        ),
        isTrue,
      );
      expect(tablero.estanEstrellasCompletas(), isFalse);
    });

    test('InicioJuegoBloc llena y limpia las estrellas', () async {
      final tablero = CreadorMapas.mapa1();
      final bloc = InicioJuegoBloc(tablero);

      bloc.add(EventoLlenarEstrellasAleatorio());
      await pumpEventQueue();

      expect(bloc.state.estanListasEstrellas, isTrue);
      expect(tablero.estanEstrellasCompletas(), isTrue);

      bloc.add(EventoLimpiarEstrellas());
      await pumpEventQueue();

      expect(bloc.state.estanListasEstrellas, isFalse);
      expect(
        tablero.obtenerCeldasEstrella().every(
          (estrella) => estrella.valor == null,
        ),
        isTrue,
      );

      await bloc.close();
    });
  });
}
