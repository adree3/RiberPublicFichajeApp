import 'package:riber_republic_fichaje_app/model/usuario.dart';

/// Dto de usuario para login con Token
class LoginResponse {
  /// Atributos
  final String token;
  final int id;
  final String nombre;
  final String apellido1;
  final String? apellido2;
  final String email;
  final Rol rol;
  final Estado estado;
  final int? grupoId;

  ///Constructor
  LoginResponse({
    required this.token,
    required this.id,
    required this.nombre,
    required this.apellido1,
    this.apellido2,
    required this.email,
    required this.rol,
    required this.estado,
    this.grupoId,
  });

  /// Convierte el json al modelo LoginResponse
  factory LoginResponse.fromJson(Map<String,dynamic> json) {
    return LoginResponse(
      token : json['token'] as String,
      id : json['id'] as int,
      nombre : json['nombre'] as String,
      apellido1 : json['apellido1'] as String,
      apellido2 : json['apellido2'] as String?,
      email : json['email'] as String,
      rol : Rol.values.firstWhere((e)=>e.name==json['rol']),
      estado : Estado.values.firstWhere((e)=>e.name==json['estado']),
      grupoId : json['grupoId'] as int?,
    );
  }
  /// Convierte de LoginResponse a Json
  Map<String, dynamic> toJson() {
    return {
      'token' : token,
      'id' : id,
      'nombre' : nombre,
      'apellido1' : apellido1,
      if (apellido2 != null) 'apellido2': apellido2,
      'email' : email,
      'rol' : rol.name,
      'estado' : estado.name,
      if (grupoId != null) 'grupoId': grupoId,
    };
  }
}