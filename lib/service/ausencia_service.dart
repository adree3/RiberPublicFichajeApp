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

  Future<bool> crearAusencia(Ausencia ausencia, int idUsuario) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nuevaAusencia?idUsuario=$idUsuario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ausencia.toJson()),
    );

    return response.statusCode == 201;
  }
}
