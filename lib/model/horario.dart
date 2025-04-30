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

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'],
      dia: Dia.values.firstWhere((e) => e.name == json['dia']),
      horaEntrada: json['horaEntrada'],
      horaSalida: json['horaSalida'],
      grupoId: json['grupo']['id'], // Asumiendo que grupo viene como objeto
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
