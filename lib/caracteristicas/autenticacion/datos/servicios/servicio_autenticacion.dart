import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../nucleo/configuracion/entorno.dart';
import '../../dominio/validaciones_autenticacion.dart';

class ServicioAutenticacion {
  // La URL se define en `lib/nucleo/configuracion/entorno.dart` mediante
  // --dart-define=API_URL=... para alternar entre desarrollo y producción.
  static const String _urlBase = Entorno.apiUrl;
  static const String claveToken = 'token_jwt';
  static const Duration _timeout = Duration(seconds: 20);

  // Método para iniciar sesión (/login)
  Future<Map<String, dynamic>> iniciarSesion(
    String usuario,
    String contrasena,
  ) async {
    try {
      final String usuarioNormalizado = normalizarNombreUsuario(usuario);
      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'usuario': usuarioNormalizado,
              'contrasena': contrasena,
            }),
          )
          .timeout(_timeout);

      final datosRespuesta = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200) {
        final String token = datosRespuesta['token'];
        await _guardarTokenLocal(token);

        return {
          'exito': true,
          'mensaje': datosRespuesta['mensaje'] ?? 'Inicio de sesión exitoso',
        };
      } else {
        return {
          'exito': false,
          'mensaje': datosRespuesta['mensaje'] ?? 'Error al iniciar sesión',
        };
      }
    } on TimeoutException {
      return {
        'exito': false,
        'mensaje': 'El servidor está tardando en responder. Intenta nuevamente en unos segundos.',
      };
    } catch (error) {
      return {
        'exito': false,
        'mensaje': 'No se pudo conectar con el servidor. Verifica tu conexión.',
      };
    }
  }

  // Método para registrar un nuevo usuario (/register)
  Future<Map<String, dynamic>> registrarUsuario(
    String usuario,
    String contrasena,
  ) async {
    try {
      final String usuarioNormalizado = normalizarNombreUsuario(usuario);
      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'usuario': usuarioNormalizado,
              'contrasena': contrasena,
            }),
          )
          .timeout(_timeout);

      final datosRespuesta = jsonDecode(respuesta.body);

      // Los códigos comunes de éxito al crear recursos son 200 o 201
      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        final String? token = datosRespuesta['token']?.toString();

        if (token != null && token.isNotEmpty) {
          await _guardarTokenLocal(token);

          return {
            'exito': true,
            'sesionIniciada': true,
            'mensaje': datosRespuesta['mensaje'] ?? 'Registro exitoso',
          };
        }

        // Compatibilidad con servidores antiguos que no devolvían token.
        final resultadoLogin = await iniciarSesion(
          usuarioNormalizado,
          contrasena,
        );

        if (resultadoLogin['exito'] == true) {
          return {
            'exito': true,
            'sesionIniciada': true,
            'mensaje': datosRespuesta['mensaje'] ?? 'Registro exitoso',
          };
        }

        return {
          'exito': true,
          'sesionIniciada': false,
          'mensaje': 'Registro exitoso. Inicia sesión para continuar.',
        };
      } else {
        return {
          'exito': false,
          'mensaje': datosRespuesta['mensaje'] ?? 'Error al registrar usuario',
        };
      }
    } on TimeoutException {
      return {
        'exito': false,
        'mensaje': 'El servidor está tardando en responder. Intenta nuevamente en unos segundos.',
      };
    } catch (error) {
      return {
        'exito': false,
        'mensaje': 'No se pudo conectar con el servidor. Verifica tu conexión.',
      };
    }
  }

  Future<Map<String, dynamic>> eliminarCuenta() async {
    try {
      final String? token = await obtenerTokenLocal();
      if (token == null || token.isEmpty) {
        return {
          'exito': false,
          'sesionExpirada': true,
          'mensaje': 'Tu sesión expiró. Inicia sesión nuevamente.',
        };
      }

      final respuesta = await http
          .delete(
            Uri.parse('$_urlBase/account'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      final datosRespuesta = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200) {
        await cerrarSesion();

        return {
          'exito': true,
          'mensaje':
              datosRespuesta['mensaje'] ?? 'Cuenta eliminada correctamente',
        };
      }

      if (respuesta.statusCode == 401 || respuesta.statusCode == 403) {
        await cerrarSesion();

        return {
          'exito': false,
          'sesionExpirada': true,
          'mensaje': 'Tu sesión expiró. Inicia sesión nuevamente.',
        };
      }

      return {
        'exito': false,
        'mensaje': datosRespuesta['mensaje'] ?? 'Error al eliminar la cuenta',
      };
    } on TimeoutException {
      return {
        'exito': false,
        'mensaje': 'El servidor está tardando en responder. Intenta nuevamente en unos segundos.',
      };
    } catch (error) {
      return {
        'exito': false,
        'mensaje': 'No se pudo conectar con el servidor. Verifica tu conexión.',
      };
    }
  }

  /// Devuelve `activa`, `invalida`, `sinToken` o `sinConexion`.
  Future<String> validarSesion() async {
    final String? token = await obtenerTokenLocal();
    if (token == null || token.isEmpty) return 'sinToken';

    try {
      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/session'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      if (respuesta.statusCode == 200) return 'activa';

      if (respuesta.statusCode == 401 || respuesta.statusCode == 403) {
        await cerrarSesion();
        return 'invalida';
      }

      return 'sinConexion';
    } catch (error) {
      return 'sinConexion';
    }
  }

  Future<void> _guardarTokenLocal(String token) async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    await preferencias.setString(claveToken, token);
  }

  Future<String?> obtenerTokenLocal() async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    return preferencias.getString(claveToken);
  }

  Future<void> cerrarSesion() async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    await preferencias.remove(claveToken);
  }
}
