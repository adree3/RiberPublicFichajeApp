import 'dart:convert';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';
import 'package:riber_republic_fichaje_app/utils/api_client.dart';
import 'package:riber_republic_fichaje_app/utils/excepciones/credenciales_invalidas.dart';

/// Conecta el API de usuarios con la aplicacion de flutter
class UsuarioService {
  static String get baseUrl => ApiConfig.baseUrl + '/usuarios';

  /// Obtiene todos los usuarios 
  /// GET /usuarios/
  Future<List<Usuario>> getUsuarios() async {
    final response = await ApiClient.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> lista = jsonDecode(utf8Body);
      return lista.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  /// Obtiene los usuarios activos
  /// GET /usuarios/activos
  Future<List<Usuario>> getUsuariosActivos() async {
    final response = await ApiClient.get(Uri.parse('$baseUrl/activos'));
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> lista = jsonDecode(utf8Body);
      return lista.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  /// Obtiene los empleados activos
  /// GET /usuarios/activos
  Future<List<Usuario>> getEmpleadosActivos() async {
    final response = await ApiClient.get(Uri.parse('$baseUrl/empleadosActivos'));
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> lista = jsonDecode(utf8Body);
      return lista.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  /// Obtiene los horarios de hoy de un usuario
  /// GET /usuarios/{idUsuario}/horarioHoy
  static Future<HorarioHoy> getHorarioDeHoy(int idUsuario) async {
    final response = await ApiClient.get(Uri.parse('$baseUrl/$idUsuario/horarioHoy'));

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(utf8Body);
      return HorarioHoy.fromJson(data);
    } else {
      throw Exception('Error al obtener el horario de hoy');
    }
  }

  /// Comprueba si un email ya está registrado
  /// GET /usuarios/existe
  Future<bool> emailEnUso(String email) async {
    final response = await ApiClient.get(Uri.parse('$baseUrl/existe?email=$email'));
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      return jsonDecode(utf8Body) as bool;
    } else {
      throw Exception('Error comprobando email (${response.statusCode})');
    }
  }

  /// Crea un usuario 
  /// POST /usuarios/nuevoUsuario/{idGrupo}
  Future<void> crearUsuario(Usuario usuario, int idGrupo) async {
    final response = await ApiClient.post(
      Uri.parse('$baseUrl/nuevoUsuario?idGrupo=$idGrupo'),
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear usuario: ${response.body}');
    }
  }

  /// Edita la contraseña a un usuario
  /// PUT /usuarios/{idUsuario}/cambiarContrasena
  static Future<void> cambiarContrasena(int idUsuario, String contrasenaActual, String nuevaContrasena) async {
    final response = await ApiClient.put(
      Uri.parse('$baseUrl/$idUsuario/cambiarContrasena'),
      body: jsonEncode({
        'contrasenaActual': contrasenaActual,
        'nuevaContrasena' : nuevaContrasena,
      }),
    );
    if (response.statusCode == 200) {
      return;
    }
    // Error de contraseña invalida
    if (response.statusCode==400){
      final errorData = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final mensaje = errorData['message'] as String? ??'Contraseña incorrecta';
      throw CredenciaslesInvalidasException(mensaje);
    }
    throw Exception('Error al cambiar contraseña (${response.statusCode}): ${response.body}');
  }

  /// Edita un usuario
  /// PUT /usuarios/editarUsuario/{id}/update?idGrupo={idGrupo}
  static Future<Usuario> editarUsuario(int idUsuario, Map<String, dynamic> usuarioEditado, int idGrupo) async {
    final response = await ApiClient.put(
      Uri.parse('$baseUrl/editarUsuario/$idUsuario?idGrupo=$idGrupo'),
      body: jsonEncode(usuarioEditado),
    );
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      return Usuario.fromJson(jsonDecode(utf8Body));
    } else {
      throw Exception(
        'Error al actualizar usuario (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Elimina un usuario
  /// DELETE /usuarios/eliminarUsuario/{id}
  Future<void> eliminarUsuario(int idUsuario) async {
    final response = await ApiClient.delete(Uri.parse('$baseUrl/eliminarUsuario/$idUsuario'));

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
