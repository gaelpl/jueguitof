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
    tablero = _construirTableroMapa1Completo();
  }

  Tablero _construirTableroMapa1Completo() {
    final zonas = [
      Zona(region: Region.amarillo, tipo: TipoRojoAmarillo()),
      Zona(region: Region.azulNorte, tipo: TipoAzul()),
      Zona(region: Region.lilaNorte, tipo: TipoMorado()),
      Zona(region: Region.rojoNoroeste, tipo: TipoRojoAmarillo()),
      Zona(region: Region.verdeNoroeste, tipo: TipoVerde()),
      Zona(region: Region.verdeEste, tipo: TipoVerde()),
      Zona(region: Region.lilaSuroeste, tipo: TipoMorado()),
      Zona(region: Region.rojoSureste, tipo: TipoRojoAmarillo()),
      Zona(region: Region.azulSureste, tipo: TipoAzul()),
    ];

    List<Celda> celdas = [];
    for (int fila = 0; fila < 7; fila++) {
      for (int columna = 0; columna < 7; columna++) {
        bool esEstrella = (columna == 2 && fila == 0) ||
            (columna == 5 && fila == 1) ||
            (columna == 1 && fila == 3) ||
            (columna == 4 && fila == 3) ||
            (columna == 2 && fila == 5) ||
            (columna == 4 && fila == 6);

        Region reg = _obtenerRegionMatrizCompleta(columna, fila);
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

  Region _obtenerRegionMatrizCompleta(int col, int fila) {
    // Esquinas y centro Amarillo
    if ((col == 0 && fila == 0) ||
        (col == 6 && fila == 0) ||
        (col == 3 && fila == 3) ||
        (col == 0 && fila == 6) ||
        (col == 6 && fila == 6)) {
      return Region.amarillo;
    }

    // Bloque Azul Norte
    if ((col == 2 && fila == 0) ||
        (col == 2 && fila == 1) ||
        (col == 3 && fila == 1) ||
        (col == 3 && fila == 2)){
      return Region.azulNorte;
    }

    // Bloque Lila Norte
    if ((col == 3 && fila == 0) ||
        (col == 4 && fila == 0) ||
        (col == 4 && fila == 1) ||
        (col == 4 && fila == 2) ||
        (col == 5 && fila == 0) ||
        (col == 5 && fila == 1) ) {
      return Region.lilaNorte;
    }

    // Bloque Rojo Noroeste
    if ((col == 1 && fila == 2) ||
        (col == 2 && fila == 2) ||
        (col == 1 && fila == 3) ||
        (col == 1 && fila == 4) ) {
      return Region.rojoNoroeste;
    }

    // Bloque Lila Suroeste
    if ((col == 3 && fila == 4) ||
        (col == 2 && fila == 3) ||
        (col == 2 && fila == 4) ||
        (col == 2 && fila == 5) ||
        (col == 1 && fila == 6) ||
        (col == 2 && fila == 6)) {
      return Region.lilaSuroeste;
    }

    // Bloque Rojo Sureste
    if ((col == 0 && fila == 5) ||
        (col == 1 && fila == 5) ||
        (col == 4 && fila == 4) ||
        (col == 5 && fila == 4) ||
        (col == 3 && fila == 5) ||
        (col == 4 && fila == 5) ||
        (col == 3 && fila == 6) ||
        (col == 4 && fila == 6)) {
      return Region.rojoSureste;
    }

    // Bloque Azul Sureste
    if ((col == 6 && fila == 4) ||
        (col == 5 && fila == 5) ||
        (col == 6 && fila == 5) ||
        (col == 5 && fila == 6)) {
      return Region.azulSureste;
    }

    // Bloque Verde Este
    if ((col == 5 && fila == 2) ||
        (col == 5 && fila == 3) ||
        (col == 6 && fila == 1) ||
        (col == 6 && fila == 2) ||
        (col == 6 && fila == 3)) {
      return Region.verdeEste;
    }

    // Resto pertenece a Verde Noroeste
    return Region.verdeNoroeste;
  }

  Color _obtenerColorRegion(Region region) {
    switch (region) {
      case Region.azulNorte:
      case Region.azulSureste:
        return const Color(0xFF2196F3);
      case Region.rojoNoroeste:
      case Region.rojoSureste:
        return const Color(0xFFE53935);
      case Region.verdeNoroeste:
      case Region.verdeEste:
        return const Color(0xFF4CAF50);
      case Region.lilaNorte:
      case Region.lilaSuroeste:
        return const Color(0xFF9C27B0);
      case Region.amarillo:
        return const Color(0xFFFFEB3B);
    }
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
        body: BlocConsumer<InicioJuegoBloc, InicioJuegoEstado>(
          listener: (context, state) {
            if (state.juegoIniciado) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Partida Iniciada Correctamente!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                    child: Text(
                      'Asigna los números del 1 al 6 en las casillas estrella',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),

                  // Cuadrícula 7x7 con los colores exactos de cada región
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 3,
                            mainAxisSpacing: 3,
                          ),
                          itemCount: 49,
                          itemBuilder: (context, index) {
                            int col = index % 7;
                            int fila = index ~/ 7;
                            final celda =
                                state.tablero.obtenerCeldaEn(col, fila);

                            if (celda == null) return const SizedBox();

                            return GestureDetector(
                              onTap: celda.esEstrella
                                  ? () {
                                      context.read<InicioJuegoBloc>().add(
                                            EventoColocarNumeroEnEstrella(
                                                col, fila),
                                          );
                                    }
                                  : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _obtenerColorRegion(celda.region),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: celda.esEstrella
                                        ? Colors.black
                                        : Colors.white30,
                                    width: celda.esEstrella ? 2.5 : 1,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (celda.esEstrella && celda.valor == null)
                                      const Icon(Icons.star,
                                          color: Colors.black87, size: 22),
                                    if (celda.valor != null && celda.valor! > 0)
                                      Text(
                                        '${celda.valor}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Paleta de Selección de Números (1 al 6)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (i) {
                        int num = i + 1;
                        bool seleccionado = state.numeroSeleccionado == num;
                        return ChoiceChip(
                          label: Text(
                            '$num',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: seleccionado ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: seleccionado,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          onSelected: (_) {
                            context
                                .read<InicioJuegoBloc>()
                                .add(EventoSeleccionarNumero(num));
                          },
                        );
                      }),
                    ),
                  ),

                  // Botón "INICIO" Reactivo
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.estanListasEstrellas
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: state.estanListasEstrellas
                            ? () {
                                context
                                    .read<InicioJuegoBloc>()
                                    .add(EventoConfirmarInicio());
                              }
                            : null,
                        child: const Text(
                          'INICIO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}