import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';

class FichajeCard extends StatelessWidget {
  final Fichaje fichaje;
  final HorarioHoy horarioHoy;

  const FichajeCard({
    super.key,
    required this.fichaje,
    required this.horarioHoy,
  });

  @override
  Widget build(BuildContext context) {
    final Duration? horasTrabajadas = (fichaje.fechaHoraEntrada != null && fichaje.fechaHoraSalida != null)
        ? fichaje.fechaHoraSalida!.difference(fichaje.fechaHoraEntrada!)
        : null;

    final DateTime? dia = fichaje.fechaHoraEntrada ?? fichaje.fechaHoraSalida;
    final String nombreDia = dia != null ? _getDiaSemana(dia.weekday) : "Desconocido";
    final String fechaStr = dia != null ? "${dia.day}/${dia.month}/${dia.year}" : "";

    late Color colorHorasTrabajadas;
    late String textoHorasTrabajadas;
    if (horasTrabajadas == null) {
      colorHorasTrabajadas = Colors.red;
      textoHorasTrabajadas = "No trabajado";
    } else if (horasTrabajadas < horarioHoy.horasEstimadas) {
      colorHorasTrabajadas = Colors.red;
      textoHorasTrabajadas = _formateaDuracion(horasTrabajadas);
    } else {
      colorHorasTrabajadas = Colors.green;
      textoHorasTrabajadas = _formateaDuracion(horasTrabajadas);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                nombreDia,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                fechaStr,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text("Horas estimadas:", style: TextStyle(fontSize: 15)),
          Text(
            _formateaDuracion(horarioHoy.horasEstimadas),
            style: const TextStyle(
              color: Color(0xFFF57C00),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 3),
          Text("Horario: ${horarioHoy.horaEntrada} - ${horarioHoy.horaSalida}"),
          const SizedBox(height: 3),
          const Text("Horas trabajadas:", style: TextStyle(fontSize: 15)),
          Text(
            textoHorasTrabajadas,
            style: TextStyle(
              color: colorHorasTrabajadas,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formateaDuracion(Duration duracion) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final horas = twoDigits(duracion.inHours);
    final minutos = twoDigits(duracion.inMinutes.remainder(60));
    final segundos = twoDigits(duracion.inSeconds.remainder(60));
    return "$horas:$minutos:$segundos";
  }

  String _getDiaSemana(int weekday) {
    switch (weekday) {
      case 1:
        return "Lunes";
      case 2:
        return "Martes";
      case 3:
        return "Miércoles";
      case 4:
        return "Jueves";
      case 5:
        return "Viernes";
      case 6:
        return "Sábado";
      case 7:
        return "Domingo";
      default:
        return "Desconocido";
    }
  }
}
