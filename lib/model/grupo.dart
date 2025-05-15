import 'usuario.dart';
import 'horario.dart';
/// Modelo Grupo
class Grupo {
  /// Atributos
  final int? id;
  final String nombre;
  final int faltasTotales;
  final List<Usuario> usuarios;
  final List<Horario> horarios;

  /// Constructor
  Grupo({
    this.id,
    required this.nombre,
    required this.faltasTotales,
    required this.usuarios,
    required this.horarios,
  });


  /// Convierte el json al modelo Grupo 
  factory Grupo.fromJson(Map<String, dynamic> json) {
    final gid = json['id'] as int;

    // si viene el objeto completo lo mapeamos y sino una lista vacia
    final usuarios = (json['usuarios'] as List<dynamic>?)
            ?.map((u) => Usuario.fromJson(u as Map<String, dynamic>))
            .toList() ??
        <Usuario>[]; 

    // lo mismo para horarios
    final horarios = (json['horarios'] as List<dynamic>?)
            ?.map((h) => Horario.fromJsonWithGroup(h as Map<String, dynamic>, gid))
            .toList() ??
        <Horario>[];

    return Grupo(
      id: gid,
      nombre: json['nombre'] as String,
      faltasTotales: json['faltasTotales'] as int? ?? 0,
      usuarios: usuarios,
      horarios: horarios,
    );
  }


  /// Convierte del modelo Grupo a Json
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
