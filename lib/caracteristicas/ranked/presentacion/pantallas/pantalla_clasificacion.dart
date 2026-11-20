import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dominio/entidades/jugador_clasificacion.dart';
import '../../dominio/rangos.dart';
import '../blocs/clasificacion_bloc/clasificacion_bloc.dart';

const Color _azulProfundo = Color(0xFF312E81);
const Color _cian = Color(0xFF0EA5E9);
const Color _textoPrincipal = Color(0xFF0F172A);
const Color _textoSecundario = Color(0xFF64748B);
const Color _fondoClaro = Color(0xFFF8FAFC);

class PantallaClasificacion extends StatelessWidget {
  const PantallaClasificacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoClaro,
      appBar: AppBar(
        title: const Text('Clasificación Ranked'),
        centerTitle: true,
        backgroundColor: _azulProfundo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => context.read<ClasificacionBloc>().add(
              const CargarClasificacion(),
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocBuilder<ClasificacionBloc, ClasificacionEstado>(
        builder: (context, estado) {
          if (estado.cargando && !estado.tieneEntradas) {
            return const Center(child: CircularProgressIndicator());
          }

          if (estado.error != null && !estado.tieneEntradas) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      estado.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<ClasificacionBloc>().add(
                        const CargarClasificacion(),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!estado.tieneEntradas) {
            return const Center(
              child: Text(
                'Aún no hay jugadores en la clasificación.',
                style: TextStyle(fontSize: 15, color: _textoSecundario),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                if (estado.error != null)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFEE2E2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      estado.error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: estado.entradas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, indice) {
                      final entrada = estado.entradas[indice];
                      return _FilaClasificacion(
                        entrada: entrada,
                        resaltar:
                            estado.usuarioActual != null &&
                            estado.usuarioActual!.idUsuario ==
                                entrada.idUsuario,
                      );
                    },
                  ),
                ),
                if (estado.usuarioActual != null &&
                    !estado.entradas.any(
                      (entrada) =>
                          entrada.idUsuario == estado.usuarioActual!.idUsuario,
                    ))
                  _FilaClasificacion(
                    entrada: estado.usuarioActual!,
                    resaltar: true,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TarjetaTop5Clasificacion extends StatelessWidget {
  const TarjetaTop5Clasificacion({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClasificacionBloc, ClasificacionEstado>(
      builder: (context, estado) {
        final List<JugadorClasificacion> entradas = estado.entradas
            .take(5)
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                final bloc = context.read<ClasificacionBloc>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: const PantallaClasificacion(),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _cian.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.leaderboard_rounded,
                            color: _cian,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top 5 Ranked',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _textoPrincipal,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Clasificación global por RP',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textoSecundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: _textoSecundario,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (estado.cargando && entradas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                        ),
                      )
                    else if (entradas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Sé el primero en aparecer jugando ranked.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textoSecundario,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (final entrada in entradas)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _FilaTop(entrada: entrada),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilaTop extends StatelessWidget {
  final JugadorClasificacion entrada;

  const _FilaTop({required this.entrada});

  @override
  Widget build(BuildContext context) {
    final Color color = Color(colorDeLiga(entrada.rp));
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '#${entrada.posicion}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _textoSecundario,
            ),
          ),
        ),
        CircleAvatar(
          radius: 15,
          backgroundColor: color.withValues(alpha: 0.18),
          child: Text(
            entrada.inicial,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            entrada.usuario,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textoPrincipal,
            ),
          ),
        ),
        Text(
          '${entrada.rp} RP',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _azulProfundo,
          ),
        ),
      ],
    );
  }
}

class _FilaClasificacion extends StatelessWidget {
  final JugadorClasificacion entrada;
  final bool resaltar;

  const _FilaClasificacion({required this.entrada, required this.resaltar});

  @override
  Widget build(BuildContext context) {
    final Color color = Color(colorDeLiga(entrada.rp));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: resaltar ? _cian.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: resaltar
              ? _cian.withValues(alpha: 0.5)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '#${entrada.posicion}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: _textoSecundario,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.18),
            child: Text(
              entrada.inicial,
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entrada.usuario,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _textoPrincipal,
                        ),
                      ),
                    ),
                    if (resaltar)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text(
                          'TÚ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: _cian,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${entrada.liga} ${entrada.division} · ${entrada.victorias} V / ${entrada.partidas} PJ',
                  style: const TextStyle(fontSize: 11, color: _textoSecundario),
                ),
              ],
            ),
          ),
          Text(
            '${entrada.rp} RP',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _azulProfundo,
            ),
          ),
        ],
      ),
    );
  }
}
