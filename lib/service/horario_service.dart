import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/horario.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';

class HorarioService {
  static String get baseUrl => ApiConfig.baseUrl + '/horarios';
  
  /// Obtiene todos los horarios
  /// GET /horarios/
  static Future<List<Horario>> getHorarios() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Horario.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Error obteniendo horarios (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Obtiene una lista de horarios por un grupo
  /// GET /horarios/{idgrupo}/horarios
  Future<List<Horario>> getHorariosPorGrupo(int idGrupo) async {
    final url = Uri.parse('$baseUrl/$idGrupo/horarios');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener los horarios del grupo $idGrupo');
    }

    final List<dynamic> decoded = jsonDecode(response.body);
    // aquí le pasamos el idGrupo a cada fromJson
    return decoded
        .map((e) => Horario.fromJsonWithGroup(e as Map<String, dynamic>, idGrupo))
        .toList();
  }

  /// Crea un horario, con los datos recibidos y se le asigna el grupo indicado
  /// POST /horarios/nuevoHorario
  static Future<Horario> crearHorario({required int grupoId, required String dia, required String horaEntrada, required String horaSalida}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nuevoHorario?idGrupo=$grupoId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dia': dia,
        'horaEntrada': horaEntrada,
        'horaSalida': horaSalida,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Horario.fromJson(data);
    } else {
      throw Exception(
        'Error creando horario: ${response.statusCode} ${response.body}'
      );
    }
  }

  /// Edita un horario, por el id, y los datos a editar
  /// PUT /horarios/editarHorario/{id}
  static Future<Horario> editarHorario({ required int id, required String dia, required String horaEntrada, required String horaSalida, required int grupoId}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/editarHorario/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dia': dia,
        'horaEntrada': horaEntrada,
        'horaSalida': horaSalida,
        'grupoId': grupoId,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Horario.fromJson(json);
    } else {
      throw Exception(
        'Error al editar horario (${response.statusCode}): ${response.body}'
      );
    }
  }

  /// Elimina el horario por el id recibido
  /// DELETE /horarios/eliminarHorario/{id}
  static Future<bool> eliminarHorario(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/eliminarHorario/$id'));
    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 404) {
      throw Exception('Horario no encontrado (404)');
    } else {
      throw Exception(
        'Error al eliminar horario (${response.statusCode}): ${response.body}'
      );
    }
  }
}
