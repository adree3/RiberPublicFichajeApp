import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';

class FichajeDiaCard extends StatelessWidget {
  final DateTime fecha;
  final HorarioHoy horarioHoy;
  final Duration totalTrabajado;

  const FichajeDiaCard({
    super.key,
    required this.fecha,
    required this.horarioHoy,
    required this.totalTrabajado,
  });

  @override
  Widget build(BuildContext context) {
    final nombreDia = _getDiaSemana(fecha.weekday);
    final fechaStr  = "${fecha.day}/${fecha.month}/${fecha.year}";

    final estimadas = horarioHoy.horasEstimadas;
    final sinTrabajo = totalTrabajado == Duration.zero;
    final colorTotal = sinTrabajo || totalTrabajado < estimadas 
        ? Colors.red 
        : Colors.green;
    final textoTotal = sinTrabajo 
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
          // Encabezado
          Row(
            children: [
              Text(nombreDia, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(fechaStr, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            ],
          ),
          const Divider(height: 20),

          // Horas estimadas
          const Text("Horas estimadas:", style: TextStyle(fontSize: 15)),
          Text(_formateaDuracion(estimadas),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF57C00))
          ),

          const SizedBox(height: 10),

          // Total horas trabajadas
          const Text("Total horas trabajadas:", style: TextStyle(fontSize: 15)),
          Text(textoTotal,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorTotal)
          ),
        ],
      ),
    );
  }

  String _formateaDuracion(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  String _getDiaSemana(int w) {
    const nombres = ["Desconocido","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"];
    return nombres[w];
  }
}
