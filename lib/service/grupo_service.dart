import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';

class GrupoService {
  static String get baseUrl => ApiConfig.baseUrl + '/grupos';


  Future<List<Grupo>> getGrupos() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body);
      return lista.map((e) => Grupo.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener los grupos');
    }
  }

  Future<bool> crearGrupo(Grupo grupo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nuevoGrupo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(grupo.toJson()),
    );

    return response.statusCode == 201;
  }
}
