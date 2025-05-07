import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';

class UsuarioService {
  static String get baseUrl => ApiConfig.baseUrl + '/usuarios';

  /// GET /usuarios/
  Future<List<Usuario>> getUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/'));


    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(utf8Body);
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
  static Future<void> cambiarContrasena(int idUsuario, String contrasenaActual, String nuevaContrasena) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$idUsuario/cambiarContrasena'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'contrasenaActual': contrasenaActual,
        'nuevaContrasena' : nuevaContrasena,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al cambiar contraseña (${response.statusCode}): ${response.body}');
    }
  }

  /// PUT /usuarios/editarUsuario/{id}/update?idGrupo={idGrupo}
  static Future<Usuario> actualizarUsuario(int idUsuario,Usuario usuario,int idGrupo,) async {
    final response = await http.put(
      Uri.parse('$baseUrl/editarUsuario/$idUsuario?idGrupo=$idGrupo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );
    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al actualizar el usuario (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// DELETE /usuarios/{id}
  Future<void> eliminarUsuario(int idUsuario) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$idUsuario'),
      headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 204) {
      if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      }
      throw Exception(
        'Error al eliminar usuario (${response.statusCode}): ${response.body}',
      );
    }
  }
}
