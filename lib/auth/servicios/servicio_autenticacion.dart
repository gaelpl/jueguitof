import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServicioAutenticacion {
  // Nota: Si usas el emulador de Android, usa 'http://10.0.2.2:3000'. 
  // Si pruebas en Windows/Web o dispositivo físico en la misma red, usa la IP de tu PC o 'http://localhost:3000'.
  static const String _urlBase = 'http://10.0.2.2:3000';

  // Método para iniciar sesión
Future<Map<String, dynamic>> iniciarSesion(String correo, String contrasena) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_urlBase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
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

  // Método privado para guardar el token con SharedPreferences
  Future<void> _guardarTokenLocal(String token) async {
    final SharedPreferences preferencias = await SharedPreferences.getInstance();
    await preferencias.setString('token_jwt', token);
  }

  // Método para obtener el token guardado (útil para peticiones futuras en el juego)
  Future<String?> obtenerTokenLocal() async {
    final SharedPreferences preferencias = await SharedPreferences.getInstance();
    return preferencias.getString('token_jwt');
  }

  // Método para cerrar sesión (borrar el token)
  Future<void> cerrarSesion() async {
    final SharedPreferences preferencias = await SharedPreferences.getInstance();
    await preferencias.remove('token_jwt');
  }
}