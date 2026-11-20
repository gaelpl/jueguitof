abstract class ClasificacionEvento {
  const ClasificacionEvento();
}

class CargarClasificacion extends ClasificacionEvento {
  final int? limite;

  const CargarClasificacion({this.limite});
}
