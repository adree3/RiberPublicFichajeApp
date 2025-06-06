import 'dart:io' show Platform;
/// Configuracion de las rutas de la API segun la plataforma que sean
class ApiConfig {
  static String get host {
    if (Platform.isAndroid) {
      // En caso de estar ejecutando la aplicacion en un dispositivo Android,
      // se tiene que usar el mismo WIFI tanto para el dispositivo que ejecute 
      // el API como el del dispositivo Android y hay que configurar la ip 
      // del host según la del dispositivo que corra el API aquí:
      return '192.168.8.182';
    } else {
      return 'localhost';
    }
  }

  static const String port = '9999';

  static String get baseUrl => 'http://$host:$port';
}