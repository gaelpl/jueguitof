import 'dart:math';

/// Representa el dado de 6 caras utilizado en las partidas de Brilliant.
class Dado {
  final int valor;

  const Dado([this.valor = 1])
      : assert(valor >= 1 && valor <= 6, 'El valor del dado debe estar entre 1 y 6');

  /// Simula la tirada aleatoria de un dado obteniendo un valor del 1 al 6.
  static Dado lanzar({Random? random}) {
    final rng = random ?? Random();
    return Dado(rng.nextInt(6) + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dado && runtimeType == other.runtimeType && valor == other.valor;

  @override
  int get hashCode => valor.hashCode;
}