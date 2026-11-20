enum ModoPartida {
  casual('casual', 'Casual'),
  ranked('ranked', 'Ranked');

  final String nombre;
  final String etiqueta;

  const ModoPartida(this.nombre, this.etiqueta);

  static ModoPartida desdeNombre(String? nombre) {
    if (nombre == 'ranked') return ModoPartida.ranked;
    return ModoPartida.casual;
  }
}
