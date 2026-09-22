import 'dart:ui';

export 'tablero.dart';

int calcular() {
  return 6 * 7;
}

abstract class Tipo {
  Color get color;
  String get descripcion;
  bool esPosibleAgregar(List<int> actuales, int posible);
  Map<int, int> get puntuaciones;
}

class TipoAzul extends Tipo {
  @override
  Color get color => const Color(0xFF2196F3);

  @override
  String get descripcion => 'Todos los números deben de ser iguales';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) {
    return actuales.isEmpty ||
        actuales.every((elemento) => elemento == posible);
  }

  @override
  Map<int, int> get puntuaciones => {1: 7, 2: 5, 3: 3};
}

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

bool esValidoRojoAmarillo(List<int> numeros, int nuevoNumero) =>
    TipoRojoAmarillo().esPosibleAgregar(numeros, nuevoNumero);

bool esValidoVerde(List<int> numeros, int nuevoNumero) =>
    TipoVerde().esPosibleAgregar(numeros, nuevoNumero);

bool esValidoAzul(List<int> numeros, int nuevoNumero) =>
    TipoAzul().esPosibleAgregar(numeros, nuevoNumero);

bool esValidoLila(List<int> numeros, int nuevoNumero) =>
    TipoMorado().esPosibleAgregar(numeros, nuevoNumero);

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

class Zona {
  final Region region;
  final Tipo tipo;

  Zona({required this.region, required this.tipo});

  bool esInsercionValida(List<int> numerosActuales, int nuevoNumero) {
    return tipo.esPosibleAgregar(numerosActuales, nuevoNumero);
  }
}

class Celda {
  final int fila;
  final int columna;
  final Region region;
  final bool esEstrella;
  int? _valor;

  Celda({
    required this.fila,
    required this.columna,
    required this.region,
    this.esEstrella = false,
    int? valor,
  }) : _valor = valor;

  int? get valor => _valor;

  bool asignarValor(int nuevoValor) {
    _valor = nuevoValor;
    return true;
  }
}

List<int> extraerValoresDeBloque(List<Celda> tablero, Region region) {
  return tablero
      .where((celda) => celda.region == region && celda.valor != null)
      .map((celda) => celda.valor!)
      .toList();
}
