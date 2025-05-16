import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/main.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase para reutilizar codigo y no tener que añadir el token en cada servio, 
/// se llama al servicio correspondiente y va con el service
class ApiClient {
  /// Guarda el headers y el token por defecto.
  static Future<Map<String, String>> get _defaultHeaders async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get para el servicio
  static Future<http.Response> get(Uri uri) async {
    final headers = await _defaultHeaders;
    final response = await http.get(uri, headers: headers);
    await _error401(response);
    return response;
  }

  /// Post para el servicio
  static Future<http.Response> post(Uri uri, {dynamic body}) async {
    final headers = await _defaultHeaders;
    final response = await http.post(uri, headers: headers, body: body);
    await _error401(response);
    return response;
  }

  /// Put para el servicio
  static Future<http.Response> put(Uri uri, {dynamic body}) async {
    final headers = await _defaultHeaders;
    final response = await http.put(uri, headers: headers, body: body);
    await _error401(response);
    return response;
  }

  /// Delete para el servicio
  static Future<http.Response> delete(Uri uri) async {
    final headers = await _defaultHeaders;
    final response = await http.delete(uri, headers: headers);
    await _error401(response);
    return response;
  }

  /// Comprueba si da el error 401 o 403, en caso de que de elimina el token 
  /// y el usuario del sharedPreferences, cierra sesion y se redirige al login
  static Future<void> _error401(http.Response resp) async {
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('usuario');

      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        Provider.of<AuthProvider>(ctx, listen: false).cerrarSesion();
      }

      navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/', (_) => false);
    }
  }
}
