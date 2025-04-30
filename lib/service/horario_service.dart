import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/horario.dart';

class HorarioService {
  static const String baseUrl = 'http://localhost:9999/horarios';

  Future<List<Horario>> getHorarios() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((e) => Horario.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener los horarios');
    }
  }

  Future<bool> crearHorario(Horario horario, int idGrupo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nuevaHorario?idGrupo=$idGrupo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(horario.toJson()),
    );

    return response.statusCode == 201;
  }
}
