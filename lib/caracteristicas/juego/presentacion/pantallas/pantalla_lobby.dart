import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../datos/mapas_oficiales.dart';
import '../blocs/lobby_bloc/lobby_bloc.dart';
import 'pantalla_seleccion_inicial.dart';

const Color _azulProfundo = Color(0xFF312E81);
const Color _cian = Color(0xFF0EA5E9);
const Color _textoPrincipal = Color(0xFF0F172A);
const Color _textoSecundario = Color(0xFF64748B);
const Color _fondoCampo = Color(0xFFF1F5F9);

class PantallaLobby extends StatefulWidget {
  const PantallaLobby({super.key});

  @override
  State<PantallaLobby> createState() => _PantallaLobbyState();
}

class _PantallaLobbyState extends State<PantallaLobby> {
  final GlobalKey<FormState> _formularioKey = GlobalKey<FormState>();
  final TextEditingController _codigoControlador = TextEditingController();

  bool _navegacionRealizada = false;

  @override
  void dispose() {
    _codigoControlador.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            esError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _irAlJuego() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PantallaSeleccionInicial(
          tablero: CreadorMapas.obtenerMapa(1),
          numeroMapa: 1,
        ),
      ),
    );
  }

  void _unirseASala() {
    if (!_formularioKey.currentState!.validate()) return;
    final String codigo = _codigoControlador.text.trim().toUpperCase();
    context.read<LobbyBloc>().add(UnirseSalaSolicitada(codigo));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LobbyBloc(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1B4B), _azulProfundo, Color(0xFF0284C7)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -70,
                child: _circuloDecorativo(
                  240,
                  Colors.white.withValues(alpha: 0.06),
                ),
              ),
              Positioned(
                bottom: -110,
                left: -80,
                child: _circuloDecorativo(
                  280,
                  _cian.withValues(alpha: 0.18),
                ),
              ),
              if (Navigator.of(context).canPop())
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        tooltip: 'Volver',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: BlocConsumer<LobbyBloc, LobbyEstado>(
                        listener: (context, estado) {
                          if (estado is ErrorLobby) {
                            _mostrarMensaje(estado.mensaje, esError: true);
                          }

                          if (estado is PartidaLista &&
                              !_navegacionRealizada) {
                            _navegacionRealizada = true;
                            _irAlJuego();
                          }
                        },
                        builder: (context, estado) {
                          return _construirTarjeta(context, estado);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirTarjeta(BuildContext context, LobbyEstado estado) {
    final bool creandoSala = estado is CreandoSala;
    final bool uniendoSala = estado is UniendoASala;
    final bool esperandoRival = estado is EsperandoRival;
    final bool ocupado = creandoSala || uniendoSala;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_azulProfundo, _cian],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _azulProfundo.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.groups_2_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'BRILLIANT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              color: _cian,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sala multijugador',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _textoPrincipal,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea una partida y comparte el código con tu rival, o únete a una sala existente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _textoSecundario,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 26),
          if (esperandoRival)
            _construirEsperandoRival(estado)
          else
            _construirFormulario(
              ocupado: ocupado,
              creandoSala: creandoSala,
              uniendoSala: uniendoSala,
            ),
          if (estado is ErrorLobby) ...[
            const SizedBox(height: 20),
            _construirError(estado.mensaje),
          ],
        ],
      ),
    );
  }

  Widget _construirEsperandoRival(EsperandoRival estado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _azulProfundo.withValues(alpha: 0.08),
                _cian.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cian.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              const Text(
                'CÓDIGO DE SALA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                  color: _textoSecundario,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                estado.codigo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: _azulProfundo,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: estado.codigo),
                  );
                  if (!mounted) return;
                  _mostrarMensaje('Código copiado al portapapeles.');
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copiar código'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(width: 12),
            Text(
              'Esperando a que se una un rival...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textoSecundario.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirFormulario({
    required bool ocupado,
    required bool creandoSala,
    required bool uniendoSala,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BotonPrincipal(
          cargando: creandoSala,
          texto: 'Crear Partida',
          icono: Icons.add_circle_outline_rounded,
          onPressed: () {
            context.read<LobbyBloc>().add(const CrearSalaSolicitada());
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: _textoSecundario.withValues(alpha: 0.25))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o únete con un código',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textoSecundario.withValues(alpha: 0.9),
                ),
              ),
            ),
            Expanded(child: Divider(color: _textoSecundario.withValues(alpha: 0.25))),
          ],
        ),
        const SizedBox(height: 24),
        Form(
          key: _formularioKey,
          child: TextFormField(
            controller: _codigoControlador,
            enabled: !ocupado,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
              LengthLimitingTextInputFormatter(6),
            ],
            onFieldSubmitted: (_) => _unirseASala(),
            decoration: _decoracionCampo(
              etiqueta: 'Código de sala',
              pista: 'Ej. A1B2C3',
              icono: Icons.key_rounded,
            ),
            validator: (valor) {
              final String codigo = valor?.trim() ?? '';
              if (codigo.isEmpty) {
                return 'Ingresa el código de la sala';
              }
              if (codigo.length < 5) {
                return 'El código debe tener al menos 5 caracteres';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        _BotonSecundario(
          cargando: uniendoSala,
          texto: 'Unirse a la Sala',
          onPressed: ocupado ? null : _unirseASala,
        ),
      ],
    );
  }

  Widget _construirError(String mensaje) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDC2626).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF991B1B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _decoracionCampo({
  required String etiqueta,
  required String pista,
  required IconData icono,
  Widget? sufijo,
}) {
  return InputDecoration(
    labelText: etiqueta,
    hintText: pista,
    prefixIcon: Icon(icono, color: _textoSecundario),
    suffixIcon: sufijo,
    filled: true,
    fillColor: _fondoCampo,
    counterText: '',
    labelStyle: const TextStyle(
      color: _textoSecundario,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(color: _textoSecundario.withValues(alpha: 0.7)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _cian, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
    ),
  );
}

Widget _circuloDecorativo(double tamanio, Color color) {
  return IgnorePointer(
    child: Container(
      width: tamanio,
      height: tamanio,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

class _BotonPrincipal extends StatelessWidget {
  final bool cargando;
  final String texto;
  final IconData icono;
  final VoidCallback onPressed;

  const _BotonPrincipal({
    required this.cargando,
    required this.texto,
    required this.icono,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_azulProfundo, _cian],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _azulProfundo.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: cargando ? null : onPressed,
          child: SizedBox(
            height: 54,
            child: Center(
              child: cargando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icono, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          texto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
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

class _BotonSecundario extends StatelessWidget {
  final bool cargando;
  final String texto;
  final VoidCallback? onPressed;

  const _BotonSecundario({
    required this.cargando,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: cargando ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _azulProfundo,
          side: BorderSide(
            color: _azulProfundo.withValues(alpha: 0.45),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : Text(
                texto,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}
