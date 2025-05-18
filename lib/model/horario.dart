/// Modelo Horario
class Horario {
  /// Atributos
  final int id;
  final Dia dia;
  final String horaEntrada;
  final String horaSalida;
  final int grupoId;

  /// Constructor
  Horario({
    required this.id,
    required this.dia,
    required this.horaEntrada,
    required this.horaSalida,
    required this.grupoId,
  });

  /// Convierte el json al modelo Horario 
  factory Horario.fromJsonWithGroup(Map<String, dynamic> json, int grupoId) {
    return Horario(
      id: json['id'] as int,
      dia: Dia.values.firstWhere((e) => e.name == json['dia']),
      horaEntrada: json['horaEntrada'] as String,
      horaSalida: json['horaSalida'] as String,
      grupoId: grupoId,
    );
  }

   
  /// Convierte el json al modelo Horario 
  factory Horario.fromJson(Map<String, dynamic> json) {
    // El grupo puede venir o compo int o como {int, }
    final dynamic rawGrupo = json['grupo'] ?? json['grupoId'];
    late final int gid;
    if (rawGrupo is int) {
      gid = rawGrupo;
    } else if (rawGrupo is Map<String, dynamic>) {
      gid = rawGrupo['id'] as int;
    } else {
      throw FormatException('No aparece el grupoId en el JSON de Horario');
    }

    final diaEnum = Dia.values.firstWhere(
      (e) => e.name == (json['dia'] as String),
      orElse: () => throw FormatException('Día inválido: ${json['dia']}'),
    );

    return Horario(
      id: json['id'] as int,
      dia: diaEnum,
      horaEntrada: json['horaEntrada'] as String,
      horaSalida: json['horaSalida'] as String,
      grupoId: gid,
    );
  }

  /// Convierte del modelo Horario a Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dia': dia.name,
      'horaEntrada': horaEntrada,
      'horaSalida': horaSalida,
      'grupo': {
        'id': grupoId,
      },
    };
  }
}

enum Dia {
  lunes,
  martes,
  miercoles,
  jueves,
  viernes,
  sabado,
  domingo
}
