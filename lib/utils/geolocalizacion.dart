import 'dart:math';

class GeofenceConfiguracion {
  static const double latitude   = 41.6555543449889;
  static const double longitud  = -4.7080354375460525;
  static const double radioMetros = 50;
} 
//41.66500903262423, -4.7238655524719695 instituto
double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
  const radio = 6371000; // metros
  final dLatitud = _toRad(lat2 - lat1);
  final dLongitud = _toRad(lon2 - lon1);
  final area = sin(dLatitud/2) * sin(dLatitud/2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) *
      sin(dLongitud/2) * sin(dLongitud/2);
  final c = 2 * atan2(sqrt(area), sqrt(1 - area));
  return radio * c;
}

double _toRad(double deg) => deg * pi / 180;