import 'dart:convert';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/utils/api_client.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';

/// Conecta el API de ausencias con la aplicacion de flutter
class AusenciaService {
  static String get baseUrl => ApiConfig.baseUrl + '/ausencias';

  /// Obtiene todas las ausencias
  /// GET /ausencias/
  Future<List<Ausencia>> getAusencias() async {
    final response = await ApiClient.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(utf8Body);
      return jsonList.map((e) => Ausencia.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener las ausencias');
    }
  }

  /// Comprueba si la ausencia existe
  /// GET /ausencias/{idUsuario}/existe
  static Future<bool> existeAusencia(int idUsuario, DateTime fecha) async {
    final iso = fecha.toIso8601String().split('T').first;
    final url = '$baseUrl/$idUsuario/existe?fecha=$iso';
    final resp = await ApiClient.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as bool;
    }
    throw Exception('Error comprobando ausencia (${resp.statusCode})');
  }

  /// Crea una nueva ausencia segun el id del usuario
  /// POST /ausencias/nuevaAusencia/{idUsuario}
  static Future<Ausencia> crearAusencia({required int idUsuario, required DateTime fecha, required Motivo motivo, String? detalles}) async {
    final response = await ApiClient.post(
      Uri.parse('$baseUrl/nuevaAusencia?idUsuario=$idUsuario'),
      body: jsonEncode({
        'fecha': fecha.toIso8601String(),
        'motivo': motivo.toString().split('.').last,
        'detalles': detalles,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Ausencia.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al justificar ausencia (${response.statusCode}): ${response.body}');
  }

  /// Edita la ausencia y dice si es justificada o no segun el estado de la ausencia
  /// POST /ausencias/editarAusencia/{idAusencia}}
  static Future<Ausencia> actualizarAusencia({required int idAusencia, required EstadoAusencia estado, String? detalles}) async {
    final response = await ApiClient.put(
      Uri.parse('$baseUrl/editarAusencia/$idAusencia'),
      body: jsonEncode({
        'estado': estado.toString().split('.').last,
        if (detalles != null) 'detalles': detalles,
      }),
    );
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      return Ausencia.fromJson(jsonDecode(utf8Body));
    } else {
      throw Exception('Error al actualizar ausencia (${response.statusCode})');
    }
  }

  /// Genera todas las ausencias posibles a partir de los fichajes
  /// POST /ausencias/generarAusencias
  static Future<void> generarAusencias() async {
    final resp = await ApiClient.post(
      Uri.parse('$baseUrl/generarAusencias'),
    );
    if (resp.statusCode != 204) {
      throw Exception(
        'Error al generar ausencias (${resp.statusCode}): ${resp.body}',
      );
    }
  }

}

