import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/grupo.dart';

class GrupoService {
  static const String baseUrl = "http://localhost:9999/grupos";

  Future<List<Grupo>> getGrupos() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((e) => Grupo.fromJson(e)).toList();
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
