import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../autenticacion/datos/servicios/servicio_autenticacion.dart';
import '../../../../nucleo/configuracion/entorno.dart';
import '../../dominio/entidades/clasificacion.dart';

class ServicioRanked {
  static const String _urlBase = Entorno.apiUrl;
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _cliente;
  final ServicioAutenticacion _servicioAutenticacion;

  ServicioRanked({
    http.Client? cliente,
    ServicioAutenticacion? servicioAutenticacion,
  }) : _cliente = cliente ?? http.Client(),
       _servicioAutenticacion =
           servicioAutenticacion ?? ServicioAutenticacion();

  Future<ClasificacionRespuesta> obtenerClasificacion({int limite = 10}) async {
    final Map<String, String> cabeceras = await _cabeceras();
    final Uri uri = Uri.parse('$_urlBase/clasificacion')
        .replace(queryParameters: {'limite': '$limite'});

    final http.Response respuesta = await _cliente
        .get(uri, headers: cabeceras)
        .timeout(_timeout);
    final Map<String, dynamic> datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200 || datos['estado'] != 'exito') {
      throw Exception(
        datos['mensaje']?.toString() ?? 'No se pudo cargar la clasificación.',
      );
    }

    return ClasificacionRespuesta.desdeJson(datos);
  }

  Future<PerfilRanked> obtenerPerfil() async {
    final Map<String, String> cabeceras = await _cabeceras(incluirToken: true);

    final http.Response respuesta = await _cliente
        .get(Uri.parse('$_urlBase/perfil'), headers: cabeceras)
        .timeout(_timeout);
    final Map<String, dynamic> datos = _decodificar(respuesta);

    if (respuesta.statusCode != 200 || datos['estado'] != 'exito') {
      throw Exception(
        datos['mensaje']?.toString() ?? 'No se pudo cargar tu perfil ranked.',
      );
    }

    return PerfilRanked.desdeJson(datos);
  }

  Future<Map<String, String>> _cabeceras({bool incluirToken = false}) async {
    final Map<String, String> cabeceras = {'Content-Type': 'application/json'};
    if (!incluirToken) return cabeceras;

    final String? token = await _servicioAutenticacion.obtenerTokenLocal();
    if (token != null && token.isNotEmpty) {
      cabeceras['Authorization'] = 'Bearer $token';
    }
    return cabeceras;
  }

  Map<String, dynamic> _decodificar(http.Response respuesta) {
    try {
      final dynamic datos = jsonDecode(respuesta.body);
      if (datos is Map) return Map<String, dynamic>.from(datos);
    } catch (_) {}
    throw Exception('El servidor devolvió una respuesta inesperada.');
  }
}
