/// Configuración central de entorno para el cliente.
///
/// La URL del backend se inyecta en tiempo de compilación mediante
/// `--dart-define`, lo que permite cambiar entre desarrollo y producción
/// sin modificar el código.
///
/// Desarrollo:
///   flutter run
///
/// Producción (web):
///   flutter build web --release \
///     --dart-define=API_URL=https://tu-backend.onrender.com
class Entorno {
  Entorno._();

  /// URL base del backend, usada tanto para HTTP como para Sockets.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Indica si la app apunta a un backend remoto (producción).
  static bool get esProduccion =>
      !apiUrl.contains('localhost') && !apiUrl.contains('10.0.2.2');
}
