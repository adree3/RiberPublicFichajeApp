import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/exportar_excel.dart';
import 'package:riber_republic_fichaje_app/widgets/snackbar.dart';

class AdminGruposScreen extends StatefulWidget {
  const AdminGruposScreen({super.key});

  @override
  State<AdminGruposScreen> createState() => AdminGruposScreenState();
}

class AdminGruposScreenState extends State<AdminGruposScreen> {
  late Future<void> _initData;
  List<Grupo> _grupos = [];
  List<Usuario> _usuarios = [];
  List<Ausencia> _ausencias = [];
  final Set<int> _expandidos = {0};

  Grupo? _filtroGrupo;

  /// Al iniciar la pantalla carga los datos 
  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }
  /// Recibe los datos del Service y los setea
  Future<void> _cargarDatos() async {
    final grupos = await GrupoService().getGrupos();
    final usuarios = await UsuarioService().getUsuariosActivos();
    final ausencias = await AusenciaService().getAusencias();
    setState(() {
      _grupos = grupos;
      _usuarios = usuarios;
      _ausencias = ausencias;
    });
  }

  /// Recarga llamando a cargarDatos
  Future<void> _recargar() async {
    await _cargarDatos();
  }

  /// Calcula el color por el id recibido
  Color _avatarColor(int id) =>
      Colors.primaries[id % Colors.primaries.length];

  /// Filtra los grupos para el dropdownbutton
   List<Grupo> get _gruposFiltrados {
    if (_filtroGrupo != null) {
      return [_filtroGrupo!];
    }

    // Extraemos Sin Asignar
    final sinAsignar = _grupos.firstWhere((g) => g.nombre == 'Sin Asignar');

    // Todos los demás, ordenados alfabéticamente (case-insensitive)
    final otros = _grupos
      .where((g) => g.nombre != 'Sin Asignar')
      .toList()
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    // Añadimos Sin Asignar al final
    otros.add(sinAsignar);

    return otros;
  }

  /// Dialogo para exportar los grupos a Excel
  void _mostrarDialogoExportar() {
    Grupo? grupoSeleccionado;
    final scheme = Theme.of(context).colorScheme;
    final gruposConUsuarios = _grupos.where((g) =>
      _usuarios.any((u) => u.grupoId == g.id)
    ).toList();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialog) {
          return AlertDialog(
            title: const Text('Exportar grupos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Grupo?>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Elige un grupo',
                    border: OutlineInputBorder(),
                  ),
                  value: grupoSeleccionado,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('—')),
                    ...gruposConUsuarios.map((g) => DropdownMenuItem(value: g, child: Text(g.nombre))),
                  ],
                  onChanged: (g) => setDialog(() => grupoSeleccionado = g),
                ),
                 const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.layers, color: scheme.onPrimary),
                    label: Text('Exportar todos', style: TextStyle(color: scheme.onPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.secondary,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () {
                      Navigator.of(ctx2).pop();
                      ExcelExporter.exportarTodosGruposAExcel(
                        context: context,
                        grupos: _grupos,
                        usuarios: _usuarios,
                        ausencias: _ausencias,
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(onPressed: (){
                  Navigator.of(ctx2).pop();
                }, 
                child:Text("Cancelar")
              ),
              ElevatedButton(
                onPressed: grupoSeleccionado == null
                ? null
                : () async {
                    Navigator.of(ctx2).pop();

                    final usuariosGrupo = _usuarios
                      .where((u) => u.grupoId == grupoSeleccionado!.id)
                      .toList();
                    final ausenciasGrupo = _ausencias.where((a) =>
                      usuariosGrupo.any((u) => u.id == a.usuario.id)
                    ).toList();

                    await ExcelExporter.exportarGrupoAExcel(
                      context: context,
                      grupo: grupoSeleccionado!,
                      usuarios: usuariosGrupo,
                      ausencias: ausenciasGrupo,
                    );
                  },
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: scheme.primary,
                  minimumSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Exportar', style: TextStyle(color: scheme.onPrimary),),
              ),
            ],
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // indica si la plataforma en la que se esta mostrando es movil (android-IOS)
    final esMovil = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS);
    return FutureBuilder<void>(
      future: _initData,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Grupo?>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por grupo',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      value: _filtroGrupo,
                      items: [
                        const DropdownMenuItem<Grupo?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ..._grupos.map((g) => DropdownMenuItem<Grupo?>(
                              value: g,
                              child: Text(g.nombre),
                            )),
                      ],
                      onChanged: (g) => setState(() => _filtroGrupo = g),
                    ),
                  ),
                  // solo se muestra el exportar, si no es movil
                  if (!esMovil)...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: Icon(Icons.file_download_outlined, color: scheme.onPrimary,),
                      label: Text('Exportar', style: TextStyle(color: scheme.onPrimary),),
                      onPressed: () => _mostrarDialogoExportar(),
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        backgroundColor: scheme.primary,
                        minimumSize: const Size(100, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _recargar,
                // Lista de grupos
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, kBottomNavigationBarHeight + 16),
                  itemCount: _gruposFiltrados.length,
                  itemBuilder: (context, index) {
                    final grupo = _gruposFiltrados[index];
                    final estaAbierto = _expandidos.contains(index);
                    final usuarios = _usuarios
                        .where((u) => u.grupoId == grupo.id)
                        .toList();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ExpansionTile(
                        key: ValueKey(grupo.id),
                        initiallyExpanded: estaAbierto,
                        onExpansionChanged: (open) {
                          setState(() {
                            if (open) _expandidos.add(index);
                            else _expandidos.remove(index);
                          });
                        },
                        leading: CircleAvatar(
                          child: Text(grupo.nombre[0]),
                          backgroundColor: scheme.primary,
                        ),
                        title: Text(
                          grupo.nombre,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: scheme.primary),
                              onPressed: () async {
                                await _EditarGrupoDialogo(grupo);
                              },
                            ),
                            if (grupo.nombre!= 'Sin Asignar')
                              IconButton(
                                icon: Icon(Icons.delete, color: scheme.error),
                                onPressed: () async {
                                  final confirmar = await _mostrarConfirmacion(context, grupo, scheme);
                                  if (confirmar == true) {
                                    await GrupoService.eliminarGrupo(grupo.id!);
                                    AppSnackBar.show(
                                      context,
                                      message: 'Grupo eliminado',
                                      backgroundColor: Colors.green.shade600,
                                      icon: Icons.check_circle,
                                    );
                                    _recargar();
                                  }
                                },
                              ),
                            Icon(
                              estaAbierto ? Icons.expand_less : Icons.expand_more,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        children: <Widget>[  
                          if (usuarios.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No hay miembros en este grupo'),
                            )
                          else ...usuarios.asMap().entries.map((entry) {
                            final miIndex = entry.key;
                            final usuario = entry.value;
                            final iniciales =
                                '${usuario.nombre[0]}${usuario.apellido1[0]}'.toUpperCase();
                            final numAusencias = _ausencias
                                .where((ausencia) => 
                                  ausencia.usuario.id == usuario.id &&
                                  ausencia.estado != EstadoAusencia.aceptada
                                ).length;

                            return ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${miIndex + 1}.',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor:_avatarColor(usuario.id),
                                    child: Text(
                                      iniciales,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text('${usuario.nombre} ${usuario.apellido1} ${usuario.apellido2??""}'),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(usuario.email),
                                  Text('Ausencias: $numAusencias'),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Dialogo para confirmar el eliminar un grupo
  Future<bool?> _mostrarConfirmacion(BuildContext context, Grupo grupo, ColorScheme scheme) {
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
            'Eliminar Grupo',
            style: TextStyle(
              color: scheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      content: Text(
        '¿Está seguro de que deseas eliminar\n'
        '"${grupo.nombre}"?',
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dctx, false),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size.fromHeight(40),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dctx, true),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: scheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size.fromHeight(40),
                ),
                child: Text(
                  'Eliminar',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

  /// Dialogo para editar un grupo
  Future<void> _EditarGrupoDialogo(Grupo grupo) async {
    final scheme = Theme.of(context).colorScheme;
    final nombreCtrl = TextEditingController(text: grupo.nombre);
    final _formKey = GlobalKey<FormState>();

    final buscarCtrl = TextEditingController();
    final buscarFocus = FocusNode();
    final suggestionsCtrl = SuggestionsController<Usuario>();

    List<Usuario> usuarios = _usuarios.where((u) => u.grupoId == grupo.id).toList();

    final esMovil = MediaQuery.of(context).size.width < 600;
    final dialogoAncho = esMovil ? 320.0 : 380.0;
    final dialogoAltura = esMovil ? 350.0 : 500.0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 100),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            titlePadding: EdgeInsets.zero,
            title: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Text('Editar Grupo',
                    style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold)),
              ),
            ),
            content: SizedBox(
              width: dialogoAncho,
              height: dialogoAltura,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nombre del grupo
                    TextFormField(
                      controller: nombreCtrl,
                      enabled: grupo.nombre != 'Sin Asignar',
                      decoration: InputDecoration(
                        labelText: 'Nombre del grupo',
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (value) {
                        final nuevo = value?.trim() ?? '';
                        if (nuevo.isEmpty) {
                          return 'El nombre no puede estar vacío';
                        }
                        final duplicado = _grupos.any((g) =>
                          g.nombre.toLowerCase() == nuevo.toLowerCase() && g.id != grupo.id
                        );
                        if (duplicado) {
                          return 'Ya existe un grupo con ese nombre';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // TypeAhead (un textfield con recomendaciones de usuarios)
                    TypeAheadField<Usuario>(
                      suggestionsController: suggestionsCtrl,
                      controller: buscarCtrl,
                      focusNode: buscarFocus,
                      builder: (context, textCtrl, focusNode) {
                        return TextField(
                          controller: textCtrl,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Añadir usuario',
                            prefixIcon: Icon(Icons.search, color: scheme.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onTap: () => suggestionsCtrl.open(),
                        );
                      },
                      // aqui lo hace
                      suggestionsCallback: (input) {
                        final q = input.toLowerCase();
                        return _usuarios.where((u) =>
                          !usuarios.any((m) => m.id == u.id) &&
                          u.email.toLowerCase().contains(q)
                        ).toList();
                      },
                      itemBuilder: (ctx, usuario) {
                        final nombreGrupo = _grupos
                            .firstWhere((g) => g.id == usuario.grupoId)
                            .nombre;
                        return ListTile(
                          title: Text(usuario.email),
                          subtitle: Text(nombreGrupo,
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                        );
                      },
                      onSelected: (usuario) {
                        setDialog(() {
                          usuarios.add(usuario);
                          buscarCtrl.clear();
                        });
                        suggestionsCtrl.close(retainFocus: true);
                        suggestionsCtrl.open(gainFocus: false);
                        suggestionsCtrl.refresh();
                      },
                      emptyBuilder: (_) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No se encontraron alumnos'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Usuario actuales',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: scheme.primary)),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      // Lista de ususarios de este grupo
                      child: ListView.separated(
                        itemCount: usuarios.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final usuario = usuarios[i];
                          return ListTile(
                            title: Text('${i+1}.  ${usuario.email}'),
                            trailing: IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: scheme.error),
                              onPressed: () {
                                setDialog(() {
                                  usuarios.removeAt(i);
                                });
                                if (buscarFocus.hasFocus) {
                                  suggestionsCtrl.close(retainFocus: true);
                                  suggestionsCtrl.open(gainFocus: false);
                                  suggestionsCtrl.refresh();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Cancelar',
                                style: TextStyle(
                                    color: scheme.error,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: scheme.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Actualizar',
                                style: TextStyle(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              final nuevoNombre = nombreCtrl.text.trim();
                              final usuariosIds =
                                  usuarios.map((u) => u.id).toList();
                              try {
                                await GrupoService.actualizarGrupo(
                                    id: grupo.id!,
                                    nombre: nuevoNombre,
                                    usuariosIds: usuariosIds);
                                Navigator.of(ctx).pop();
                                await _recargar();
                                AppSnackBar.show(
                                  context,
                                  message: 'Grupo actualizado correctamente',
                                  backgroundColor: Colors.green.shade600,
                                  icon: Icons.check_circle,
                                );
                              } catch (e) {
                                AppSnackBar.show(
                                  context,
                                  message: 'Error al actualizar el grupo',
                                  backgroundColor: Colors.red.shade600,
                                  icon: Icons.error_outline,
                                );
                              }
                            },
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

  /// Dialogo para crear un grupo
  Future<void> crearGrupoDialogo() async {
    final scheme = Theme.of(context).colorScheme;
    final nombreCtrl = TextEditingController();
    final buscarCtrl = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final buscarFocus = FocusNode();
    final suggestionsCtrl = SuggestionsController<Usuario>();
    List<Usuario> usuarios = [];

    final esMovil = MediaQuery.of(context).size.width < 600;
    final dialogoAncho = esMovil ? 320.0 : 380.0;
    final dialogoAltura = esMovil ? 350.0 : 500.0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  'Crear Grupo',
                  style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            content: SizedBox(
              width: dialogoAncho,
              height: dialogoAltura,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre del grupo',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (value) {
                        final nuevo = value?.trim() ?? '';
                        if (nuevo.isEmpty) {
                          return 'El nombre no puede estar vacío';
                        }
                        final duplicado = _grupos.any((g) =>
                          g.nombre.toLowerCase() == nuevo.toLowerCase()
                        );
                        if (duplicado) {
                          return 'Ya existe un grupo con ese nombre';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    // El mismo que el de editar
                    TypeAheadField<Usuario>(
                      suggestionsController: suggestionsCtrl,
                      controller: buscarCtrl,
                      focusNode: buscarFocus,
                      builder: (context, textCtrl, focusNode) {
                        return TextField(
                          controller: textCtrl,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Añadir usuario',
                            prefixIcon: Icon(Icons.search, color: scheme.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onTap: () => suggestionsCtrl.open(),
                        );
                      },
                      suggestionsCallback: (input) {
                        final q = input.toLowerCase();
                        return _usuarios.where((u) =>
                          !usuarios.any((m) => m.id == u.id) &&
                          u.email.toLowerCase().contains(q)
                        ).toList();
                      },
                      itemBuilder: (ctx, usuario) {
                        final nombreGrupo = _grupos
                            .firstWhere((g) => g.id == usuario.grupoId)
                            .nombre;
                        return ListTile(
                          title: Text(usuario.email),
                          subtitle: Text(nombreGrupo,
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                        );
                      },
                      onSelected: (usuario) {
                        setDialog(() {
                          usuarios.add(usuario);
                          buscarCtrl.clear();
                        });
                        suggestionsCtrl.close(retainFocus: true);
                        suggestionsCtrl.open(gainFocus: false);
                        suggestionsCtrl.refresh();
                      },
                      emptyBuilder: (_) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No se encontraron alumnos'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Usuarios seleccionados',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: usuarios.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final usuario = usuarios[i];
                          return ListTile(
                            title: Text('${i+1}.  ${usuario.email}'),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle, color: scheme.error),
                              onPressed: () {
                                setDialog(() {
                                  usuarios.removeAt(i);
                                  if (buscarFocus.hasFocus) {
                                    suggestionsCtrl.close();
                                    suggestionsCtrl.refresh();
                                    suggestionsCtrl.open();
                                  }
                                });
                              }
                            )
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: scheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              final nombre     = nombreCtrl.text.trim();
                              final usuariosIds = usuarios.map((u) => u.id).toList();
                              try {
                                await GrupoService.crearGrupo(
                                  nombre: nombre,
                                  usuariosIds: usuariosIds,
                                );
                                Navigator.of(ctx).pop();
                                await _recargar();
                                AppSnackBar.show(
                                  context,
                                  message: 'Grupo creado',
                                  backgroundColor: Colors.green.shade600,
                                  icon: Icons.check_circle,
                                );
                              } catch (e) {
                                AppSnackBar.show(
                                  context,
                                  message: 'Error al crear el grupo',
                                  backgroundColor: Colors.red.shade600,
                                  icon: Icons.error_outline,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: scheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Crear',
                              style: TextStyle(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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