import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../nucleo/tema/colores_region.dart';
import '../../../autenticacion/datos/servicios/servicio_autenticacion.dart';
import '../../../autenticacion/presentacion/pantallas/pantalla_login.dart';
import '../../datos/servicios/servicio_socket.dart';
import '../../dominio/entidades/jugador_partida.dart';
import '../../dominio/logica/juego_logica.dart';
import '../blocs/juego_turno_bloc/juego_turno_bloc.dart';
import 'pantalla_menu_mapas.dart';
import 'pantalla_reglas.dart';

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
  late final StreamSubscription<bool> _suscripcionSesionInvalida;
  Timer? _temporizadorSalidaRendicion;
  bool _conexionInestable = false;
  bool _rendicionNotificada = false;
  bool _partidaTerminada = false;
  bool _dialogoRendicionAbierto = false;
  bool _sesionExpirada = false;

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
    _suscripcionSesionInvalida = ServicioSocket.instancia.sesionInvalida.listen(
      (_) => _manejarSesionExpirada(),
    );
  }

  Future<void> _manejarSesionExpirada() async {
    if (_sesionExpirada || !mounted) return;
    _sesionExpirada = true;

    await ServicioSocket.instancia.desconectar();
    await ServicioAutenticacion().cerrarSesion();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaLogin()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _temporizadorSalidaRendicion?.cancel();
    _suscripcionConexion.cancel();
    _suscripcionSesionInvalida.cancel();
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
        anfitrion: widget.anfitrion,
      ),
      child: Builder(
        builder: (context) => PopScope(
          canPop: _partidaTerminada,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _confirmarRendicion(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Brilliant - Partida'),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'Reglas del Juego',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PantallaReglas()),
                    );
                  },
                  icon: const Icon(Icons.menu_book_rounded),
                ),
                Builder(
                  builder: (context) {
                    final bool pantallaAngosta =
                        MediaQuery.sizeOf(context).width < 380;
                    return TextButton.icon(
                      key: const Key('boton-rendirse'),
                      onPressed: _conexionInestable
                          ? null
                          : () => _confirmarRendicion(context),
                      icon: const Icon(Icons.flag),
                      label: pantallaAngosta
                          ? const SizedBox.shrink()
                          : const Text('Rendirse'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFB91C1C),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: BlocConsumer<JuegoTurnoBloc, JuegoTurnoEstado>(
              listener: (context, state) {
                final bool esTerminal =
                    state is JuegoRendicionLocal ||
                    state is JuegoGanadoPorAbandono ||
                    state is JuegoCanceladoDesconexion ||
                    state is JuegoFinalizadoPorPuntos;
                if (esTerminal && !_partidaTerminada) {
                  setState(() => _partidaTerminada = true);
                }
                if (state is JuegoGanadoPorAbandono) {
                  _mostrarDialogoVictoria(context);
                }
                if (state is JuegoCanceladoDesconexion) {
                  _mostrarDialogoDesconexion(context);
                }
                if (state is JuegoRendicionLocal && !_rendicionNotificada) {
                  _rendicionNotificada = true;
                  _mostrarDialogoRendicion(context);
                }
                if (state is JuegoFinalizadoPorPuntos) {
                  _mostrarDialogoVictoriaPorPuntos(context, state);
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // El tablero es cuadrado y usa el máximo ancho permitido por
                      // el teléfono, con un tope para tablets/escritorio.
                      final double anchoDisponible = constraints.maxWidth - 24;
                      final double ladoTablero = anchoDisponible.clamp(
                        160.0,
                        480.0,
                      );

                      return SingleChildScrollView(
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

                            _construirLeyenda(state),
                            _construirHistorial(state),
                            const SizedBox(height: 8),
                            SizedBox(
                              key: const Key('tablero-juego'),
                              width: ladoTablero,
                              height: ladoTablero,
                              child: AbsorbPointer(
                                absorbing:
                                    _conexionInestable ||
                                    (state.esMultijugador &&
                                        !state.puedeActuar),
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

                                    final bool esAncla =
                                        state.celdaAncla == celda;
                                    final bool esObjetivoValido = state
                                        .celdasObjetivoValidas
                                        .contains(celda);

                                    return GestureDetector(
                                      onTap: () {
                                        if (celda.valor != null) {
                                          context.read<JuegoTurnoBloc>().add(
                                            EventoSeleccionarAnclaTablero(
                                              celda,
                                            ),
                                          );
                                        } else if (esObjetivoValido) {
                                          context.read<JuegoTurnoBloc>().add(
                                            EventoColocarNumeroEnObjetivo(
                                              celda,
                                            ),
                                          );
                                        } else {
                                          context.read<JuegoTurnoBloc>().add(
                                            EventoMovimientoInvalido(celda),
                                          );
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        decoration: BoxDecoration(
                                          color: esObjetivoValido
                                              ? Colors.amberAccent
                                              : colorDeRegion(celda.region),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                                    color: Colors.amber
                                                        .withValues(alpha: 0.8),
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
                                                                Region
                                                                    .amarillo ||
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

                            Container(
                              color: Colors.grey.shade100,
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  if (state.dado1 != null &&
                                      state.dado2 != null) ...[
                                    const Text(
                                      'Selecciona cuál dado usarás como ANCLA:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildChipDado(
                                          context: context,
                                          valorDado: state.dado1!.valor,
                                          esAncla: state.indiceDadoAncla == 0,
                                          onTap: state.puedeActuar
                                              ? () => context
                                                    .read<JuegoTurnoBloc>()
                                                    .add(
                                                      EventoSeleccionarDadoAncla(
                                                        0,
                                                      ),
                                                    )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        _buildChipDado(
                                          context: context,
                                          valorDado: state.dado2!.valor,
                                          esAncla: state.indiceDadoAncla == 1,
                                          onTap: state.puedeActuar
                                              ? () => context
                                                    .read<JuegoTurnoBloc>()
                                                    .add(
                                                      EventoSeleccionarDadoAncla(
                                                        1,
                                                      ),
                                                    )
                                              : null,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                  ],
                                  if (state.esMultijugador) ...[
                                    _construirInfoRonda(state),
                                    const SizedBox(height: 10),
                                    if (state.esAnfitrion)
                                      ElevatedButton.icon(
                                        key: const Key('boton-lanzar-dados'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed:
                                            _conexionInestable ||
                                                !state.puedeLanzarDados
                                            ? null
                                            : () {
                                                context
                                                    .read<JuegoTurnoBloc>()
                                                    .add(EventoLanzarDados());
                                              },
                                        icon: const Icon(Icons.casino),
                                        label: Text(
                                          state.esperandoDados
                                              ? 'Lanzando dados...'
                                              : state.rondaActiva
                                              ? 'Ronda en curso'
                                              : state.esperandoJugadoresListos
                                              ? 'Esperando jugadores (${state.jugadoresListos}/${state.totalJugadores})...'
                                              : 'Lanzar 2 Dados',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      )
                                    else if (!state.rondaActiva)
                                      const Text(
                                        'Esperando lanzamiento del anfitrión...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    else
                                      Text(
                                        'Ronda ${state.numeroRonda} en curso',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (state.puedeSaltarTurno) ...[
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        key: const Key('boton-saltar-turno'),
                                        onPressed: _conexionInestable
                                            ? null
                                            : () {
                                                context
                                                    .read<JuegoTurnoBloc>()
                                                    .add(EventoSaltarTurno());
                                              },
                                        icon: const Icon(Icons.skip_next),
                                        label: const Text('Saltar Turno'),
                                      ),
                                    ],
                                    if (state.accionTurnoCompletada) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Acción completada. Esperando a los demás...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ] else
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
                                              context
                                                  .read<JuegoTurnoBloc>()
                                                  .add(EventoLanzarDados());
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirInfoRonda(JuegoTurnoEstado state) {
    if (!state.rondaActiva) {
      return Text(
        state.numeroRonda == 0
            ? 'Esperando el inicio de la primera ronda.'
            : 'Ronda ${state.numeroRonda} completada.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      );
    }

    final int minutos = state.segundosRestantesRonda ~/ 60;
    final int segundos = state.segundosRestantesRonda % 60;
    final String tiempo =
        '${minutos.toString().padLeft(2, '0')}:'
        '${segundos.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Text(
          'Ronda ${state.numeroRonda}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          'Tiempo restante: $tiempo',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: state.segundosRestantesRonda <= 30
                ? Colors.red.shade700
                : Colors.black87,
          ),
        ),
      ],
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

  Widget _construirLeyenda(JuegoTurnoEstado state) {
    final List<ResumenRegion> resumen = calcularResumenRegiones(state.tablero);

    if (resumen.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Text(
            'Regiones',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: resumen.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return _construirEntradaLeyenda(resumen[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _construirEntradaLeyenda(ResumenRegion region) {
    final Color color = region.tipo.color;
    final Color colorTexto = color.computeLuminance() > 0.6
        ? Colors.black87
        : Colors.white;
    final String puntos = region.puntosPorPuesto
        .asMap()
        .entries
        .map((entrada) => '${entrada.key + 1}º ${entrada.value}')
        .join('  ');

    return Container(
      key: Key('leyenda-tipo-${region.tipo.identificador}'),
      width: 148,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.black26),
                ),
                child: Text(
                  region.tipo.simbolo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: colorTexto,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  region.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bloques ${region.bloquesCompletados}/${region.totalBloques}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            puntos,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _construirHistorial(JuegoTurnoEstado state) {
    if (state.historialRegiones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Text(
            'Historial de regiones',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          height: 58,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: state.historialRegiones.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final RegistroRegion registro = state.historialRegiones[index];
              final Color color = colorDeRegion(registro.region);
              final String bloque = nombreBloqueRegion(registro.region);
              final String nombre = bloque.isEmpty
                  ? nombreDeRegion(registro.region)
                  : '${nombreDeRegion(registro.region)} $bloque';

              return Container(
                key: Key(
                  'historial-region-${registro.region.name}-${registro.puesto}-$index',
                ),
                width: 132,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: registro.puntos > 0
                      ? color.withValues(alpha: 0.14)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: registro.puntos > 0
                        ? color.withValues(alpha: 0.7)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${registro.usuario} · ${registro.puesto}º · '
                      '${registro.puntos} pts',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: registro.puntos > 0
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

  Future<void> _confirmarRendicion(BuildContext context) async {
    if (_dialogoRendicionAbierto || _partidaTerminada) return;
    _dialogoRendicionAbierto = true;

    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar rendición'),
        content: const Text(
          '¿Estás seguro de que deseas rendirte? Perderás la partida actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar Rendición'),
          ),
        ],
      ),
    );

    _dialogoRendicionAbierto = false;

    if (confirmado != true || !context.mounted) return;

    context.read<JuegoTurnoBloc>().add(EventoRendirse());
  }

  void _mostrarDialogoRendicion(BuildContext context) {
    _temporizadorSalidaRendicion?.cancel();
    bool navegando = false;
    late BuildContext dialogContext;

    void volverAlMenu() {
      if (navegando || !mounted) return;
      navegando = true;
      _temporizadorSalidaRendicion?.cancel();

      if (Navigator.of(dialogContext).canPop()) {
        Navigator.of(dialogContext).pop();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaMenuMapas()),
        (route) => false,
      );
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (contextDialogo) {
        dialogContext = contextDialogo;
        return AlertDialog(
          title: const Text('Te has rendido'),
          content: const Text(
            'Has abandonado la partida. Volverás al menú de mapas en unos segundos.',
          ),
          actions: [
            TextButton(
              onPressed: volverAlMenu,
              child: const Text('Volver al menú de mapas'),
            ),
          ],
        );
      },
    );

    _temporizadorSalidaRendicion = Timer(
      const Duration(seconds: 2),
      volverAlMenu,
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
    VoidCallback? onTap,
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
      onSelected: _conexionInestable || onTap == null ? null : (_) => onTap(),
    );
  }
}
