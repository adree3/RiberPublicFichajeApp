import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'dart:convert';

class FichajeService {
  static const String _baseUrl = "http://localhost:9999/fichajes";

  /// GET /fichajes/usuario/{idUsuario}
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

  /// POST /fichajes/abrirFichaje/{idUsuario}
  static Future<Fichaje> abrirFichaje(int idUsuario) async {
    final uri = Uri.parse('$_baseUrl/abrirFichaje/$idUsuario');
    final resp = await http.post(uri, headers: {
      'Content-Type': 'application/json',
    });
    if (resp.statusCode == 200) {
      return Fichaje.fromJson(jsonDecode(resp.body));
    } else if (resp.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    }
    throw Exception('Error al abrir fichaje (${resp.statusCode})');
  }

  /// PUT /fichajes/cerrarFichaje/{idUsuario}
  static Future<Fichaje> cerrarFichaje(int idUsuario) async {
    final uri = Uri.parse('$_baseUrl/cerrarFichaje/$idUsuario');
    final resp = await http.put(uri, headers: {
      'Content-Type': 'application/json',
    });
    if (resp.statusCode == 200) {
      return Fichaje.fromJson(jsonDecode(resp.body));
    } else if (resp.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else if (resp.statusCode == 409) {
      throw Exception('No hay jornada abierta hoy');
    }
    throw Exception('Error al cerrar fichaje (${resp.statusCode})');
  }
}
