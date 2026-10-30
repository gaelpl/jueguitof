import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../nucleo/tema/colores_region.dart';
import '../../dominio/logica/juego_logica.dart';
import '../blocs/inicio_juego_bloc/inicio_juego_bloc.dart';
import 'pantalla_juego_turno.dart';

class PantallaSeleccionInicial extends StatefulWidget {
  final Tablero tablero;
  final int numeroMapa;

  const PantallaSeleccionInicial({
    super.key,
    required this.tablero,
    required this.numeroMapa,
  });

  @override
  State<PantallaSeleccionInicial> createState() =>
      _PantallaSeleccionInicialState();
}

class _PantallaSeleccionInicialState extends State<PantallaSeleccionInicial> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(widget.numeroMapa),
      create: (_) => InicioJuegoBloc(widget.tablero),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Brilliant - Mapa ${widget.numeroMapa}'),
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 16,
                            ),
                            child: Text(
                              'Asigna los números del 1 al 6 en las casillas estrella',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          AspectRatio(
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
                                      color: colorDeRegion(celda.region),
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
                                        if (celda.esEstrella &&
                                            celda.valor == null)
                                          const Icon(
                                            Icons.star,
                                            color: Colors.black87,
                                            size: 22,
                                          ),
                                        if (celda.valor != null &&
                                            celda.valor! > 0)
                                          Text(
                                            '${celda.valor}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  celda.region ==
                                                          Region.blanco ||
                                                      celda.region ==
                                                          Region.amarillo
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.grey[100],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(6, (i) {
                                int num = i + 1;
                                bool seleccionado =
                                    state.numeroSeleccionado == num;
                                return ChoiceChip(
                                  label: Text(
                                    '$num',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: seleccionado
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  selected: seleccionado,
                                  selectedColor: Theme.of(context)
                                      .colorScheme
                                      .primary,
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
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
