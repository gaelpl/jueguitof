class Liga {
  final String nombre;
  final int min;
  final int? max;
  final int colorHex;

  const Liga({
    required this.nombre,
    required this.min,
    required this.max,
    required this.colorHex,
  });
}

class ProgresoLiga {
  final Liga liga;
  final String division;
  final double progreso;
  final int rpRestante;

  const ProgresoLiga({
    required this.liga,
    required this.division,
    required this.progreso,
    required this.rpRestante,
  });
}

const List<Liga> ligasRanked = [
  Liga(nombre: 'Bronce', min: 0, max: 199, colorHex: 0xFFB45309),
  Liga(nombre: 'Plata', min: 200, max: 399, colorHex: 0xFF64748B),
  Liga(nombre: 'Oro', min: 400, max: 599, colorHex: 0xFFD97706),
  Liga(nombre: 'Platino', min: 600, max: 799, colorHex: 0xFF0D9488),
  Liga(nombre: 'Diamante', min: 800, max: null, colorHex: 0xFF4F46E5),
];

const List<String> divisionesRanked = ['IV', 'III', 'II', 'I'];

int _normalizarRp(int rp) => rp < 0 ? 0 : rp;

Liga obtenerLiga(int rp) {
  final int puntos = _normalizarRp(rp);
  for (final liga in ligasRanked) {
    if (liga.max == null || puntos <= liga.max!) return liga;
  }
  return ligasRanked.last;
}

String obtenerDivision(int rp) {
  final int puntos = _normalizarRp(rp);
  final int indice = ((puntos % 200) / 50).floor().clamp(0, 3);
  return divisionesRanked[indice];
}

ProgresoLiga obtenerProgresoLiga(int rp) {
  final int puntos = _normalizarRp(rp);
  final Liga liga = obtenerLiga(puntos);
  final int indice = ligasRanked.indexOf(liga);
  final Liga? siguiente = indice + 1 < ligasRanked.length
      ? ligasRanked[indice + 1]
      : null;

  if (siguiente == null) {
    return ProgresoLiga(
      liga: liga,
      division: obtenerDivision(puntos),
      progreso: 1,
      rpRestante: 0,
    );
  }

  final int rango = liga.max! - liga.min + 1;
  return ProgresoLiga(
    liga: liga,
    division: obtenerDivision(puntos),
    progreso: ((puntos - liga.min) / rango).clamp(0.0, 1.0),
    rpRestante: siguiente.min - puntos,
  );
}

int colorDeLiga(int rp) => obtenerLiga(rp).colorHex;

String etiquetaRango(int rp) =>
    '${obtenerLiga(rp).nombre} ${obtenerDivision(rp)}';
