import 'dart:ui';

export 'tablero.dart';

int calculate() {
  return 6 * 7;
}

// ==========================================
// 1. CLASE ABSTRACTA Y CLASES DE TIPO
// ==========================================
abstract class Tipo {
  Color get color;
  String get descripcion;
  bool esPosibleAgregar(List<int> actuales, int posible);
  Map<int, int> get puntuaciones;
}

/// Azul: todos los números de la región deben ser iguales.
class TipoAzul extends Tipo {
  @override
  Color get color => const Color(0xFF2196F3);
  @override
  String get descripcion => 'Todos los números deben de ser iguales';
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) {
    return actuales.isEmpty || actuales.every((element) => element == posible);
  }

  @override
  Map<int, int> get puntuaciones => {1: 7, 2: 5, 3: 3};
}

/// Morado/Lila: como máximo 2 valores distintos en la región.
class TipoMorado extends Tipo {
  @override
  Color get color => const Color(0xFF8E24AA);
  @override
  String get descripcion =>
      'Puede haber como máximo 2 valores distintos en la región';
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) {
    final valoresUnicos = {...actuales, posible};
    return valoresUnicos.length <= 2;
  }

  @override
  Map<int, int> get puntuaciones => {1: 7, 2: 5, 3: 3};
}

/// Rojo / Amarillo: todos los números deben ser diferentes.
class TipoRojoAmarillo extends Tipo {
  @override
  Color get color => const Color(0xFFE53935);
  @override
  String get descripcion => 'Todos los números deben de ser diferentes';
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) {
    return !actuales.contains(posible);
  }

  @override
  Map<int, int> get puntuaciones => {1: 6, 2: 4, 3: 2};
}

/// Verde: comodín (sin restricciones).
class TipoVerde extends Tipo {
  @override
  Color get color => const Color(0xFF4CAF50);
  @override
  String get descripcion => 'Cualquier número es permitido';
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) {
    return true;
  }

  @override
  Map<int, int> get puntuaciones => {1: 4, 2: 3, 3: 2};
}

// Funciones delegadas directas para mantener compatibilidad con las pruebas previas
bool esValidoRojoAmarillo(List<int> numeros, int nuevoNumero) =>
    TipoRojoAmarillo().esPosibleAgregar(numeros, nuevoNumero);
bool esValidoVerde(List<int> numeros, int nuevoNumero) =>
    TipoVerde().esPosibleAgregar(numeros, nuevoNumero);
bool esValidoAzul(List<int> numeros, int nuevoNumero) =>
    TipoAzul().esPosibleAgregar(numeros, nuevoNumero);
bool esValidoLila(List<int> numeros, int nuevoNumero) =>
    TipoMorado().esPosibleAgregar(numeros, nuevoNumero);

// ==========================================
// 2. MODELO DE ZONA Y TABLERO
// ==========================================
/// Regiones físicas del Mapa 1.
enum Region {
  rojoNoroeste,
  rojoSureste,
  amarillo,
  verdeNoroeste,
  verdeEste,
  azulNorte,
  azulSureste,
  lilaNorte,
  lilaSuroeste,
}

/// Representa una zona/bloque del tablero conectada a un Tipo abstracto.
class Zona {
  final Region region;
  final Tipo tipo;
  Zona({required this.region, required this.tipo});
  bool esInsercionValida(List<int> numerosActuales, int nuevoNumero) {
    return tipo.esPosibleAgregar(numerosActuales, nuevoNumero);
  }
}

/// Representa una celda del tablero.
class Celda {
  final int fila;
  final int columna;
  final Region region;
  int? valor;
  Celda({
    required this.fila,
    required this.columna,
    required this.region,
    this.valor,
  });
}

// ==========================================
// 3. EXTRACCIÓN DE CELDAS
// ==========================================
/// Extrae la lista de enteros presentes en cualquier bloque según su región.
List<int> extraerValoresDeBloque(List<Celda> tablero, Region region) {
  return tablero
      .where((celda) => celda.region == region && celda.valor != null)
      .map((celda) => celda.valor!)
      .toList();
}
