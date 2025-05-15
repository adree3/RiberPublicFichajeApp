import 'package:riber_republic_fichaje_app/model/usuario.dart';

/// Modelo Ausencia
class Ausencia {
  /// Atributos
  int? id;
  DateTime fecha;
  Motivo motivo;
  EstadoAusencia estado;
  bool justificada;
  String? detalles;
  DateTime tiempoRegistrado;
  Usuario usuario;
  /// Constructor
  Ausencia({
    this.id,
    required this.fecha,
    this.motivo = Motivo.falta_injustificada,
    this.estado = EstadoAusencia.vacio,
    required this.justificada,
    this.detalles,
    required this.tiempoRegistrado,
    required this.usuario,
  });
  /// Convierte el json al modelo Ausencia 
  factory Ausencia.fromJson(Map<String, dynamic> json) {
    final usuarioField = json['usuario'];
    Usuario usuario;
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
      throw Exception('Campo "usuario" en ausencia inválido: $usuarioField');
    }
    return Ausencia(
      id: json['id'] as int?,
      fecha: DateTime.parse(json['fecha']),
      motivo: Motivo.values.firstWhere(
        (e) => e.toString().split('.').last == json['motivo'],
        orElse: () => Motivo.falta_injustificada,
      ),
      estado: EstadoAusencia.values.firstWhere(
        (e) => e.toString().split('.').last == json['estado'],
        orElse: () => EstadoAusencia.vacio,
      ),
      justificada: json['justificada'] as bool,
      detalles: json['detalles'] as String?,
      tiempoRegistrado: DateTime.parse(json['tiempoRegistrado']),
      usuario: usuario,
    );
  }

  /// Convierte del modelo Ausencia a Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'motivo': motivo.toString().split('.').last,
      'estado': estado.toString().split('.').last,
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
enum EstadoAusencia{
  vacio,
  pendiente,
  aceptada,
  rechazada
}
