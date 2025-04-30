class HorarioHoy {
  final String horaEntrada;
  final String horaSalida;
  final Duration horasEstimadas;

  HorarioHoy({required this.horaEntrada, required this.horaSalida, required this.horasEstimadas});

  factory HorarioHoy.fromJson(Map<String, dynamic> json) {
    final partes = (json['horasEstimadas'] as String).split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    final segundos = int.parse(partes[2]);
    return HorarioHoy(
      horaEntrada: json['horaEntrada'],
      horaSalida: json['horaSalida'],
      horasEstimadas: Duration(hours: horas, minutes: minutos, seconds: segundos),
    );
  }
}
