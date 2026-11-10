import 'package:flutter_test/flutter_test.dart';
import 'package:jueguitof/caracteristicas/juego/dominio/entidades/jugador_partida.dart';

void main() {
  group('JugadorPartida', () {
    test('crea un jugador desde el JSON del servidor', () {
      final jugador = JugadorPartida.desdeJson({
        'socketId': 'socket-1',
        'idUsuario': 7,
        'usuario': 'Ana',
        'puntuacion': 12,
      });

      expect(jugador.socketId, 'socket-1');
      expect(jugador.idUsuario, 7);
      expect(jugador.usuario, 'Ana');
      expect(jugador.puntuacion, 12);
    });

    test('usa valores por defecto si faltan datos', () {
      final jugador = JugadorPartida.desdeJson({});

      expect(jugador.socketId, '');
      expect(jugador.idUsuario, 0);
      expect(jugador.usuario, 'Jugador');
      expect(jugador.puntuacion, 0);
    });

    test('copia el jugador actualizando solo su puntuación', () {
      const jugador = JugadorPartida(
        socketId: 'socket-1',
        idUsuario: 7,
        usuario: 'Ana',
        puntuacion: 4,
      );

      final actualizado = jugador.copyWith(puntuacion: 10);

      expect(actualizado.socketId, 'socket-1');
      expect(actualizado.usuario, 'Ana');
      expect(actualizado.puntuacion, 10);
      expect(jugador.puntuacion, 4);
    });
  });
}
