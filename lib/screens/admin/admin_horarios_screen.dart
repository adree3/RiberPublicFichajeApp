import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/horario.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/horario_service.dart';

class AdminHorariosScreen extends StatefulWidget {
  const AdminHorariosScreen({super.key});

  @override
  AdminHorariosScreenState createState() => AdminHorariosScreenState();
}

class AdminHorariosScreenState extends State<AdminHorariosScreen> {
  late Future<void> _initData;
  List<Grupo> _grupos = [];
  List<Horario> _horarios = [];
  
  Grupo? _filtroGrupo;
  Dia? _filtroDia;

  /// Al iniciar la pantalla carga los datos
  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }

  /// Recibe del service los grupos y horarios y comprueba si teniamos un filtro de grupo
  /// para utilizar la nueva instancia
  Future<void> _cargarDatos() async {
    final grupos   = await GrupoService().getGrupos();
    final horarios = await HorarioService.getHorarios();
    setState(() {
      _grupos   = grupos;
      _horarios = horarios;
    });
    if (_filtroGrupo != null) {
      final idAnterior = _filtroGrupo!.id;
      final encontrados = _grupos.where((g) => g.id == idAnterior).toList();
      _filtroGrupo = encontrados.isNotEmpty ? encontrados.first : null;
    }
  }

  /// Calcula el color por el id recibido
  Color _avatarColor(int id) =>
    Colors.primaries[id % Colors.primaries.length];

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
        // filtra los grupos por el filtro y de esos filtra los que tengan al menos un horario 
        final gruposFiltrados = _grupos.where((g) {
          if (_filtroGrupo != null && g.id != _filtroGrupo!.id) return false;
          return _horarios.any((h) =>
            h.grupoId == g.id
            && (_filtroDia == null || h.dia == _filtroDia)
          );
        }).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Filtro de Grupo
                  Expanded(
                    child: DropdownButtonFormField<Grupo?>(
                      isExpanded: true,
                      value: _filtroGrupo,
                      decoration: InputDecoration(
                        labelText: 'Filtrar por Grupo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todos')),
                        ..._grupos.map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.nombre),
                        )),
                      ],
                      onChanged: (g) => setState(() => _filtroGrupo = g),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filtro del dia
                  Expanded(
                    child: DropdownButtonFormField<Dia?>(
                      isExpanded: true,   
                      value: _filtroDia,
                      decoration: InputDecoration(
                        labelText: 'Filtrar por Día',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todos')),
                        ...Dia.values.map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                        )),
                      ],
                      onChanged: (d) => setState(() => _filtroDia = d),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, kBottomNavigationBarHeight + 16),
                itemCount: gruposFiltrados.length,
                itemBuilder: (ctx, i) {
                  final grupo = gruposFiltrados[i];
                  // cogemos solo los horarios de este grupo
                  final horariosDelGrupo = _horarios
                      .where((horario) => horario.grupoId == grupo.id&& (_filtroDia == null || horario.dia == _filtroDia))
                      .toList()
                    ..sort((a, b) {
                      // Se ordena la lista de lunes a viernes
                      final diaOrden = ['lunes','martes','miercoles','jueves','viernes'];
                      final da = diaOrden.indexOf(a.dia.name);
                      final db = diaOrden.indexOf(b.dia.name);
                      if (da != db) return da.compareTo(db);
                      return a.horaEntrada.compareTo(b.horaEntrada);
                    });
              
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ExpansionTile(
                      leading: CircleAvatar(
                          backgroundColor: scheme.primary,
                          child: Text(
                            grupo.nombre.substring(0,1).toUpperCase(),
                            style: TextStyle(color: scheme.onPrimary),
                          ),
                        ),
                      title: Text(
                        grupo.nombre,
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
                      : horariosDelGrupo
                        .asMap()
                        .entries
                        .map((entry) {
                          final idx = entry.key;
                          final horario = entry.value;
                          final entrada = horario.horaEntrada.substring(0, 5);
                          final salida = horario.horaSalida.substring(0, 5);
                          final diaTxt = horario.dia.name[0].toUpperCase() +
                            horario.dia.name.substring(1);
              
                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${idx + 1}.',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor: _avatarColor(horario.id),
                                  child: Text(
                                    diaTxt.substring(0, 1),
                                    style: TextStyle(color: scheme.onPrimary),
                                  ),
                                ),
                              ],
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
                        }
                      ).toList(),
                    )
                  );
                },
              ),
            )
          ]
        );
      },
    );
  }
  /// Dialogo para editar un horario
  Future<void> _editarHorario(Horario horario) async {
    final scheme = Theme.of(context).colorScheme;
    final _formKey = GlobalKey<FormState>();
    // Parsea de "HH:mm:ss" a TimeOfDay
    TimeOfDay parseTime(String s) {
      final parts = s.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    TimeOfDay entrada = parseTime(horario.horaEntrada);
    TimeOfDay salida  = parseTime(horario.horaSalida);
    Grupo grupoSeleccionado = _grupos.firstWhere((g) => g.id == horario.grupoId);
    Dia? diaSeleccionado = horario.dia;

    final nuevoHorario = await showDialog<Horario>(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => StatefulBuilder(
        builder: (dctx, setDialog) {
          // comprueba que la hora salida sea posterior a la de entrada
          final horaValida = salida.hour < entrada.hour || (salida.hour == entrada.hour && salida.minute <= entrada.minute);

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
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Grupo>(
                    value: grupoSeleccionado,
                    decoration: const InputDecoration(labelText: 'Grupo',border: OutlineInputBorder(),),
                    items: _grupos.map((g) {
                      return DropdownMenuItem(value: g, child: Text(g.nombre));
                    }).toList(),
                    onChanged: (g) => setDialog(() => grupoSeleccionado = g!),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<Dia>(
                    value: diaSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Día',
                      border: OutlineInputBorder(),
                    ),
                    items: Dia.values.map((d) =>
                      DropdownMenuItem(
                        value: d,
                        child: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                      )
                    ).toList(),
                    onChanged: (d) => setDialog(() => diaSeleccionado = d),
                    validator: (d) {
                      if (d == null) return 'Selecciona un día';
                      // comprueba que no haya otro horario con el mismo grupo y día
                      final existe = _horarios.any((h) =>
                        h.grupoId == grupoSeleccionado.id &&
                        h.dia == d &&
                        h.id != horario.id
                      );
                      if (existe) return 'Ya existe un horario para ese día';
                      return null;
                    },
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
                  if (horaValida)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'La hora de salida debe ser posterior a la de entrada',
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(dctx).pop<Horario?>(null),
                child: const Text('Cancelar'),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: scheme.primary
                ),
                 onPressed: () {
                  if (_formKey.currentState!.validate() || horaValida) {
                    if (!_formKey.currentState!.validate()) return;
                    // Parsea de TimeOfDay a "HH:mm:ss"  
                    String fmt(TimeOfDay t) =>
                      '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}:00';
                    final h = Horario(
                      id: horario.id,
                      grupoId: grupoSeleccionado.id!,
                      dia: diaSeleccionado!,
                      horaEntrada: fmt(entrada),
                      horaSalida: fmt(salida),
                    );
                    Navigator.of(dctx).pop(h);
                  }
                },
                child: Text('Actualizar', style: TextStyle(color: scheme.onPrimary)),
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
  /// Dialogo para confirmar elimar un horario
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

  /// Dialogo para crear un dialogo
  Future<void> crearHorarioDialogo() async {
    final scheme = Theme.of(context).colorScheme;
    final _formKey = GlobalKey<FormState>();

    Dia? diaSeleccionado;
    Grupo? grupoSeleccionado;
    TimeOfDay entrada =TimeOfDay(hour: 9, minute: 0);;
    TimeOfDay salida= TimeOfDay(hour: 15, minute: 0);;
    String? diaError;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => StatefulBuilder(
        builder: (dctx, setDialog) {
          final horaInvalida = salida.hour < entrada.hour ||
            (salida.hour == entrada.hour && salida.minute <= entrada.minute);
          return AlertDialog(
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
                  'Crear Horario',
                  style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Grupo>(
                      decoration: const InputDecoration(labelText: 'Grupo',border: OutlineInputBorder(),),
                      items: _grupos
                          .map((g) => DropdownMenuItem(value: g, child: Text(g.nombre)))
                          .toList(),
                      onChanged: (grupo) {
                        setDialog(() {
                          grupoSeleccionado = grupo;
                        });
                      },
                      validator: (value) {
                        if (value == null){
                          return 'Selecciona un grupo';
                        }
                        return null;
                      }
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Dia>(
                      decoration: const InputDecoration(labelText: 'Día',border: OutlineInputBorder(),),
                      items: Dia.values
                          .map((dia) => DropdownMenuItem(value: dia, child: Text(dia.name)))
                          .toList(),
                      onChanged: (dia) {
                        setDialog(() {
                          diaSeleccionado = dia;
                          diaError = null;
                        });
                      },
                      validator: (value) {
                        if (value == null){
                          return 'Selecciona un día';
                        }
                        return null;
                      }
                    ),
                    if (diaError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(diaError!,
                          style: TextStyle(color: scheme.error, fontSize: 12)),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Text('Entrada:  ${entrada.format(context)}')),
                        TextButton(
                          onPressed: () async {
                            final pick = await showTimePicker(
                              context: context,
                              initialTime: entrada,
                            );
                            if (pick != null){
                              setDialog(() {
                                entrada = pick;
                              });
                            }
                          },
                          child: const Text('Cambiar'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Text('Salida: ${salida.format(context)}')),
                        TextButton(
                          onPressed: () async {
                            final pick = await showTimePicker(
                              context: context,
                              initialTime: salida,
                            );
                            if (pick != null){
                              setDialog(() {
                                entrada = pick;
                              });
                            }
                          },
                          child: const Text('Cambiar'),
                        ),
                      ],
                    ),
                    if (horaInvalida)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'La salida debe ser posterior a la entrada',
                          style: TextStyle(color: scheme.error),
                        ),
                      ),
                    SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(dctx),
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Cancelar', style: TextStyle(color: scheme.error)),
                          ),
                        ),
                        SizedBox(width: 8,),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (grupoSeleccionado == null ||diaSeleccionado == null || horaInvalida)
                            ? null
                            : () async {
                                final existe = _horarios.any((h) =>
                                  h.grupoId == grupoSeleccionado!.id && h.dia == diaSeleccionado);
                                if (existe) {
                                  setDialog(() {
                                    diaError = 'Ya existe un horario para ese día';
                                  });
                                  return;
                                }
                                String fmt(TimeOfDay t) =>
                                  '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}:00';

                                try {
                                  await HorarioService.crearHorario(
                                    grupoId: grupoSeleccionado!.id!,
                                    dia: diaSeleccionado!.name,
                                    horaEntrada: fmt(entrada),
                                    horaSalida: fmt(salida),
                                  );
                                  Navigator.pop(dctx);
                                  await _cargarDatos();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Horario creado')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al crear horario: $e')),
                                  );
                                }
                              },
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: scheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Crear', style: TextStyle(color: scheme.onPrimary)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
