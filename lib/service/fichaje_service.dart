import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'dart:convert';

class FichajeService {
  static const String _baseUrl = "http://localhost:9999/fichajes";

  static Future<List<Fichaje>> getFichajesPorUsuario(int idUsuario) async {
    final url = "$_baseUrl/usuario/$idUsuario";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Fichaje.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar fichajes del usuario");
    }
  }

  static Future<Fichaje> crearFichaje(int idUsuario, {required DateTime fechaHoraEntrada, String? ubicacion, bool nfcUsado = false}) async {

    final uri = Uri.parse("$_baseUrl/nuevaFichaje?idUsuario=$idUsuario");
    final body = jsonEncode({
      "fechaHoraEntrada": fechaHoraEntrada.toIso8601String(),
      "ubicacion": ubicacion,
      "nfcUsado": nfcUsado,
    });
    final resp = await http.post(uri,
      headers: {'Content-Type': 'application/json'},
      body: body
    );
    if (resp.statusCode == 201) {
      return Fichaje.fromJson(jsonDecode(resp.body));
    }
    throw Exception("Error al crear fichaje: ${resp.body}");
  }

  static Future<Fichaje> cerrarFichaje(int idFichaje, {required DateTime fechaHoraSalida}) async {

    final uri = Uri.parse("$_baseUrl/$idFichaje/cerrarFichaje");
    final body = jsonEncode({
      "fechaHoraSalida": fechaHoraSalida.toIso8601String(),
    });
    final resp = await http.put(uri,
      headers: {'Content-Type': 'application/json'},
      body: body
    );
    if (resp.statusCode == 200) {
      return Fichaje.fromJson(jsonDecode(resp.body));
    }
    throw Exception("Error al cerrar fichaje: ${resp.body}");
  }
}
