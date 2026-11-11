import 'dart:math';
import 'dart:ui';

import '../entidades/tablero.dart';

export '../entidades/tablero.dart';
export '../entidades/dado.dart';

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
  Map<int, int> get puntuaciones => {1: 6, 2: 4, 3: 2};
}

class TipoRojo extends Tipo {
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

class TipoAmarillo extends Tipo {
  @override
  Color get color => const Color(0xFFFFEB3B);

  @override
  String get descripcion => 'Todos los números deben de ser diferentes';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) {
    return !actuales.contains(posible);
  }

  @override
  Map<int, int> get puntuaciones => {1: 8, 2: 6, 3: 4};
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

class TipoBlanco extends Tipo {
  @override
  Color get color => const Color(0xFFECEFF1);

  @override
  String get descripcion => 'Todos los números deben de ser iguales';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) {
    return actuales.isEmpty ||
        actuales.every((elemento) => elemento == posible);
  }

  @override
  Map<int, int> get puntuaciones => {1: 8, 2: 6, 3: 4};
}

// 3. Clase TipoNaranja (regla 4-6 arriba / 1-3 abajo, puntuación 6, 4, 3)
class TipoNaranja extends Tipo {
  final bool esFilaSuperior;

  TipoNaranja({required this.esFilaSuperior});

  @override
  Color get color => const Color(0xFFFF9800);

  @override
  String get descripcion => esFilaSuperior
      ? 'Solo se permiten números del 4 al 6'
      : 'Solo se permiten números del 1 al 3';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) {
    if (esFilaSuperior) {
      return posible >= 4 && posible <= 6;
    } else {
      return posible >= 1 && posible <= 3;
    }
  }

  @override
  Map<int, int> get puntuaciones => {1: 6, 2: 4, 3: 3};
}

bool esValidoRojoAmarillo(List<int> numeros, int nuevoNumero) =>
    TipoRojo().esPosibleAgregar(numeros, nuevoNumero);

bool esValidoVerde(List<int> numeros, int nuevoNumero) =>
    TipoVerde().esPosibleAgregar(numeros, nuevoNumero);

bool esValidoAzul(List<int> numeros, int nuevoNumero) =>
    TipoAzul().esPosibleAgregar(numeros, nuevoNumero);

bool esValidoLila(List<int> numeros, int nuevoNumero) =>
    TipoMorado().esPosibleAgregar(numeros, nuevoNumero);

bool esValidoBlanco(List<int> numeros, int nuevoNumero) =>
    TipoBlanco().esPosibleAgregar(numeros, nuevoNumero);

bool esValidoNaranja(
  List<int> numeros,
  int nuevoNumero, {
  required bool esFilaSuperior,
}) =>
    TipoNaranja(esFilaSuperior: esFilaSuperior)
        .esPosibleAgregar(numeros, nuevoNumero);

enum Region {
  rojoNoroeste,
  rojoSureste,
  rojoNoreste,
  rojoSuroeste,
  amarillo,
  verdeNoroeste,
  verdeEste,
  azulNorte,
  azulSureste,
  lilaNorte,
  lilaSuroeste,
  lilaSureste,
  blanco,
  naranjaNorte,
  naranjaSur,
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

