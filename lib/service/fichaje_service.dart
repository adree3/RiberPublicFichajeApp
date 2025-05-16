import 'dart:convert';
import 'package:riber_republic_fichaje_app/model/totalHorasHoy.dart';
import 'package:riber_republic_fichaje_app/utils/api_client.dart';
import 'package:riber_republic_fichaje_app/utils/api_config.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';

/// Conecta el API de fichajes con la aplicacion de flutter
class FichajeService {
  static String get _baseUrl => ApiConfig.baseUrl + '/fichajes';


  /// GET /fichajes/usuario/{idUsuario}
  static Future<List<Fichaje>> getFichajesPorUsuario(int idUsuario) async {
    final url = "$_baseUrl/usuario/$idUsuario";
    final response = await ApiClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(utf8Body);
      return jsonList.map((json) => Fichaje.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar fichajes del usuario");
    }
  }

  /// GET /fichajes/totalHorasHoy/{idUsuario}
  static Future<TotalHorasHoy> getTotalHorasHoy(int idUsuario) async {
    final uri = Uri.parse("$_baseUrl/totalHorasHoy/$idUsuario");
    final response = await ApiClient.get(uri);
    if (response.statusCode == 200) {
      return TotalHorasHoy.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al obtener total horas hoy (${response.statusCode})');
  }

  /// POST /fichajes/abrirFichaje/{idUsuario}
  static Future<Fichaje>abrirFichaje(int idUsuario, {required bool nfcUsado, required String ubicacion}) async  {
    final response = await ApiClient.post(
      Uri.parse('$_baseUrl/abrirFichaje/$idUsuario'), 
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
  static Future<Fichaje> cerrarFichaje({required int idUsuario, required bool nfcUsado}) async {
    final response = await ApiClient.put(
      Uri.parse('$_baseUrl/cerrarFichaje/$idUsuario?nfcUsado=$nfcUsado'));
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
