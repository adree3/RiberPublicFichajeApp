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
    return Fichaje(
      id: json['id'],
      fechaHoraEntrada: json['fechaHoraEntrada'] != null
          ? DateTime.parse(json['fechaHoraEntrada'])
          : null,
      fechaHoraSalida: json['fechaHoraSalida'] != null  
          ? DateTime.parse(json['fechaHoraSalida'])
          : null,
      ubicacion: json['ubicacion'],
      nfcUsado: json['nfcUsado'] ?? false,
      usuario: Usuario.fromJson(json['usuario']),
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
