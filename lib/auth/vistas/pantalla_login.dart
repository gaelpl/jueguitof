import 'package:flutter/material.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  // Controladores para los campos de texto con nombres en español
  final TextEditingController _correoControlador = TextEditingController();
  final TextEditingController _contrasenaControlador = TextEditingController();

  // Función simulada para manejar el evento de presionar el botón de inicio de sesión
  void _manejarEnvioFormulario() {
    final String correo = _correoControlador.text.trim();
    final String contrasena = _contrasenaControlador.text.trim();

    // Validaciones básicas locales
    if (correo.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    // Aquí integraremos la llamada HTTP al backend en los siguientes commits
    print('Intentando iniciar sesión con el correo: $correo');
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

                // Botón de Envío
                ElevatedButton(
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