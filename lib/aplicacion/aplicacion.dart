import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../caracteristicas/autenticacion/datos/servicios/servicio_autenticacion.dart';
import '../caracteristicas/autenticacion/presentacion/pantallas/pantalla_login.dart';
import '../caracteristicas/juego/presentacion/pantallas/pantalla_menu_mapas.dart';

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});

  // Verifica el token local y, si es posible, lo valida contra el servidor.
  Future<bool> _verificarSesionActiva() async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    final String? token = preferencias.getString(
      ServicioAutenticacion.claveToken,
    );

    if (token == null || token.isEmpty) return false;

    final String estado = await ServicioAutenticacion().validarSesion();

    // Si Render está despertando o no hay red, conservamos la sesión local
    // para no expulsar al usuario; el socket la validará al conectarse.
    return estado == 'activa' || estado == 'sinConexion';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant - Juego',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _verificarSesionActiva(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final bool sesionActiva = snapshot.data ?? false;

          if (sesionActiva) {
            return const PantallaMenuMapas();
          } else {
            return const PantallaLogin();
          }
        },
      ),
    );
  }
}
