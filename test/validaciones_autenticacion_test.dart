import 'package:flutter_test/flutter_test.dart';
import 'package:jueguitof/caracteristicas/autenticacion/dominio/validaciones_autenticacion.dart';

void main() {
  group('normalizarNombreUsuario', () {
    test('elimina espacios al inicio y al final', () {
      expect(normalizarNombreUsuario('  gael_pl  '), 'gael_pl');
    });

    test('devuelve cadena vacía para valores nulos', () {
      expect(normalizarNombreUsuario(null), '');
    });
  });

  group('validarNombreUsuario', () {
    test('acepta usuarios válidos', () {
      expect(validarNombreUsuario('gael_pl'), isNull);
      expect(validarNombreUsuario('  gael.pl-2026  '), isNull);
    });

    test('rechaza usuarios vacíos', () {
      expect(
        validarNombreUsuario('   ', mensajeVacio: 'Ingresa un nombre'),
        'Ingresa un nombre',
      );
    });

    test('rechaza usuarios demasiado cortos o largos', () {
      expect(validarNombreUsuario('ab'), 'Debe tener entre 3 y 30 caracteres');
      expect(
        validarNombreUsuario('a' * 31),
        'Debe tener entre 3 y 30 caracteres',
      );
    });

    test('rechaza caracteres no permitidos', () {
      expect(
        validarNombreUsuario('gael pl'),
        'Usa solo letras, números, puntos, guiones o guiones bajos',
      );
      expect(
        validarNombreUsuario('gael@pl'),
        'Usa solo letras, números, puntos, guiones o guiones bajos',
      );
    });
  });
}
