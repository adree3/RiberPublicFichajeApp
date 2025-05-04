import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';

class UsuarioService {
  static String baseUrl = 'http://localhost:9999/usuarios'; 

  /// GET /usuarios/
  Future<List<Usuario>> getUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }
    
  /// GET /usuarios/{idUsuario}/horarioHoy
  static Future<HorarioHoy> getHorarioDeHoy(int idUsuario) async {
    final uri = Uri.parse('$baseUrl/$idUsuario/horarioHoy');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return HorarioHoy.fromJson(data);
    } else {
      throw Exception('Error al obtener el horario de hoy');
    }
  }

  /// POST /usuarios/nuevoUsuario/{idGrupo}
  Future<void> crearUsuario(Usuario usuario, int idGrupo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nuevoUsuario?idGrupo=$idGrupo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear usuario: ${response.body}');
    }
  }

  /// PUT /usuarios/{idUsuario}/cambiarContrasena
  static Future<void> cambiarContrasena(int idUsuario, String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$idUsuario/cambiarContrasena'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      })
    );
    if (response.statusCode != 200) {
      throw Exception('Error al cambiar contraseña (${response.statusCode}): ${response.body}');
    }
  }

  static changePassword(String trim, String trim2) {}
}
