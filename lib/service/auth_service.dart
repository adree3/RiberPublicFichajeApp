import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/loginResponse.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';

/// Conecta el API de ausencias con la aplicacion de flutter
class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  
  /// Comprueba si el usuario y contraseña son correctos, y guarda el token
  static Future<LoginResponse?> login(String email, String contrasena, bool recuerdame) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'contrasena': contrasena,
        'recuerdame' : recuerdame
      }),
    );

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final data = jsonDecode(utf8Body);
      return LoginResponse.fromJson(data);
    } else {
      return null;
    }
  }
}
