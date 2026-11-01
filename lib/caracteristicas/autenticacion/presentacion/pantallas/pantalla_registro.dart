import 'package:flutter/material.dart';

import '../../datos/servicios/servicio_autenticacion.dart';
import '../../../juego/presentacion/pantallas/pantalla_menu_mapas.dart';

const Color _azulProfundo = Color(0xFF312E81);
const Color _cian = Color(0xFF0EA5E9);
const Color _textoPrincipal = Color(0xFF0F172A);
const Color _textoSecundario = Color(0xFF64748B);
const Color _fondoCampo = Color(0xFFF1F5F9);

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final GlobalKey<FormState> _formularioKey = GlobalKey<FormState>();
  final TextEditingController _usuarioControlador = TextEditingController();
  final TextEditingController _contrasenaControlador = TextEditingController();
  final TextEditingController _confirmarContrasenaControlador =
      TextEditingController();
  final ServicioAutenticacion _servicioAutenticacion = ServicioAutenticacion();

  bool _estaCargando = false;
  bool _mostrarContrasena = false;
  bool _mostrarConfirmacion = false;

  Future<void> _manejarRegistro() async {
    if (!_formularioKey.currentState!.validate()) return;

    final String usuario = _usuarioControlador.text.trim();
    final String contrasena = _contrasenaControlador.text.trim();

    setState(() {
      _estaCargando = true;
    });

    final resultado = await _servicioAutenticacion.registrarUsuario(
      usuario,
      contrasena,
    );

    if (!mounted) return;

    setState(() {
      _estaCargando = false;
    });

    _mostrarMensaje(
      resultado['mensaje']?.toString() ?? 'No se pudo completar el registro.',
      esError: resultado['exito'] != true,
    );

    if (resultado['exito'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PantallaMenuMapas()),
        (route) => false,
      );
    }
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

  @override
  void dispose() {
    _usuarioControlador.dispose();
    _contrasenaControlador.dispose();
    _confirmarContrasenaControlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: _circuloDecorativo(280, _cian.withValues(alpha: 0.18)),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          tooltip: 'Volver',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _construirTarjeta(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjeta() {
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
      child: Form(
        key: _formularioKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 34,
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
              'Crea tu cuenta',
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
              'Regístrate y empieza a conquistar cada mapa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textoSecundario,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _usuarioControlador,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newUsername],
              decoration: _decoracionCampo(
                etiqueta: 'Nombre de usuario',
                pista: 'Ej. gael_pl',
                icono: Icons.person_outline_rounded,
              ),
              validator: (valor) {
                final usuario = valor?.trim() ?? '';
                if (usuario.isEmpty) {
                  return 'Ingresa un nombre de usuario';
                }
                if (usuario.length < 3 || usuario.length > 30) {
                  return 'Debe tener entre 3 y 30 caracteres';
                }
                if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(usuario)) {
                  return 'Usa solo letras, números, puntos, guiones o guiones bajos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contrasenaControlador,
              obscureText: !_mostrarContrasena,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: _decoracionCampo(
                etiqueta: 'Contraseña',
                pista: 'Mínimo 6 caracteres',
                icono: Icons.lock_outline_rounded,
                sufijo: IconButton(
                  onPressed: () {
                    setState(() {
                      _mostrarContrasena = !_mostrarContrasena;
                    });
                  },
                  icon: Icon(
                    _mostrarContrasena
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _textoSecundario,
                  ),
                  tooltip: _mostrarContrasena
                      ? 'Ocultar contraseña'
                      : 'Mostrar contraseña',
                ),
              ),
              validator: (valor) {
                final contrasena = valor ?? '';
                if (contrasena.isEmpty) {
                  return 'Ingresa una contraseña';
                }
                if (contrasena.length < 6) {
                  return 'Debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmarContrasenaControlador,
              obscureText: !_mostrarConfirmacion,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _manejarRegistro(),
              decoration: _decoracionCampo(
                etiqueta: 'Confirmar contraseña',
                pista: 'Repite tu contraseña',
                icono: Icons.lock_reset_rounded,
                sufijo: IconButton(
                  onPressed: () {
                    setState(() {
                      _mostrarConfirmacion = !_mostrarConfirmacion;
                    });
                  },
                  icon: Icon(
                    _mostrarConfirmacion
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _textoSecundario,
                  ),
                  tooltip: _mostrarConfirmacion
                      ? 'Ocultar contraseña'
                      : 'Mostrar contraseña',
                ),
              ),
              validator: (valor) {
                if ((valor ?? '').isEmpty) {
                  return 'Confirma tu contraseña';
                }
                if (valor != _contrasenaControlador.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 26),
            _BotonPrincipal(
              cargando: _estaCargando,
              texto: 'Crear cuenta',
              onPressed: _manejarRegistro,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿Ya tienes cuenta?',
                  style: TextStyle(color: _textoSecundario, fontSize: 14),
                ),
                TextButton(
                  onPressed: _estaCargando
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _azulProfundo,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
  final VoidCallback onPressed;

  const _BotonPrincipal({
    required this.cargando,
    required this.texto,
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
                  : Text(
                      texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
