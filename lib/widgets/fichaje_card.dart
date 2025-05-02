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
    // Día y fecha
    final DateTime? dia = fichaje.fechaHoraEntrada ?? fichaje.fechaHoraSalida;
    final String nombreDia = dia != null ? _getDiaSemana(dia.weekday) : "Desconocido";
    final String fechaStr  = dia != null ? "${dia.day}/${dia.month}/${dia.year}" : "";

    // Color y texto según totalTrabajado vs estimadas
    final colorTotal = totalTrabajado < horarioHoy.horasEstimadas
      ? Colors.red
      : Colors.green;
    final textoTotal = totalTrabajado == Duration.zero
      ? "No trabajado"
      : _formateaDuracion(totalTrabajado);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Día y fecha
          Row(
            children: [
              Text(nombreDia, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(fechaStr, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          // Horas estimadas
          const Text("Horas estimadas:", style: TextStyle(fontSize: 15)),
          Text(
            _formateaDuracion(horarioHoy.horasEstimadas),
            style: const TextStyle(color: Color(0xFFF57C00), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 3),

          // Horario
          Text("Horario: ${horarioHoy.horaEntrada} - ${horarioHoy.horaSalida}"),

          // Solo Total trabajado hoy
          const Text("Total horas hoy:", style: TextStyle(fontSize: 15)),
          Text(
            textoTotal,
            style: TextStyle(color: colorTotal, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formateaDuracion(Duration duracion) {
    String two(int n) => n.toString().padLeft(2, "0");
    final h = two(duracion.inHours);
    final m = two(duracion.inMinutes.remainder(60));
    final s = two(duracion.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  String _getDiaSemana(int weekday) {
    switch (weekday) {
      case 1: return "Lunes";
      case 2: return "Martes";
      case 3: return "Miércoles";
      case 4: return "Jueves";
      case 5: return "Viernes";
      case 6: return "Sábado";
      case 7: return "Domingo";
      default: return "Desconocido";
    }
  }
}
