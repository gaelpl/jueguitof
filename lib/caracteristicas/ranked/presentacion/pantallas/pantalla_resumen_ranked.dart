import 'package:flutter/material.dart';

import '../../../juego/presentacion/pantallas/pantalla_menu_mapas.dart';
import '../../dominio/entidades/resumen_partida.dart';
import '../../dominio/rangos.dart';

const Color _azulProfundo = Color(0xFF312E81);
const Color _cian = Color(0xFF0EA5E9);
const Color _textoPrincipal = Color(0xFF0F172A);
const Color _textoSecundario = Color(0xFF64748B);
const Color _fondoClaro = Color(0xFFF8FAFC);

class PantallaResumenRanked extends StatelessWidget {
  final ResumenPartida resumen;

  const PantallaResumenRanked({super.key, required this.resumen});

  @override
  Widget build(BuildContext context) {
    final Color colorLiga = Color(colorDeLiga(resumen.rpDespues));
    final Color colorDelta = resumen.rpDelta >= 0
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: _fondoClaro,
      appBar: AppBar(
        title: const Text('Resultado Ranked'),
        centerTitle: true,
        backgroundColor: _azulProfundo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_azulProfundo, _cian],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        resumen.puesto == 1
                            ? Icons.emoji_events_rounded
                            : Icons.military_tech_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        resumen.tituloResultado,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Puntuación: ${resumen.puntuacion}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'RP',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _textoSecundario,
                            ),
                          ),
                          Text(
                            '${resumen.rpAntes} → ${resumen.rpDespues}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: _textoPrincipal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorDelta.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${resumen.rpDelta >= 0 ? '+' : ''}${resumen.rpDelta} RP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: colorDelta,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: colorLiga.withValues(alpha: 0.16),
                            child: Icon(Icons.shield_rounded, color: colorLiga),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${resumen.ligaDespues} ${obtenerDivision(resumen.rpDespues)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: _textoPrincipal,
                                  ),
                                ),
                                if (resumen.cambioLiga)
                                  Text(
                                    'Antes: ${resumen.ligaAntes}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _textoSecundario,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'CLASIFICACIÓN DE LA PARTIDA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: _textoSecundario,
                  ),
                ),
                const SizedBox(height: 10),
                ...resumen.clasificacion.map(
                  (entrada) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '#${entrada.puesto}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _textoSecundario,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entrada.usuario,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textoPrincipal,
                            ),
                          ),
                        ),
                        Text(
                          '${entrada.puntuacion} pts',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textoSecundario,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${entrada.rpDelta >= 0 ? '+' : ''}${entrada.rpDelta}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: entrada.rpDelta >= 0
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _azulProfundo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const PantallaMenuMapas(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Volver al menú',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
