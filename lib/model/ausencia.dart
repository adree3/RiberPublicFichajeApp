import 'package:riber_republic_fichaje_app/model/usuario.dart';

class Ausencia {
  int? id;
  DateTime fecha;
  Motivo motivo;
  bool justificada;
  String? detalles;
  DateTime tiempoRegistrado;
  Usuario usuario;

  Ausencia({
    this.id,
    required this.fecha,
    this.motivo = Motivo.falta_injustificada,
    required this.justificada,
    this.detalles,
    required this.tiempoRegistrado,
    required this.usuario,
  });

  factory Ausencia.fromJson(Map<String, dynamic> json) {
    return Ausencia(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      motivo: Motivo.values.firstWhere(
        (e) => e.toString().split('.').last == json['motivo'],
        orElse: () => Motivo.falta_injustificada,
      ),
      justificada: json['justificada'],
      detalles: json['detalles'],
      tiempoRegistrado: DateTime.parse(json['tiempoRegistrado']),
      usuario: Usuario.fromJson(json['usuario']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'motivo': motivo.toString().split('.').last,
      'justificada': justificada,
      'detalles': detalles,
      'tiempoRegistrado': tiempoRegistrado.toIso8601String(),
      'usuario': usuario.toJson(),
    };
  }
}
enum Motivo {
  retraso,
  permiso,
  vacaciones,
  enfermedad,
  falta_injustificada,
  otro
}
