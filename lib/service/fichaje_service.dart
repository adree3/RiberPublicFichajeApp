import 'package:http/http.dart' as http;
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'dart:convert';

import 'package:riber_republic_fichaje_app/model/totalHorasHoy.dart';

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

  /// GET /fichajes/totalHorasHoy/{idUsuario}
  static Future<TotalHorasHoy> getTotalHorasHoy(int idUsuario) async {
    final uri = Uri.parse("$_baseUrl/totalHorasHoy/$idUsuario");
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      return TotalHorasHoy.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al obtener total horas hoy (${response.statusCode})');
  }

  /// POST /fichajes/abrirFichaje/{idUsuario}
  static Future<Fichaje>abrirFichaje(int idUsuario, {required bool nfcUsado, required String ubicacion}) async  {
    final response = await http.post(
      Uri.parse('$_baseUrl/abrirFichaje/$idUsuario'), 
      headers: {
      'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nfcUsado': nfcUsado,
        'ubicacion': ubicacion,
      })
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Fichaje.fromJson(jsonDecode(response.body));
    } 
    throw Exception('Error al abrir fichaje (${response.statusCode})');
  }

  /// PUT /fichajes/cerrarFichaje/{idUsuario}
  static Future<Fichaje> cerrarFichaje(int idUsuario) async {
    final uri = Uri.parse('$_baseUrl/cerrarFichaje/$idUsuario');
    final response = await http.put(uri, headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      return Fichaje.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Usuario no encontrado');
    } else if (response.statusCode == 409) {
      throw Exception('No hay jornada abierta hoy');
    }
    throw Exception('Error al cerrar fichaje (${response.statusCode})');
  }
}
