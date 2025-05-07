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
    final int gid = json['id'] as int;
    return Grupo(
      id: gid,
      nombre: json['nombre'] as String,
      faltasTotales: json['faltasTotales'] as int,
      usuarios: (json['usuarios'] as List).map((u) => Usuario.fromJson(u as Map<String, dynamic>))
                  .toList(),
      horarios: (json['horarios'] as List<dynamic>).map((h) => Horario.fromJson(h as Map<String,dynamic>, gid))
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
