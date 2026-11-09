import 'package:flutter/material.dart';

import '../../datos/servicios/servicio_autenticacion.dart';
import '../../dominio/validaciones_autenticacion.dart';
import '../../../juego/presentacion/pantallas/pantalla_menu_mapas.dart';
import 'pantalla_registro.dart';

const Color _azulProfundo = Color(0xFF312E81);
const Color _cian = Color(0xFF0EA5E9);
const Color _textoPrincipal = Color(0xFF0F172A);
const Color _textoSecundario = Color(0xFF64748B);
const Color _fondoCampo = Color(0xFFF1F5F9);

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final GlobalKey<FormState> _formularioKey = GlobalKey<FormState>();
  final TextEditingController _usuarioControlador = TextEditingController();
  final TextEditingController _contrasenaControlador = TextEditingController();
  final ServicioAutenticacion _servicioAutenticacion = ServicioAutenticacion();

  bool _estaCargando = false;
  bool _mostrarContrasena = false;

  Future<void> _manejarEnvioFormulario() async {
    if (!_formularioKey.currentState!.validate()) return;

    final String usuario = normalizarNombreUsuario(_usuarioControlador.text);
    final String contrasena = _contrasenaControlador.text;

    setState(() {
      _estaCargando = true;
    });

    final resultado = await _servicioAutenticacion.iniciarSesion(
      usuario,
      contrasena,
    );

    if (!mounted) return;

    setState(() {
      _estaCargando = false;
    });

    _mostrarMensaje(
      resultado['mensaje']?.toString() ?? 'No se pudo iniciar sesión.',
      esError: resultado['exito'] != true,
    );

    if (resultado['exito'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaMenuMapas()),
      );
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor: esError
            ? const Color(0xFFDC2626)
            : const Color(0xFF059669),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioControlador.dispose();
    _contrasenaControlador.dispose();
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
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _construirTarjeta(),
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
                  Icons.sports_esports_rounded,
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
              'Bienvenido de nuevo',
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
              'Inicia sesión para continuar tu partida.',
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
              autofillHints: const [AutofillHints.username],
              maxLength: 30,
              decoration: _decoracionCampo(
                etiqueta: 'Nombre de usuario',
                pista: 'Ej. gael_pl',
                icono: Icons.person_outline_rounded,
              ).copyWith(counterText: ''),
              validator: (valor) => validarNombreUsuario(
                valor,
                mensajeVacio: 'Ingresa tu nombre de usuario',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contrasenaControlador,
              obscureText: !_mostrarContrasena,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _manejarEnvioFormulario(),
              decoration: _decoracionCampo(
                etiqueta: 'Contraseña',
                pista: 'Ingresa tu contraseña',
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
                if ((valor ?? '').isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 26),
            _BotonPrincipal(
              cargando: _estaCargando,
              texto: 'Entrar',
              onPressed: _manejarEnvioFormulario,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿No tienes cuenta?',
                  style: TextStyle(color: _textoSecundario, fontSize: 14),
                ),
                TextButton(
                  onPressed: _estaCargando
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PantallaRegistro(),
                            ),
                          );
                        },
                  child: const Text(
                    'Regístrate',
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
