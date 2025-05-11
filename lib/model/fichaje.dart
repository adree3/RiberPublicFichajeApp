import 'usuario.dart';

class Fichaje {
  final int? id;
  final DateTime? fechaHoraEntrada;
  final DateTime? fechaHoraSalida;
  final String? ubicacion;
  final bool nfcUsado;
  final Usuario usuario;

  Fichaje({
    this.id,
    this.fechaHoraEntrada,
    this.fechaHoraSalida,
    this.ubicacion,
    required this.nfcUsado,
    required this.usuario,
  });

  factory Fichaje.fromJson(Map<String, dynamic> json) {
    final usuarioField = json['usuario'];
    late final Usuario usuario;
    if (usuarioField is int) {
      usuario = Usuario(
        id: usuarioField,
        nombre: '',
        apellido1: '',
        apellido2: null,
        email: '',
        contrasena: null,
        rol: Rol.empleado,
        estado: Estado.activo,
        grupoId: null,
      );
    } else if (usuarioField is Map<String, dynamic>) {
      usuario = Usuario.fromJson(usuarioField);
    } else {
      throw Exception('Campo "usuario" inválido en Fichaje: $usuarioField');
    }
    return Fichaje(
      id: json['id'] as int?,
      fechaHoraEntrada: json['fechaHoraEntrada'] != null
          ? DateTime.parse(json['fechaHoraEntrada'] as String)
          : null,
      fechaHoraSalida: json['fechaHoraSalida'] != null
          ? DateTime.parse(json['fechaHoraSalida'] as String)
          : null,
      ubicacion: json['ubicacion'] as String?,
      nfcUsado: json['nfcUsado'] as bool? ?? false,
      usuario: usuario,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaHoraEntrada': fechaHoraEntrada?.toIso8601String(),
      'fechaHoraSalida': fechaHoraSalida?.toIso8601String(),
      'ubicacion': ubicacion,
      'nfcUsado': nfcUsado,
      'usuario': usuario.toJson(),
    };
  }
}
