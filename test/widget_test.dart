import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jueguitof/caracteristicas/juego/dominio/entidades/jugador_partida.dart';
import 'package:jueguitof/caracteristicas/juego/dominio/logica/juego_logica.dart';
import 'package:jueguitof/caracteristicas/juego/presentacion/pantallas/pantalla_juego_turno.dart';
import 'package:jueguitof/caracteristicas/juego/presentacion/pantallas/pantalla_menu_mapas.dart';

void main() {
  group('Widget Tests - Camino Feliz', () {
    testWidgets('Renderiza el menú de mapas y navega a la Selección Inicial', (
      WidgetTester tester,
    ) async {
      // 1. Cargar la app
      await tester.pumpWidget(const MaterialApp(home: PantallaMenuMapas()));
      await tester.pumpAndSettle();

      // 2. Verificar el menú de mapas
      expect(find.text('Selecciona un mapa'), findsOneWidget);
      for (int i = 1; i <= 4; i++) {
        expect(find.text('Mapa $i'), findsOneWidget);
      }

      // 3. Entrar al Mapa 1
      await tester.tap(find.text('Mapa 1'));
      await tester.pumpAndSettle();

      // 4. Verificar títulos y mensajes de la selección inicial
      expect(find.text('Brilliant - Mapa 1'), findsOneWidget);
      expect(
        find.text('Asigna los números del 1 al 6 en las casillas estrella'),
        findsOneWidget,
      );

      // 5. Verificar que el botón INICIO está presente
      expect(find.text('INICIO'), findsOneWidget);

      // 6. Verificar que se muestran los números del 1 al 6 para seleccionar
      for (int i = 1; i <= 6; i++) {
        expect(find.text('$i'), findsWidgets);
      }
    });

    testWidgets(
      'Asigna números a las 6 estrellas y navega a la pantalla de juego',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const MaterialApp(home: PantallaMenuMapas()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Mapa 1'));
        await tester.pumpAndSettle();

        // Buscar los iconos de estrella en la cuadrícula
        final estrellasFinder = find.byIcon(Icons.star);
        expect(estrellasFinder, findsNWidgets(6));

        // Asignar los valores del 1 al 6 a cada estrella secuencialmente
        for (int num = 1; num <= 6; num++) {
          // Seleccionar el chip del número
          final chipNumero = find.widgetWithText(ChoiceChip, '$num');
          await tester.tap(chipNumero);
          await tester.pumpAndSettle();

          // Tocar la primera estrella vacía disponible
          await tester.tap(estrellasFinder.first);
          await tester.pumpAndSettle();
        }

        // Tocar el botón de INICIO para comenzar la partida
        final botonInicio = find.text('INICIO');
        await tester.tap(botonInicio);
        await tester.pumpAndSettle();

        // Verificar la transición exitosa a PantallaJuegoTurno
        expect(find.text('Brilliant - Partida'), findsOneWidget);
        expect(find.text('Puntuación:'), findsOneWidget);
        expect(find.text('Lanzar 2 Dados'), findsOneWidget);
      },
    );

    testWidgets(
      'Simula el lanzamiento de dados y la interacción en la pantalla de juego',
      (WidgetTester tester) async {
        // Inicializar directamente en PantallaJuegoTurno
        final tablero = Tablero(
          alto: 7,
          ancho: 7,
          celdas: [
            Celda(columna: 0, fila: 0, region: Region.amarillo, valor: 3),
            Celda(columna: 0, fila: 1, region: Region.verdeNoroeste),
          ],
          zonas: [
            Zona(region: Region.amarillo, tipo: TipoAmarillo()),
            Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(home: PantallaJuegoTurno(tablero: tablero)),
        );
        await tester.pumpAndSettle();

        // Presionar el botón de lanzar dados
        final botonDados = find.byIcon(Icons.casino);
        expect(botonDados, findsOneWidget);

        await tester.ensureVisible(botonDados);
        await tester.pumpAndSettle();

        await tester.tap(botonDados);
        await tester.pumpAndSettle();

        // Verificar que aparezcan los chips de los dados
        expect(find.byType(ChoiceChip), findsNWidgets(2));
      },
    );

    testWidgets('Muestra el marcador dinámico con jugadores y meta de puntos', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [
          Celda(columna: 0, fila: 0, region: Region.amarillo, valor: 3),
          Celda(columna: 0, fila: 1, region: Region.verdeNoroeste),
        ],
        zonas: [
          Zona(region: Region.amarillo, tipo: TipoAmarillo()),
          Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
        ],
      );

      const jugadores = [
        JugadorPartida(
          idSocket: 'socket-ana',
          idUsuario: 1,
          usuario: 'Ana',
          puntuacion: 12,
        ),
        JugadorPartida(
          idSocket: 'socket-luis',
          idUsuario: 2,
          usuario: 'Luis',
          puntuacion: 7,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: PantallaJuegoTurno(
            tablero: tablero,
            jugadores: jugadores,
            puntosParaGanar: 20,
            tuIdSocket: 'socket-ana',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Marcador'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Luis'), findsOneWidget);
      expect(find.text('12 pts'), findsOneWidget);
      expect(find.text('7 pts'), findsOneWidget);
      expect(find.text('Meta: 20 pts'), findsOneWidget);
    });

    testWidgets('mantiene el tamaño del tablero al lanzar los dados', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [
          Celda(columna: 0, fila: 0, region: Region.amarillo, valor: 3),
          Celda(columna: 0, fila: 1, region: Region.verdeNoroeste),
        ],
        zonas: [
          Zona(region: Region.amarillo, tipo: TipoAmarillo()),
          Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: PantallaJuegoTurno(tablero: tablero)),
      );
      await tester.pumpAndSettle();

      final tableroFinder = find.byKey(const Key('tablero-juego'));
      final Size tamanoInicial = tester.getSize(tableroFinder);

      await tester.tap(find.text('Lanzar 2 Dados'));
      await tester.pumpAndSettle();

      expect(tester.getSize(tableroFinder), tamanoInicial);
    });

    testWidgets('resume el progreso de los bloques por tipo de región', (
      WidgetTester tester,
    ) async {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [
          Celda(columna: 0, fila: 0, region: Region.azulNorte, valor: 3),
          Celda(columna: 1, fila: 0, region: Region.azulNorte, valor: 3),
          Celda(columna: 2, fila: 0, region: Region.verdeNoroeste, valor: 1),
          Celda(columna: 3, fila: 0, region: Region.verdeNoroeste),
        ],
        zonas: [
          Zona(region: Region.azulNorte, tipo: TipoAzul()),
          Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: PantallaJuegoTurno(tablero: tablero)),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('leyenda-tipo-azul')),
          matching: find.text('Bloques 1/1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('leyenda-tipo-verde')),
          matching: find.text('Bloques 0/1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('leyenda-tipo-azul')),
          matching: find.text('='),
        ),
        findsOneWidget,
      );
    });

    testWidgets('muestra confirmación y vuelve al menú al rendirse', (
      WidgetTester tester,
    ) async {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [Celda(columna: 0, fila: 0, region: Region.amarillo, valor: 3)],
        zonas: [Zona(region: Region.amarillo, tipo: TipoAmarillo())],
      );

      await tester.pumpWidget(
        MaterialApp(home: PantallaJuegoTurno(tablero: tablero)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rendirse'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar rendición'), findsOneWidget);
      expect(
        find.text(
          '¿Estás seguro de que deseas rendirte? Perderás la partida actual.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Confirmar Rendición'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Te has rendido'), findsNothing);

      await tester.tap(find.text('Rendirse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar Rendición'));
      await tester.pumpAndSettle();

      expect(find.text('Te has rendido'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Selecciona un mapa'), findsOneWidget);
    });

    testWidgets('muestra controles de ronda solo para el anfitrión', (
      WidgetTester tester,
    ) async {
      final tablero = Tablero(
        alto: 7,
        ancho: 7,
        celdas: [Celda(columna: 0, fila: 0, region: Region.amarillo, valor: 3)],
        zonas: [Zona(region: Region.amarillo, tipo: TipoAmarillo())],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PantallaJuegoTurno(
            key: const ValueKey('host'),
            tablero: tablero,
            codigoSala: 'ABC123',
            tuIdSocket: 'socket-ana',
            anfitrion: 'socket-ana',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('boton-lanzar-dados')), findsOneWidget);
      expect(find.byKey(const Key('boton-saltar-turno')), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: PantallaJuegoTurno(
            key: const ValueKey('guest'),
            tablero: tablero,
            codigoSala: 'ABC123',
            tuIdSocket: 'socket-luis',
            anfitrion: 'socket-ana',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('boton-lanzar-dados')), findsNothing);
      expect(
        find.text('Esperando lanzamiento del anfitrión...'),
        findsOneWidget,
      );
    });
  });
}
