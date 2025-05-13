class Horario {
  final int id;
  final Dia dia;
  final String horaEntrada;
  final String horaSalida;
  final int grupoId;

  Horario({
    required this.id,
    required this.dia,
    required this.horaEntrada,
    required this.horaSalida,
    required this.grupoId,
  });

  factory Horario.fromJsonWithGroup(Map<String, dynamic> json, int grupoId) {
    return Horario(
      id: json['id'] as int,
      dia: Dia.values.firstWhere((e) => e.name == json['dia']),
      horaEntrada: json['horaEntrada'] as String,
      horaSalida: json['horaSalida'] as String,
      grupoId: grupoId,
    );
  }

   /// De un solo parámetro, extrae el grupoId aunque venga como int o como objeto
  factory Horario.fromJson(Map<String, dynamic> json) {
    // ’grupo’ puede venir como:
    //  • int                →  3
    //  • Map<String, dynamic> → { 'id': 3 }
    //  • o incluso un campo 'grupoId'
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
      id:          json['id']           as int,
      dia:         diaEnum,
      horaEntrada: json['horaEntrada']  as String,
      horaSalida:  json['horaSalida']   as String,
      grupoId:     gid,
    );
  }

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
}
