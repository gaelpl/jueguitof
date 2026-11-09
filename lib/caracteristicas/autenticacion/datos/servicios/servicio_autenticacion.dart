import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/validaciones_autenticacion.dart';

class ServicioAutenticacion {
  // Nota: Para Flutter Web y escritorio usa 'http://localhost:3000'.
  // Si usas el emulador de Android, cambia el valor a 'http://10.0.2.2:3000'.
  static const String _urlBase = 'http://localhost:3000';

  // Método para iniciar sesión (/login)
  Future<Map<String, dynamic>> iniciarSesion(
    String usuario,
    String contrasena,
  ) async {
    try {
      final String usuarioNormalizado = normalizarNombreUsuario(usuario);
      final respuesta = await http.post(
        Uri.parse('$_urlBase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario': usuarioNormalizado,
          'contrasena': contrasena,
        }),
      );

      final datosRespuesta = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200) {
        // Guardar el token JWT de forma local
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
      final respuesta = await http.post(
        Uri.parse('$_urlBase/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario': usuarioNormalizado,
          'contrasena': contrasena,
        }),
      );

      final datosRespuesta = jsonDecode(respuesta.body);

      // Los códigos comunes de éxito al crear recursos son 200 o 201
      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        // Si el backend devuelve un token automáticamente al registrarse, lo guardamos
        if (datosRespuesta['token'] != null) {
          await _guardarTokenLocal(datosRespuesta['token']);
        }

        return {
          'exito': true,
          'mensaje': datosRespuesta['mensaje'] ?? 'Registro exitoso',
        };
      } else {
        return {
          'exito': false,
          'mensaje': datosRespuesta['mensaje'] ?? 'Error al registrar usuario',
        };
      }
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
      if (token == null) {
        return {'exito': false, 'mensaje': 'No hay una sesión activa.'};
      }

      final respuesta = await http.delete(
        Uri.parse('$_urlBase/account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final datosRespuesta = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200) {
        // Limpiamos el token local tras borrar la cuenta exitosamente
        await cerrarSesion();

        return {
          'exito': true,
          'mensaje':
              datosRespuesta['mensaje'] ?? 'Cuenta eliminada correctamente',
        };
      } else {
        return {
          'exito': false,
          'mensaje': datosRespuesta['mensaje'] ?? 'Error al eliminar la cuenta',
        };
      }
    } catch (error) {
      return {
        'exito': false,
        'mensaje': 'No se pudo conectar con el servidor. Verifica tu conexión.',
      };
    }
  }

  // Método privado para guardar el token con SharedPreferences
  Future<void> _guardarTokenLocal(String token) async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    await preferencias.setString('token_jwt', token);
  }

  // Método para obtener el token guardado (útil para peticiones futuras en el juego)
  Future<String?> obtenerTokenLocal() async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    return preferencias.getString('token_jwt');
  }

  // Método para cerrar sesión (borrar el token)
  Future<void> cerrarSesion() async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    await preferencias.remove('token_jwt');
  }
}
