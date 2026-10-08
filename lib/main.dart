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
      title: 'Brilliant - Juego',
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
        bool esEstrella =
            (columna == 2 && fila == 0) ||
            (columna == 5 && fila == 1) ||
            (columna == 1 && fila == 3) ||
            (columna == 4 && fila == 3) ||
            (columna == 2 && fila == 5) ||
            (columna == 4 && fila == 6);

        Region reg = _obtenerRegionMatrizCompleta(columna, fila);
        celdas.add(
          Celda(
            columna: columna,
            fila: fila,
            region: reg,
            esEstrella: esEstrella,
          ),
        );
      }
    }
    return Tablero(alto: 7, ancho: 7, celdas: celdas, zonas: zonas);
  }

  Region _obtenerRegionMatrizCompleta(int col, int fila) {
    if ((col == 0 && fila == 0) ||
        (col == 6 && fila == 0) ||
        (col == 3 && fila == 3) ||
        (col == 0 && fila == 6) ||
        (col == 6 && fila == 6)) {
      return Region.amarillo;
    }

    if ((col == 2 && fila == 0) ||
        (col == 2 && fila == 1) ||
        (col == 3 && fila == 1) ||
        (col == 3 && fila == 2)) {
      return Region.azulNorte;
    }

    if ((col == 3 && fila == 0) ||
        (col == 4 && fila == 0) ||
        (col == 4 && fila == 1) ||
        (col == 4 && fila == 2) ||
        (col == 5 && fila == 0) ||
        (col == 5 && fila == 1)) {
      return Region.lilaNorte;
    }

    if ((col == 1 && fila == 2) ||
        (col == 2 && fila == 2) ||
        (col == 1 && fila == 3) ||
        (col == 1 && fila == 4)) {
      return Region.rojoNoroeste;
    }

    if ((col == 3 && fila == 4) ||
        (col == 2 && fila == 3) ||
        (col == 2 && fila == 4) ||
        (col == 2 && fila == 5) ||
        (col == 1 && fila == 6) ||
        (col == 2 && fila == 6)) {
      return Region.lilaSuroeste;
    }

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

    if ((col == 6 && fila == 4) ||
        (col == 5 && fila == 5) ||
        (col == 6 && fila == 5) ||
        (col == 5 && fila == 6)) {
      return Region.azulSureste;
    }

    if ((col == 5 && fila == 2) ||
        (col == 5 && fila == 3) ||
        (col == 6 && fila == 1) ||
        (col == 6 && fila == 2) ||
        (col == 6 && fila == 3)) {
      return Region.verdeEste;
    }

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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PantallaJuegoTurno(tablero: state.tablero),
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16,
                    ),
                    child: Text(
                      'Asigna los números del 1 al 6 en las casillas estrella',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

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
                            final celda = state.tablero.obtenerCeldaEn(
                              col,
                              fila,
                            );

                            if (celda == null) return const SizedBox();

                            return GestureDetector(
                              onTap: celda.esEstrella
                                  ? () {
                                      context.read<InicioJuegoBloc>().add(
                                        EventoColocarNumeroEnEstrella(
                                          col,
                                          fila,
                                        ),
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
                                      const Icon(
                                        Icons.star,
                                        color: Colors.black87,
                                        size: 22,
                                      ),
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
                            context.read<InicioJuegoBloc>().add(
                              EventoSeleccionarNumero(num),
                            );
                          },
                        );
                      }),
                    ),
                  ),

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
                                context.read<InicioJuegoBloc>().add(
                                  EventoConfirmarInicio(),
                                );
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

/// Pantalla Principal de Juego por Turnos (Adaptada a 2 Dados)
class PantallaJuegoTurno extends StatelessWidget {
  final Tablero tablero;

  const PantallaJuegoTurno({super.key, required this.tablero});

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
      create: (_) => JuegoTurnoBloc(tablero),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Brilliant - Partida'),
          centerTitle: true,
        ),
        body: BlocBuilder<JuegoTurnoBloc, JuegoTurnoEstado>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // Marcador de Puntuación
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Puntuación:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.puntuacionTotal} pts',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cuadrícula del Tablero
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
                            final celda = state.tablero.obtenerCeldaEn(
                              col,
                              fila,
                            );

                            if (celda == null) return const SizedBox();

                            final bool esAncla = state.celdaAncla == celda;
                            final bool esObjetivoValido = state
                                .celdasObjetivoValidas
                                .contains(celda);

                            return GestureDetector(
                              onTap: () {
                                if (celda.valor != null) {
                                  // Selecciona como Ancla en el tablero
                                  context.read<JuegoTurnoBloc>().add(
                                    EventoSeleccionarAnclaTablero(celda),
                                  );
                                } else if (esObjetivoValido) {
                                  // Coloca el Dado en la posición objetivo
                                  context.read<JuegoTurnoBloc>().add(
                                    EventoColocarNumeroEnObjetivo(celda),
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: esObjetivoValido
                                      ? Colors.amberAccent
                                      : _obtenerColorRegion(celda.region),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: esAncla
                                        ? Colors.white
                                        : (esObjetivoValido
                                              ? Colors.amber.shade900
                                              : Colors.black26),
                                    width: esAncla
                                        ? 3.5
                                        : (esObjetivoValido ? 3 : 1),
                                  ),
                                  boxShadow: esObjetivoValido
                                      ? [
                                          BoxShadow(
                                            color: Colors.amber.withOpacity(
                                              0.8,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: celda.valor != null
                                      ? Text(
                                          '${celda.valor}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                celda.region == Region.amarillo
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        )
                                      : (esObjetivoValido
                                            ? const Icon(
                                                Icons.add_circle,
                                                color: Colors.black87,
                                                size: 22,
                                              )
                                            : null),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Área de Selección de Dados y Botón de Lanzamiento
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    color: Colors.grey.shade100,
                    child: Column(
                      children: [
                        if (state.dado1 != null && state.dado2 != null) ...[
                          const Text(
                            'Selecciona cuál dado usarás como ANCLA:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildChipDado(
                                context: context,
                                label: 'Dado 1: ${state.dado1!.valor}',
                                esAncla: state.indiceDadoAncla == 0,
                                onTap: () => context.read<JuegoTurnoBloc>().add(
                                  EventoSeleccionarDadoAncla(0),
                                ),
                              ),
                              const SizedBox(width: 16),
                              _buildChipDado(
                                context: context,
                                label: 'Dado 2: ${state.dado2!.valor}',
                                esAncla: state.indiceDadoAncla == 1,
                                onTap: () => context.read<JuegoTurnoBloc>().add(
                                  EventoSeleccionarDadoAncla(1),
                                ),
                              ),
                            ],
                          ),
                          if (state.dadoColocar != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Valor a colocar alrededor del ancla: ${state.dadoColocar!.valor}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                        ],

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            context.read<JuegoTurnoBloc>().add(
                              EventoLanzarDados(),
                            );
                          },
                          icon: const Icon(Icons.casino),
                          label: const Text(
                            'Lanzar 2 Dados',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
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

  Widget _buildChipDado({
    required BuildContext context,
    required String label,
    required bool esAncla,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: esAncla ? Colors.white : Colors.black87,
        ),
      ),
      selected: esAncla,
      selectedColor: Theme.of(context).colorScheme.primary,
      onSelected: (_) => onTap(),
    );
  }
}
