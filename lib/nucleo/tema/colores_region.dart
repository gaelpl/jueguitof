import 'package:flutter/material.dart';

import '../../caracteristicas/juego/dominio/logica/juego_logica.dart';

Color colorDeRegion(Region region) {
  switch (region) {
    case Region.azulNorte:
    case Region.azulSureste:
      return const Color(0xFF2196F3);
    case Region.rojoNoroeste:
    case Region.rojoSureste:
    case Region.rojoNoreste:
    case Region.rojoSuroeste:
      return const Color(0xFFE53935);
    case Region.verdeNoroeste:
    case Region.verdeEste:
      return const Color(0xFF4CAF50);
    case Region.lilaNorte:
    case Region.lilaSuroeste:
    case Region.lilaSureste:
      return const Color(0xFF9C27B0);
    case Region.amarillo:
      return const Color(0xFFFFEB3B);
    case Region.blanco:
      return const Color(0xFFECEFF1);
    case Region.naranjaNorte:
    case Region.naranjaSur:
      return const Color(0xFFFF9800);
  }
}
