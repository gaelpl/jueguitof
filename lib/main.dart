import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'juego_logica.dart';
import 'mapas_oficiales.dart';
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
      home: const PantallaMenuMapas(),
    );
  }
}

class _OpcionMapa {
  final int numero;
  final String descripcion;

  const _OpcionMapa(this.numero, this.descripcion);
}

class PantallaMenuMapas extends StatelessWidget {
  const PantallaMenuMapas({super.key});

  static const List<_OpcionMapa> _opciones = [
    _OpcionMapa(1, 'Nivel 1'),
    _OpcionMapa(2, 'Nivel 2'),
    _OpcionMapa(3, 'Nivel 3'),
    _OpcionMapa(4, 'Nivel 4'),
  ];

  void _abrirMapa(BuildContext context, int numeroMapa) {
    final tablero = CreadorMapas.obtenerMapa(numeroMapa);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PantallaSeleccionInicial(tablero: tablero, numeroMapa: numeroMapa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brilliant - Mapas'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'SELECCIONA UN MAPA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige un nivel para configurar sus estrellas y comenzar la partida.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  for (final opcion in _opciones)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 1,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary,
                          foregroundColor: Colors.white,
                          child: Text(
                            '${opcion.numero}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          'Mapa ${opcion.numero}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(opcion.descripcion),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrirMapa(context, opcion.numero),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
  Color _obtenerColorRegion(Region region) {
    switch (region) {
      case Region.azulNorte:
      case Region.azulSureste:
        return const Color(0xFF2196F3);
      case Region.rojoNoroeste:
      case Region.rojoSureste:
      case Region.rojoNoreste:
      case Region.rojoSuroeste:
        return const Color(0xFFE53935);
      case Region.verdeNoroeste:
      case Region.verdeEste:
        return const Color(0xFF4CAF50);
      case Region.lilaNorte:
      case Region.lilaSuroeste:
      case Region.lilaSureste:
        return const Color(0xFF9C27B0);
      case Region.amarillo:
        return const Color(0xFFFFEB3B);
      case Region.blanco:
        return const Color(0xFFECEFF1);
      case Region.naranjaNorte:
      case Region.naranjaSur:
        return const Color(0xFFFF9800);
    }
  }

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

/// Pantalla Principal de Juego por Turnos
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
      case Region.rojoNoreste:
      case Region.rojoSuroeste:
        return const Color(0xFFE53935);
      case Region.verdeNoroeste:
      case Region.verdeEste:
        return const Color(0xFF4CAF50);
      case Region.lilaNorte:
      case Region.lilaSuroeste:
      case Region.lilaSureste:
        return const Color(0xFF9C27B0);
      case Region.amarillo:
        return const Color(0xFFFFEB3B);
      case Region.blanco:
        return const Color(0xFFECEFF1);
      case Region.naranjaNorte:
      case Region.naranjaSur:
        return const Color(0xFFFF9800);
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
                                                        Region.blanco ||
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
