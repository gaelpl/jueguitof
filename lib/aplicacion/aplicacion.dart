import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../caracteristicas/autenticacion/presentacion/pantallas/pantalla_login.dart';
import '../caracteristicas/juego/presentacion/pantallas/pantalla_menu_mapas.dart';

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});

  // Método para verificar si el token JWT existe localmente
  Future<bool> _verificarSesionActiva() async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();
    final String? token = preferencias.getString('token_jwt');
    return token != null && token.isNotEmpty;
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
          // Mostramos un indicador de carga mientras lee SharedPreferences
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Verificamos el resultado de la lectura del token
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
