import 'package:flutter_test/flutter_test.dart';
import 'package:jueguitof/caracteristicas/juego/dominio/entidades/modo_partida.dart';
import 'package:jueguitof/caracteristicas/ranked/dominio/entidades/clasificacion.dart';
import 'package:jueguitof/caracteristicas/ranked/dominio/entidades/jugador_clasificacion.dart';
import 'package:jueguitof/caracteristicas/ranked/dominio/entidades/resumen_partida.dart';
import 'package:jueguitof/caracteristicas/ranked/dominio/rangos.dart';

void main() {
  group('rangos ranked', () {
    test('asigna la liga según los límites de RP', () {
      expect(obtenerLiga(0).nombre, 'Bronce');
      expect(obtenerLiga(199).nombre, 'Bronce');
      expect(obtenerLiga(200).nombre, 'Plata');
      expect(obtenerLiga(399).nombre, 'Plata');
      expect(obtenerLiga(400).nombre, 'Oro');
      expect(obtenerLiga(599).nombre, 'Oro');
      expect(obtenerLiga(600).nombre, 'Platino');
      expect(obtenerLiga(799).nombre, 'Platino');
      expect(obtenerLiga(800).nombre, 'Diamante');
      expect(obtenerLiga(-10).nombre, 'Bronce');
    });

    test('calcula división y progreso dentro de cada liga', () {
      expect(obtenerDivision(0), 'IV');
      expect(obtenerDivision(50), 'III');
      expect(obtenerDivision(100), 'II');
      expect(obtenerDivision(150), 'I');
      expect(obtenerDivision(199), 'I');
      expect(obtenerDivision(200), 'IV');
      expect(obtenerDivision(800), 'IV');

      final progreso = obtenerProgresoLiga(100);
      expect(progreso.liga.nombre, 'Bronce');
      expect(progreso.progreso, 0.5);
      expect(progreso.rpRestante, 100);

      final diamante = obtenerProgresoLiga(1000);
      expect(diamante.progreso, 1.0);
      expect(diamante.rpRestante, 0);
    });
  });

  group('entidades ranked', () {
    test('parsea una entrada de clasificación', () {
      final jugador = JugadorClasificacion.desdeJson({
        'posicion': '1',
        'idUsuario': '7',
        'usuario': 'Ana',
        'liga': 'Plata',
        'division': 'III',
        'rp': '250',
        'victorias': 4,
        'partidas': 10,
      });

      expect(jugador.posicion, 1);
      expect(jugador.idUsuario, 7);
      expect(jugador.rp, 250);
      expect(jugador.derrotas, 6);
      expect(jugador.inicial, 'A');
    });

    test('parsea la respuesta de clasificación con el usuario actual', () {
      final respuesta = ClasificacionRespuesta.desdeJson({
        'estado': 'exito',
        'total': 23,
        'entradas': [
          {
            'posicion': 1,
            'idUsuario': 7,
            'usuario': 'Ana',
            'liga': 'Plata',
            'division': 'III',
            'rp': 250,
            'victorias': 4,
            'partidas': 10,
          },
        ],
        'usuarioActual': {
          'posicion': 23,
          'idUsuario': 9,
          'usuario': 'Luis',
          'liga': 'Bronce',
          'division': 'IV',
          'rp': 10,
          'victorias': 0,
          'partidas': 1,
        },
      });

      expect(respuesta.total, 23);
      expect(respuesta.entradas, hasLength(1));
      expect(respuesta.usuarioActual?.usuario, 'Luis');
      expect(respuesta.usuarioActual?.posicion, 23);
    });

    test('parsea el resumen ranked emitido por el servidor', () {
      final resumen = ResumenPartida.desdeJson({
        'idPartida': 'partida-1',
        'codigo': 'ABC123',
        'motivoFin': 'puntos',
        'puesto': 1,
        'posicionDesde': 1,
        'posicionHasta': 1,
        'puntuacion': 62,
        'rpAntes': 190,
        'rpDelta': 25,
        'rpDespues': 215,
        'ligaAntes': 'Bronce',
        'ligaDespues': 'Plata',
        'cambioLiga': true,
        'clasificacion': [
          {
            'idUsuario': 7,
            'usuario': 'Ana',
            'puesto': 1,
            'puntuacion': 62,
            'rpDelta': 25,
            'liga': 'Plata',
          },
        ],
      });

      expect(resumen.rpAntes, 190);
      expect(resumen.rpDespues, 215);
      expect(resumen.cambioLiga, isTrue);
      expect(resumen.clasificacion, hasLength(1));
      expect(resumen.tituloResultado, '¡Victoria!');
    });

    test('normaliza el modo de partida', () {
      expect(ModoPartida.desdeNombre('ranked'), ModoPartida.ranked);
      expect(ModoPartida.desdeNombre('casual'), ModoPartida.casual);
      expect(ModoPartida.desdeNombre(null), ModoPartida.casual);
      expect(ModoPartida.ranked.nombre, 'ranked');
    });
  });
}
