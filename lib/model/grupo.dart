import 'usuario.dart';
import 'horario.dart';

class Grupo {
  final int? id;
  final String nombre;
  final int faltasTotales;
  final List<Usuario> usuarios;
  final List<Horario> horarios;

  Grupo({
    this.id,
    required this.nombre,
    required this.faltasTotales,
    required this.usuarios,
    required this.horarios,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'],
      nombre: json['nombre'],
      faltasTotales: json['faltasTotales'],
      usuarios: (json['usuarios'] as List<dynamic>)
          .map((e) => Usuario.fromJson(e))
          .toList(),
      horarios: (json['horarios'] as List<dynamic>)
          .map((e) => Horario.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'faltasTotales': faltasTotales,
      'usuarios': usuarios.map((u) => u.toJson()).toList(),
      'horarios': horarios.map((h) => h.toJson()).toList(),
    };
  }
}
