// lib/screens/horarios_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/horario.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/horario_service.dart';

class AdminHorariosScreen extends StatefulWidget {
  const AdminHorariosScreen({super.key});

  @override
  _AdminHorariosScreenState createState() => _AdminHorariosScreenState();
}

class _AdminHorariosScreenState extends State<AdminHorariosScreen> {
  late Future<void> _initData;
  List<Grupo> _grupos = [];
  List<Horario> _horarios = [];

  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final grupos   = await GrupoService().getGrupos();
    final horarios = await HorarioService.getHorarios();
    setState(() {
      _grupos   = grupos;
      _horarios = horarios;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<void>(
      future: _initData,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (_grupos.isEmpty) {
          return const Center(child: Text('No hay grupos.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _grupos.length,
          itemBuilder: (ctx, i) {
            final g = _grupos[i];
            // extraemos solo los horarios de este grupo
            final horariosDelGrupo = _horarios
                .where((horario) => horario.grupoId == g.id)
                .toList()
              ..sort((a, b) {
                // opcional: ordenar por día y hora de entrada
                final dayOrder = ['lunes','martes','miercoles','jueves','viernes'];
                final da = dayOrder.indexOf(a.dia.name);
                final db = dayOrder.indexOf(b.dia.name);
                if (da != db) return da.compareTo(db);
                return a.horaEntrada.compareTo(b.horaEntrada);
              });

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ExpansionTile(
                title: Text(
                  g.nombre,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                children: horariosDelGrupo.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay horarios asignados'),
                    ),
                  ]
                : horariosDelGrupo.map((horario) {
                    final entrada = horario.horaEntrada.substring(0, 5);
                    final salida  = horario.horaSalida .substring(0, 5);
                    final diaTxt  = horario.dia.name[0].toUpperCase() +
                      horario.dia.name.substring(1);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primary,
                        child: Text(
                          diaTxt.substring(0, 1),
                          style: TextStyle(color: scheme.onPrimary),
                        ),
                      ),
                      title: Text(
                        '$diaTxt: $entrada – $salida',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: scheme.primary),
                            onPressed: () => _editarHorario(horario),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: scheme.error),
                            onPressed: () async {
                              final confirmar = await _mostrarConfirmacion(context, horario, scheme);
                              if (confirmar == true) {
                                await HorarioService.eliminarHorario(horario.id);
                                await _cargarDatos();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Horario eliminado')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              )
            );
          },
        );
      },
    );
  }
  Future<void> _editarHorario(Horario horario) async {
    final scheme = Theme.of(context).colorScheme;
    // Parseamos los String "HH:mm:ss" a TimeOfDay
    TimeOfDay parseTime(String s) {
      final parts = s.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    TimeOfDay entrada = parseTime(horario.horaEntrada);
    TimeOfDay salida  = parseTime(horario.horaSalida);
    Grupo selectedGroup = _grupos.firstWhere((g) => g.id == horario.grupoId);

    final nuevoHorario = await showDialog<Horario>(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => StatefulBuilder(
        builder: (dctx, setDialog) {
          return AlertDialog(
            title: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  'Editar Horario',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            titlePadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de grupo
                DropdownButtonFormField<Grupo>(
                  value: selectedGroup,
                  decoration: const InputDecoration(labelText: 'Grupo'),
                  items: _grupos.map((g) {
                    return DropdownMenuItem(value: g, child: Text(g.nombre));
                  }).toList(),
                  onChanged: (g) => setDialog(() => selectedGroup = g!),
                ),
                const SizedBox(height: 16),
                // Entrada
                Row(
                  children: [
                    Expanded(child: Text('Entrada: ${entrada.format(context)}')),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: entrada,
                        );
                        if (picked != null) setDialog(() => entrada = picked);
                      },
                      child: const Text('Cambiar'),
                    ),
                  ],
                ),
                // Salida
                Row(
                  children: [
                    Expanded(child: Text('Salida: ${salida.format(context)}')),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: salida,
                        );
                        if (picked != null) setDialog(() => salida = picked);
                      },
                      child: const Text('Cambiar'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dctx).pop<Horario?>(null),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                ),
                onPressed: () {
                  // Construimos los Strings "HH:mm:ss"
                  String fmt(TimeOfDay t) =>
                    '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}:00';

                  final editado = Horario(
                    id:           horario.id,
                    dia:          horario.dia,
                    horaEntrada:  fmt(entrada),
                    horaSalida:   fmt(salida),
                    grupoId:      selectedGroup.id!,
                  );
                  Navigator.of(dctx).pop(editado);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    if (nuevoHorario != null) {
      try {
        await HorarioService.editarHorario(
          id: nuevoHorario.id,
          dia: nuevoHorario.dia.name,
          horaEntrada: nuevoHorario.horaEntrada,
          horaSalida: nuevoHorario.horaSalida,
          grupoId: nuevoHorario.grupoId
        );
        await _cargarDatos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horario actualizado')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<bool?> _mostrarConfirmacion(BuildContext context, Horario horario, ColorScheme scheme) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              'Eliminar Horario',
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        content: Text(
          '¿Está seguro de que deseas eliminar el \n'
          '"${horario.dia}"?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 12),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dctx, false),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              foregroundColor: scheme.primary,
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(dctx, true),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              backgroundColor: scheme.error,
              foregroundColor: scheme.onPrimary,
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
