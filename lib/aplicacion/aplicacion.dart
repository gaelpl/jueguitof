import 'package:flutter/material.dart';

import '../caracteristicas/autenticacion/presentacion/pantallas/pantalla_login.dart';

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant - Juego',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PantallaLogin(),
    );
  }
}
