import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/ausencia.dart';

class AusenciaService {
  static const String baseUrl = 'http://localhost:9999/ausencias';

  Future<List<Ausencia>> getAusencias() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((e) => Ausencia.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener las ausencias');
    }
  }

  /// POST /ausencias/{idUsuario}
  static Future<Ausencia> crearAusencia({required int idUsuario, required DateTime fecha, required Motivo motivo, String? detalles}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$idUsuario'),
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
