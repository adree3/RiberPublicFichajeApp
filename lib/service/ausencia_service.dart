import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/ausencia.dart';

class AusenciaService {
  static const String baseUrl = 'http://localhost:9999/ausencias';

  /// GET /ausencias/
  Future<List<Ausencia>> getAusencias() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((e) => Ausencia.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener las ausencias');
    }
  }

  /// GET /ausencias/{idUsuario}/existe
  static Future<bool> existeAusencia(int idUsuario, DateTime fecha) async {
    final iso = fecha.toIso8601String().split('T').first;
    final url = '$baseUrl/$idUsuario/existe?fecha=$iso';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as bool;
    }
    throw Exception('Error comprobando ausencia (${resp.statusCode})');
  }

  /// POST /ausencias/nuevaAusencia}
  static Future<Ausencia> crearAusencia({required int idUsuario, required DateTime fecha, required Motivo motivo, String? detalles}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nuevaAusencia?idUsuario=$idUsuario'),
      headers: {'Content-Type': 'application/json'},
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
}
