import 'package:riber_republic_fichaje_app/model/fichaje.dart';

class FichajeUtils {
  /// Filtra los fichajes de la lista que correspondan al día actual.
  static List<Fichaje> filtradosDeHoy(List<Fichaje> fichajes) {
    final ahora = DateTime.now();
    return fichajes.where((f) {
      final entrada = f.fechaHoraEntrada;
      if (entrada == null) return false;
      return entrada.year  == ahora.year && entrada.month == ahora.month && entrada.day   == ahora.day;

    }).toList();
  }
  /// Calcula el total de los fichajes de hoy cuya horaSalida sea distinto a null
  static Duration calcularFichajesHoy (List<Fichaje> fichajesFiltrados){
    return fichajesFiltrados.fold(Duration.zero, (sum, f) {
      if (f.fechaHoraSalida != null) {
        return sum + f.fechaHoraSalida!.difference(f.fechaHoraEntrada!);
      }
      return sum;
    });
  }
  static Duration calcularFichajesHoy2(List<Fichaje> fichajesHoy) {
    final ahora = DateTime.now();
    return fichajesHoy.fold(Duration.zero, (sum, f) {
      final inicio = f.fechaHoraEntrada;
      if (inicio == null) return sum;

      final fin = f.fechaHoraSalida ?? ahora;
      return sum + fin.difference(inicio);
    });
  }
}