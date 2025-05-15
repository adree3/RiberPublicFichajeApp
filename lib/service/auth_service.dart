import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';

/// Conecta el API de ausencias con la aplicacion de flutter
class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  
  /// 
  static Future<Usuario?> login(String email, String contrasena) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'contrasena': contrasena,
      }),
    );

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final data = jsonDecode(utf8Body);
      return Usuario.fromJson(data);
    } else {
      return null;
    }
  }
}
