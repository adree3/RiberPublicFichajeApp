import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/usuario.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:9999'; 

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
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    } else {
      return null;
    }
  }
}
