import 'package:flutter/material.dart';
import 'juego_logica.dart'; // Importa tu lógica intacta

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant Board Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // Creamos una muestra de zonas utilizando tus clases
  final List<Zona> zonasDelJuego = [
    Zona(region: Region.azulNorte, tipo: TipoAzul()),
    Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
    Zona(region: Region.rojoNoroeste, tipo: TipoRojoAmarillo()),
    Zona(region: Region.lilaNorte, tipo: TipoMorado()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brilliant - Reglas y Zonas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: zonasDelJuego.length,
          itemBuilder: (context, index) {
            final zona = zonasDelJuego[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: zona.tipo.color,
                  child: const Icon(Icons.palette, color: Colors.white),
                ),
                title: Text(
                  zona.region.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(zona.tipo.descripcion),
                trailing: Text(
                  'Puntuación máx: ${zona.tipo.puntuaciones[1]} pts',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}