import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';

class GrupoService {
  static String get baseUrl => ApiConfig.baseUrl + '/grupos';

  /// Obtiene todos los grupos
  /// GET /grupos/
  Future<List<Grupo>> getGrupos() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> lista = jsonDecode(utf8Body);
      return lista.map((e) => Grupo.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener los grupos');
    }
  }

  /// Crea un grupo por los parametros recibidos
  /// POST /grupos/nuevoGrupo
  Future<bool> crearGrupo(Grupo grupo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nuevoGrupo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(grupo.toJson()),
    );
    return response.statusCode == 201;
  }

  /// Actualiza un grupo y si se han asignado o desasignado usuarios al grupo también se actualiza
  /// PUT /grupos/editarGrupo/{id}
  static Future<Grupo> actualizarGrupo({required int id, required String nombre, required List<int> usuariosIds}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/editarGrupo/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'usuariosIds': usuariosIds,
      }),
    );
    if (response.statusCode == 200) {
      return Grupo.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error actualizando grupo (${response.statusCode})');
  }

  /// Eliminar el grupo recibido y re asigna los usuarios a "Sin Asingar"
  /// DELETE /grupos/eliminarGrupo/{id}
  static Future<bool> eliminarGrupo(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/eliminarGrupo/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 204) {
      return true;
    }
    throw Exception('Error borrando grupo (${response.statusCode})');
  }
}
