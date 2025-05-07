import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/screens/user/justificar_ausencia_screen.dart';

class FichajeCard extends StatelessWidget {
  final Fichaje fichaje;
  final HorarioHoy horarioHoy;
  final Duration totalTrabajado; 
  final bool yaJustificado;


  const FichajeCard({
    super.key,
    required this.fichaje,
    required this.horarioHoy,
    required this.totalTrabajado,
    required this.yaJustificado,
  });

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Día y fecha
    final DateTime? dia = fichaje.fechaHoraEntrada ?? fichaje.fechaHoraSalida;
    final String nombreDia = dia != null
        ? _getDiaSemana(dia.weekday)
        : "Desconocido";
    final String fechaStr = dia != null
        ? "${dia.day}/${dia.month}/${dia.year}"
        : "";

    // Color y texto según totalTrabajado vs horas estimadas
    final bool sinTrabajo = totalTrabajado == Duration.zero;
    final bool porDebajo = !sinTrabajo && totalTrabajado < horarioHoy.horasEstimadas;

    final colorEstimadas = scheme.secondary;
    final colorTrabajadas = sinTrabajo || porDebajo ? scheme.error : scheme.primary;
    final textoTrabajadas = sinTrabajo ? "No trabajado" : _formateaDuracion(totalTrabajado);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
         boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              nombreDia,
              style: textTheme.titleMedium,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  fechaStr,
                  style: textTheme.bodySmall,
                ),
              ),
              Tooltip(
                message: yaJustificado
                  ? 'Ausencia registrada'
                  : 'Registrar ausencia',
                child: IconButton(
                  icon: const Icon(Icons.event_busy),
                  color: yaJustificado
                    ? scheme.secondaryContainer     
                    : scheme.error,
                  // Color cuando está deshabilitado
                  disabledColor: Colors.grey.shade400,
                  onPressed: yaJustificado
                  ? null             
                  : () {
                    if (dia != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => JustificarAusenciaScreen(usuario: fichaje.usuario,fecha: dia),),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),

          // Horas estimadas
          Text("Horas estimadas:", style: textTheme.bodySmall,),
          Text(
            _formateaDuracion(horarioHoy.horasEstimadas),
            style: textTheme.bodyMedium!
              .copyWith(color: colorEstimadas, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),

          // Total horas hoy
          const Text("Horas trabajadas:", style: TextStyle(fontSize: 15)),
          Text(
            textoTrabajadas,
             style: textTheme.bodyMedium!
              .copyWith(color: colorTrabajadas, fontWeight: FontWeight.bold),
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
