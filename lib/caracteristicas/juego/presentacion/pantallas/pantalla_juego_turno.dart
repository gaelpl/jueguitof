import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../nucleo/tema/colores_region.dart';
import '../../dominio/logica/juego_logica.dart';
import '../blocs/juego_turno_bloc/juego_turno_bloc.dart';

/// Pantalla Principal de Juego por Turnos
class PantallaJuegoTurno extends StatelessWidget {
  final Tablero tablero;

  const PantallaJuegoTurno({super.key, required this.tablero});

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
                                  context.read<JuegoTurnoBloc>().add(
                                    EventoSeleccionarAnclaTablero(celda),
                                  );
                                } else if (esObjetivoValido) {
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
                                      : colorDeRegion(celda.region),
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
                                            color: Colors.amber.withValues(
                                              alpha: 0.8,
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
                                                celda.region ==
                                                        Region.amarillo ||
                                                    celda.region ==
                                                        Region.blanco
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
                                valorDado: state.dado1!.valor,
                                esAncla: state.indiceDadoAncla == 0,
                                onTap: () => context.read<JuegoTurnoBloc>().add(
                                  EventoSeleccionarDadoAncla(0),
                                ),
                              ),
                              const SizedBox(width: 16),
                              _buildChipDado(
                                context: context,
                                valorDado: state.dado2!.valor,
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
    required int valorDado,
    required bool esAncla,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      label: Text(
        '$valorDado',
        style: TextStyle(
          fontSize: 18,
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
