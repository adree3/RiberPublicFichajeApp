class Usuario {
  final int id;
  final String nombre;
  final String apellido1;
  final String? apellido2;
  final String email;
  final String? contrasena;
  final Rol rol;
  final Estado estado;
  final int? grupoId;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido1,
    this.apellido2,
    required this.email,
    this.contrasena,
    required this.rol,
    required this.estado,
    this.grupoId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final grupoField = json['grupo'];
    int? grupoId;
    if (grupoField is int) {
      grupoId = grupoField;
    } else if (grupoField is Map<String, dynamic>) {
      grupoId = grupoField['id'] as int?;
    }

    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido1: json['apellido1'] as String,
      apellido2: json['apellido2'] as String?,
      email: json['email'] as String,
      contrasena: json['contrasena'] as String?,
      rol: Rol.values.firstWhere((e) => e.name == json['rol']),
      estado: Estado.values.firstWhere((e) => e.name == json['estado']),
      grupoId: grupoId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido1': apellido1,
      'apellido2': apellido2,
      'email': email,
      'contrasena': contrasena,
      'rol': rol.name,
      'estado': estado.name,
      'grupo': grupoId != null ? {'id': grupoId} : null,
    };
  }
}

enum Rol {
  empleado,
  jefe,
}
enum Estado {
  activo,
  inactivo,
}
