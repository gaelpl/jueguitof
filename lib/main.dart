import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'juego_logica.dart';
import 'inicio_juego_bloc/inicio_juego_bloc.dart';

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant - Selección Inicial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PantallaSeleccionInicial(),
    );
  }
}

class PantallaSeleccionInicial extends StatefulWidget {
  const PantallaSeleccionInicial({super.key});

  @override
  State<PantallaSeleccionInicial> createState() =>
      _PantallaSeleccionInicialState();
}

class _PantallaSeleccionInicialState extends State<PantallaSeleccionInicial> {
  late Tablero tablero;

  @override
  void initState() {
    super.initState();
    tablero = _construirTableroMapa1();
  }

  Tablero _construirTableroMapa1() {
    final zonas = [
      Zona(region: Region.azulNorte, tipo: TipoAzul()),
      Zona(region: Region.rojoNoroeste, tipo: TipoRojoAmarillo()),
      Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
      Zona(region: Region.lilaNorte, tipo: TipoMorado()),
      Zona(region: Region.amarillo, tipo: TipoRojoAmarillo()),
      Zona(region: Region.lilaSuroeste, tipo: TipoMorado()),
      Zona(region: Region.rojoSureste, tipo: TipoRojoAmarillo()),
      Zona(region: Region.verdeEste, tipo: TipoVerde()),
      Zona(region: Region.azulSureste, tipo: TipoAzul()),
    ];

    List<Celda> celdas = [];
    for (int fila = 0; fila < 7; fila++) {
      for (int columna = 0; columna < 7; columna++) {
        bool esEstrella = (columna == 2 && fila == 0) ||
            (columna == 6 && fila == 1) ||
            (columna == 1 && fila == 3) ||
            (columna == 4 && fila == 3) ||
            (columna == 2 && fila == 5) ||
            (columna == 5 && fila == 6);

        Region reg = _obtenerRegion(columna, fila);
        celdas.add(Celda(
          columna: columna,
          fila: fila,
          region: reg,
          esEstrella: esEstrella,
        ));
      }
    }
    return Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
  }

  Region _obtenerRegion(int col, int fila) {
    if (col == 2 && fila == 0) return Region.azulNorte;
    if (col == 6 && fila == 1) return Region.lilaNorte;
    if (col == 1 && fila == 3) return Region.rojoNoroeste;
    if (col == 4 && fila == 3) return Region.verdeNoroeste;
    if (col == 2 && fila == 5) return Region.lilaSuroeste;
    if (col == 5 && fila == 6) return Region.rojoSureste;
    return Region.verdeNoroeste;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InicioJuegoBloc(tablero),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Brilliant - Selección Inicial'),
          centerTitle: true,
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Estructura base de la interfaz inicial cargada'),
          ),
        ),
      ),
    );
  }
}