const String patronNombreUsuario = r'^[a-zA-Z0-9._-]+$';

final RegExp _regexNombreUsuario = RegExp(patronNombreUsuario);

String normalizarNombreUsuario(String? usuario) {
  return (usuario ?? '').trim();
}

bool esNombreUsuarioValido(String? usuario) {
  final String normalizado = normalizarNombreUsuario(usuario);
  return normalizado.length >= 3 &&
      normalizado.length <= 30 &&
      _regexNombreUsuario.hasMatch(normalizado);
}

String? validarNombreUsuario(
  String? usuario, {
  String mensajeVacio = 'Ingresa tu nombre de usuario',
}) {
  final String normalizado = normalizarNombreUsuario(usuario);

  if (normalizado.isEmpty) {
    return mensajeVacio;
  }

  if (normalizado.length < 3 || normalizado.length > 30) {
    return 'Debe tener entre 3 y 30 caracteres';
  }

  if (!_regexNombreUsuario.hasMatch(normalizado)) {
    return 'Usa solo letras, números, puntos, guiones o guiones bajos';
  }

  return null;
}
