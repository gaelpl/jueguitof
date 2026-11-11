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

String nombreDeRegion(Region region) {
  switch (region) {
    case Region.rojoNoroeste:
      return 'Rojo NO';
    case Region.rojoSureste:
      return 'Rojo SE';
    case Region.rojoNoreste:
      return 'Rojo NE';
    case Region.rojoSuroeste:
      return 'Rojo SO';
    case Region.amarillo:
      return 'Amarillo';
    case Region.verdeNoroeste:
      return 'Verde NO';
    case Region.verdeEste:
      return 'Verde E';
    case Region.azulNorte:
      return 'Azul N';
    case Region.azulSureste:
      return 'Azul SE';
    case Region.lilaNorte:
      return 'Lila N';
    case Region.lilaSuroeste:
      return 'Lila SO';
    case Region.lilaSureste:
      return 'Lila SE';
    case Region.blanco:
      return 'Blanco';
    case Region.naranjaNorte:
      return 'Naranja N';
    case Region.naranjaSur:
      return 'Naranja S';
  }
}