  bool asignarValor(int? nuevoValor) {
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

void limpiarEstrellas(Tablero tablero) {
  for (final celda in tablero.obtenerCeldasEstrella()) {
    celda.asignarValor(null);
  }
}

bool asignarEstrellasAleatorias(Tablero tablero, {Random? generador}) {
  final estrellas = tablero.obtenerCeldasEstrella();
  if (estrellas.length != 6) return false;

  limpiarEstrellas(tablero);

  final random = generador ?? Random();
  final disponibles = <int>{1, 2, 3, 4, 5, 6};
  final exito = _asignarEstrellasRecursivo(
    tablero,
    estrellas,
    disponibles,
    0,
    random,
  );

  if (!exito) {
    limpiarEstrellas(tablero);
  }

  return exito;
}

bool _asignarEstrellasRecursivo(
  Tablero tablero,
  List<Celda> estrellas,
  Set<int> disponibles,
  int indice,
  Random random,
) {
  if (indice == estrellas.length) return true;

  final celda = estrellas[indice];
  final zona = tablero.obtenerZona(celda.region);
  final candidatos = disponibles.toList()..shuffle(random);

  for (final valor in candidatos) {
    if (zona != null) {
      final valoresActuales = estrellas
          .where((otra) => otra != celda && otra.region == celda.region)
          .map((otra) => otra.valor)
          .whereType<int>()
          .toList();

      if (!zona.tipo.esPosibleAgregar(valoresActuales, valor)) {
        continue;
      }
    }

    celda.asignarValor(valor);
    disponibles.remove(valor);

    if (_asignarEstrellasRecursivo(
      tablero,
      estrellas,
      disponibles,
      indice + 1,
      random,
    )) {
      return true;
    }

    disponibles.add(valor);
    celda.asignarValor(null);
  }

  return false;
}

/// Obtiene las celdas adyacentes ortogonales (arriba, abajo, izquierda, derecha) de una celda ancla.
List<Celda> obtenerCeldasAdyacentes(Tablero tablero, Celda ancla) {
  final List<Celda> adyacentes = [];
  final direcciones = [
    {'col': 0, 'fila': -1}, // Arriba
    {'col': 0, 'fila': 1}, // Abajo
    {'col': -1, 'fila': 0}, // Izquierda
    {'col': 1, 'fila': 0}, // Derecha
  ];

  for (var dir in direcciones) {
    final nuevaCol = ancla.columna + dir['col']!;
    final nuevaFila = ancla.fila + dir['fila']!;
    final celda = tablero.obtenerCeldaEn(nuevaCol, nuevaFila);
    if (celda != null) {
      adyacentes.add(celda);
    }
  }

  return adyacentes;
}

/// Filtra de las celdas adyacentes al ancla solo aquellas vacías que permiten colocar el valor del dado.
List<Celda> obtenerCeldasObjetivoValidas({
  required Tablero tablero,
  required Celda celdaAncla,
  required int valorAColocar,
}) {
  final adyacentes = obtenerCeldasAdyacentes(tablero, celdaAncla);
  final List<Celda> validas = [];

  for (var celda in adyacentes) {
    if (celda.valor == null) {
      final valoresActuales = extraerValoresDeBloque(
        tablero.celdas,
        celda.region,
      );
      final zona = tablero.obtenerZona(celda.region);

      if (zona != null &&
          zona.esInsercionValida(valoresActuales, valorAColocar)) {
        validas.add(celda);
      }
    }
  }

  return validas;
}

String mensajeDadosNoLanzados() {
  return 'Primero lanza los dados para comenzar tu turno.';
}

String mensajeSeleccionaAncla() {
  return 'Selecciona una casilla con el valor de uno de tus dados para usar como ancla.';
}

String mensajeCasillaOcupada(int valor, {int? valorDado1, int? valorDado2}) {
  final dados = <int>[?valorDado1, ?valorDado2];

  if (dados.isEmpty) {
    return 'Casilla ocupada. Esa casilla ya tiene un $valor.';
  }

  final opciones = dados.toSet().join(' o ');
  return 'Casilla ocupada. Esa casilla tiene un $valor; para usarla como ancla debe coincidir con tus dados ($opciones).';
}

String mensajeSoloAdyacente() {
  return 'Solo puedes colocar en una casilla adyacente al ancla.';
}

String mensajeAnclaSinOpciones(int valor) {
  return 'El ancla no tiene casillas disponibles para colocar un $valor. Prueba con otra casilla o vuelve a lanzar los dados.';
}

String _nombreColorZona(Tipo tipo) {
  if (tipo is TipoAzul) return 'azules';
  if (tipo is TipoBlanco) return 'blancas';
  if (tipo is TipoRojo) return 'rojas';
  if (tipo is TipoAmarillo) return 'amarillas';
  if (tipo is TipoMorado) return 'lilas';
  if (tipo is TipoNaranja) return 'naranjas';
  if (tipo is TipoVerde) return 'verdes';
  return 'de esta zona';
}

String mensajeReglaZona({
  required Tipo tipo,
  required int valorAColocar,
  required List<int> valoresActuales,
}) {
  final color = _nombreColorZona(tipo);

  if (tipo is TipoAzul || tipo is TipoBlanco) {
    final valoresDistintos = valoresActuales.toSet();
    if (valoresDistintos.isNotEmpty) {
      return 'En las casillas $color solo puedes poner números iguales. Esta zona ya tiene el ${valoresDistintos.first}.';
    }
    return 'En las casillas $color solo puedes poner números iguales.';
  }

  if (tipo is TipoRojo || tipo is TipoAmarillo) {
    if (valoresActuales.contains(valorAColocar)) {
      return 'En las casillas $color todos los números deben ser diferentes. El $valorAColocar ya está en esta zona.';
    }
    return 'En las casillas $color todos los números deben ser diferentes.';
  }

  if (tipo is TipoMorado) {
    return 'En las casillas lilas puedes usar como máximo dos números distintos. El $valorAColocar sería un tercer valor.';
  }

  if (tipo is TipoNaranja) {
    final ubicacion = tipo.esFilaSuperior ? 'superiores' : 'inferiores';
    final rango = tipo.esFilaSuperior ? 'del 4 al 6' : 'del 1 al 3';
    return 'En las casillas naranjas $ubicacion solo puedes poner números $rango.';
  }

  if (tipo is TipoVerde) {
    return 'En las casillas verdes cualquier número es válido.';
  }

  return 'El $valorAColocar no cumple la regla de esta zona.';
}

String obtenerMensajeMovimientoInvalido({
  required Tablero tablero,
  required Celda celda,
  required Celda? celdaAncla,
  required int? valorAColocar,
}) {
  if (celda.valor != null) {
    return mensajeCasillaOcupada(celda.valor!);
  }

  if (celdaAncla == null) {
    return mensajeSeleccionaAncla();
  }

  final adyacentes = obtenerCeldasAdyacentes(tablero, celdaAncla);
  if (!adyacentes.contains(celda)) {
    return mensajeSoloAdyacente();
  }

  if (valorAColocar == null) {
    return mensajeSeleccionaAncla();
  }

  final zona = tablero.obtenerZona(celda.region);
  if (zona == null) {
    return 'Esta casilla no tiene una regla de zona configurada.';
  }

  final valoresActuales = extraerValoresDeBloque(tablero.celdas, celda.region);
  return mensajeReglaZona(
    tipo: zona.tipo,
    valorAColocar: valorAColocar,
    valoresActuales: valoresActuales,
  );
}

class ProgresoZona {
  final Region region;
  final Tipo tipo;
  final int totalCeldas;
  final int celdasCompletadas;
  final int puntos;

  const ProgresoZona({
    required this.region,
    required this.tipo,
    required this.totalCeldas,
    required this.celdasCompletadas,
    required this.puntos,
  });

  bool get completada => totalCeldas > 0 && celdasCompletadas == totalCeldas;
}

/// Calcula el progreso y los puntos de cada región que tiene celdas en el tablero.
List<ProgresoZona> calcularProgresoZonas(Tablero tablero) {
  final regiones = tablero.celdas.map((celda) => celda.region).toSet();
  final progresos = <ProgresoZona>[];

  for (final region in regiones) {
    final zona = tablero.obtenerZona(region);
    if (zona == null) continue;

    final celdas = tablero.celdas.where((celda) => celda.region == region);
    final totalCeldas = celdas.length;
    final celdasCompletadas = celdas
        .where((celda) => celda.valor != null)
        .length;

    progresos.add(
      ProgresoZona(
        region: region,
        tipo: zona.tipo,
        totalCeldas: totalCeldas,
        celdasCompletadas: celdasCompletadas,
        puntos: zona.tipo.puntuaciones[1] ?? 0,
      ),
    );
  }

  progresos.sort((a, b) => a.region.index.compareTo(b.region.index));
  return progresos;
}

/// Calcula la puntuación total del tablero otorgando la puntuación de 1.er lugar al completar cada bloque al 100%.
int calcularPuntuacionTotal(Tablero tablero) {
  int puntajeTotal = 0;

  for (var zona in tablero.mapaZonas.values) {
    // Total de celdas que componen la región actual
    final totalCeldasRegion = tablero.celdas
        .where((c) => c.region == zona.region)
        .length;

    // Celdas completadas con valor en esta región
    final valoresRellenos = extraerValoresDeBloque(tablero.celdas, zona.region);

    // Si la región está 100% llena
    if (valoresRellenos.length == totalCeldasRegion && totalCeldasRegion > 0) {
      // Clave 1 representa los puntos para el 1.er lugar (en morado otorga 6 pts)
      final puntosZona = zona.tipo.puntuaciones[1] ?? 0;
      puntajeTotal += puntosZona;
    }
  }

  return puntajeTotal;
}
