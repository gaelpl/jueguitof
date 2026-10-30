import 'package:flutter/material.dart';

import '../servicios/servicio_autenticacion.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _correoControlador = TextEditingController();
  final TextEditingController _contrasenaControlador = TextEditingController();
  final ServicioAutenticacion _servicioAutenticacion = ServicioAutenticacion();

  bool _estaCargando = false;

  // Función para manejar el envío del formulario y conectar con el backend
  Future<void> _manejarEnvioFormulario() async {
    final String correo = _correoControlador.text.trim();
    final String contrasena = _contrasenaControlador.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _estaCargando = true;
    });

    // Llamada al servicio HTTP
    final resultado = await _servicioAutenticacion.iniciarSesion(
      correo,
      contrasena,
    );

    setState(() {
      _estaCargando = false;
    });

    if (!mounted) return;

    // Mostrar retroalimentación al usuario
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(resultado['mensaje'])));

    if (resultado['exito']) {
      // Aquí puedes navegar a la pantalla principal de tu juego más adelante
      print('Token guardado exitosamente. ¡Listo para jugar!');
    }
  }

  @override
  void dispose() {
    _correoControlador.dispose();
    _contrasenaControlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión - Jueguitof'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '¡Bienvenido de nuevo!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Campo de texto para el Correo
                TextField(
                  controller: _correoControlador,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de texto para la Contraseña
                TextField(
                  controller: _contrasenaControlador,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de Envío o Indicador de Carga
                _estaCargando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _manejarEnvioFormulario,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 16),
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
