class TotalHorasHoy {
  final String totalHoras;

  TotalHorasHoy({ required this.totalHoras });

  factory TotalHorasHoy.fromJson(Map<String, dynamic> json) =>
    TotalHorasHoy(totalHoras: json['totalHoras'] as String);
}