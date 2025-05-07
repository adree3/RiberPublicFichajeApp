import 'dart:io' show Platform;
/// configuracion de las rutas de la API segun la plataforma que sean
class ApiConfig {
  static String get host {
    if (Platform.isAndroid) {
      return '10.0.2.2';
    } else {
      return 'localhost';
    }
  }

  static const String port = '9999';

  static String get baseUrl => 'http://$host:$port';
}