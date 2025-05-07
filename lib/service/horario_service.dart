import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/horario.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';

class HorarioService {
  static String get baseUrl => ApiConfig.baseUrl + '/horarios';

  Future<List<Horario>> getHorariosPorGrupo(int idGrupo) async {
    final url = Uri.parse('$baseUrl/$idGrupo/horarios');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener los horarios del grupo $idGrupo');
    }

    final List<dynamic> decoded = jsonDecode(response.body);
    // aquí le pasamos el idGrupo a cada fromJson
    return decoded
        .map((e) => Horario.fromJson(e as Map<String, dynamic>, idGrupo))
        .toList();
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
