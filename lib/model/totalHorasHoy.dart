/// Dto de faltas
class TotalHorasHoy {
  /// Atributo
  final String totalHoras;

  /// Constructor
  TotalHorasHoy({ required this.totalHoras });

  /// Convierte el json al modelo TotalHorasHoy 
  factory TotalHorasHoy.fromJson(Map<String, dynamic> json) =>
    TotalHorasHoy(totalHoras: json['totalHoras'] as String);
}