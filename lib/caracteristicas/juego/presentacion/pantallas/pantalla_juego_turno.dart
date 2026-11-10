import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../nucleo/tema/colores_region.dart';
import '../../datos/servicios/servicio_socket.dart';
import '../../dominio/entidades/jugador_partida.dart';
import '../../dominio/logica/juego_logica.dart';
import '../blocs/juego_turno_bloc/juego_turno_bloc.dart';
import 'pantalla_menu_mapas.dart';

/// Pantalla Principal de Juego por Turnos
class PantallaJuegoTurno extends StatefulWidget {
  final Tablero tablero;
  final String? codigoSala;
  final List<JugadorPartida> jugadores;
  final int? puntosParaGanar;
  final String? tuIdSocket;
  final String? anfitrion;

  const PantallaJuegoTurno({
    super.key,
    required this.tablero,
    this.codigoSala,
    this.jugadores = const [],
    this.puntosParaGanar,
    this.tuIdSocket,
    this.anfitrion,
  });

  @override
  State<PantallaJuegoTurno> createState() => _PantallaJuegoTurnoState();
}

class _PantallaJuegoTurnoState extends State<PantallaJuegoTurno> {
  late final StreamSubscription<bool> _suscripcionConexion;
  bool _conexionInestable = false;

  @override
  void initState() {
    super.initState();
    _conexionInestable = ServicioSocket.instancia.conexionInestableActual;
    _suscripcionConexion = ServicioSocket.instancia.conexionInestable.listen((
      inestable,
    ) {
      if (!mounted) return;
      setState(() => _conexionInestable = inestable);
    });
  }

  @override
  void dispose() {
    _suscripcionConexion.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JuegoTurnoBloc(
        widget.tablero,
        codigoSala: widget.codigoSala,
        jugadores: widget.jugadores,
        puntosParaGanar: widget.puntosParaGanar,
        tuIdSocket: widget.tuIdSocket,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Brilliant - Partida'),
          centerTitle: true,
        ),
        body: BlocConsumer<JuegoTurnoBloc, JuegoTurnoEstado>(
          listener: (context, state) {
            if (state is JuegoGanadoPorAbandono) {
              _mostrarDialogoVictoria(context);
            }
            if (state is JuegoCanceladoDesconexion) {
              _mostrarDialogoDesconexion(context);
            }
            if (state is JuegoFinalizadoPorPuntos) {
              _mostrarDialogoVictoriaPorPuntos(context, state);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  if (_conexionInestable) _construirBannerConexion(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final deslizamiento = Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: deslizamiento,
                          child: child,
                        ),
                      );
                    },
                    child: state.mensajeAyuda == null
                        ? const SizedBox.shrink(
                            key: ValueKey('sin-mensaje-ayuda'),
                          )
                        : _construirBannerAyuda(state.mensajeAyuda!),
                  ),
                  _construirMarcador(context, state),

                  Expanded(
                    child: AbsorbPointer(
                      absorbing: _conexionInestable,
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
                                  } else {
                                    context.read<JuegoTurnoBloc>().add(
                                      EventoMovimientoInvalido(celda),
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
                          onPressed: _conexionInestable
                              ? null
                              : () {
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
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _conexionInestable
                              ? null
                              : () {
                                  context.read<JuegoTurnoBloc>().add(
                                    EventoRendirse(),
                                  );
                                },
                          icon: const Icon(Icons.flag),
                          label: const Text(
                            'Rendirse',
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

  Widget _construirMarcador(BuildContext context, JuegoTurnoEstado state) {
    if (state.jugadores.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      );
    }

    final String? tuIdSocket = state.tuIdSocket ?? widget.tuIdSocket;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Marcador',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (state.puntosParaGanar != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    'Meta: ${state.puntosParaGanar} pts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final JugadorPartida jugador in state.jugadores)
                  _construirTarjetaJugador(
                    jugador,
                    jugador.idSocket == tuIdSocket,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaJugador(JugadorPartida jugador, bool esLocal) {
    return Container(
      width: 132,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: esLocal ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esLocal ? Colors.blue.shade300 : Colors.grey.shade300,
          width: esLocal ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  jugador.usuario,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: esLocal ? FontWeight.w800 : FontWeight.w600,
                    color: esLocal ? Colors.blue.shade900 : Colors.black87,
                  ),
                ),
              ),
              if (esLocal)
                Icon(
                  Icons.person_rounded,
                  size: 14,
                  color: Colors.blue.shade700,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${jugador.puntuacion} pts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: esLocal ? Colors.blue.shade900 : Colors.indigo.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBannerConexion() {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Conexión inestable. Reconectando...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBannerAyuda(String mensaje) {
    return Container(
      key: ValueKey(mensaje),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC7D2FE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF4338CA),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Color(0xFF312E81),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoVictoriaPorPuntos(
    BuildContext context,
    JuegoFinalizadoPorPuntos estado,
  ) {
    final String titulo = estado.esGanadorLocal
        ? '¡Has ganado!'
        : 'Partida finalizada';
    final String contenido = estado.esGanadorLocal
        ? 'Alcanzaste la meta de ${estado.puntosParaGanar} puntos.'
        : '${estado.ganadorUsuario ?? "Un jugador"} alcanzó la meta de ${estado.puntosParaGanar} puntos.';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(titulo),
        content: Text(contenido),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PantallaMenuMapas()),
                (route) => false,
              );
            },
            child: const Text('Volver al menú de mapas'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoDesconexion(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Partida cancelada'),
        content: const Text('La partida terminó. El rival perdió la conexión'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PantallaMenuMapas()),
                (route) => false,
              );
            },
            child: const Text('Volver al menú de mapas'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoVictoria(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¡Has ganado!'),
        content: const Text('Tu oponente se ha rendido'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PantallaMenuMapas()),
                (route) => false,
              );
            },
            child: const Text('Volver al menú de mapas'),
          ),
        ],
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
      onSelected: _conexionInestable ? null : (_) => onTap(),
    );
  }
}
