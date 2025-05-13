import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';

class AdminGruposScreen extends StatefulWidget {
  const AdminGruposScreen({super.key});

  @override
  State<AdminGruposScreen> createState() => _AdminGruposScreenState();
}

class _AdminGruposScreenState extends State<AdminGruposScreen> {
  late Future<void> _initData;
  List<Grupo> _grupos = [];
  List<Usuario> _usuarios = [];
  List<Ausencia> _ausencias = [];

  Grupo? _filtroGrupo;

  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final grupos = await GrupoService().getGrupos();
    final usuarios = await UsuarioService().getUsuarios();
    final ausencias = await AusenciaService().getAusencias();
    setState(() {
      _grupos = grupos;
      _usuarios = usuarios;
      _ausencias = ausencias;
    });
  }

  Future<void> _recargar() async => await _cargarDatos();

  Color _avatarColor(int id) =>
      Colors.primaries[id % Colors.primaries.length];

  List<Grupo> get _gruposFiltrados {
    if (_filtroGrupo == null) return _grupos;
    return _grupos.where((g) => g.id == _filtroGrupo!.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: _recargar,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _gruposFiltrados.length,
                  itemBuilder: (context, index) {
                    final grupo = _gruposFiltrados[index];
                    final usuarios = _usuarios
                        .where((u) => u.grupoId == grupo.id)
                        .toList();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ExpansionTile(
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
                                await _showEditGroupDialog(grupo);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: scheme.error),
                              onPressed: () async {
                                final confirmar = await _mostrarConfirmacion(context, grupo, scheme);
                                if (confirmar == true) {
                                  await GrupoService.eliminarGrupo(grupo.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Grupo eliminado')),
                                  );
                                  _recargar();
                                }
                              },
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
                                '${usuario.nombre[0]}${usuario.apellido1[0]}';
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
                                    backgroundColor:
                                        _avatarColor(usuario.id),
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
          '¿Está seguro de que deseas eliminar \n'
          '"${grupo.nombre}"?',
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

  Future<void> _showEditGroupDialog(Grupo grupo) async {
    final scheme = Theme.of(context).colorScheme;
    final nombreCtrl = TextEditingController(text: grupo.nombre);
    final buscarCtrl = TextEditingController();
    final _formKey   = GlobalKey<FormState>();

    List<Usuario> usuarios = _usuarios.where((u) => u.grupoId == grupo.id).toList();

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
                borderRadius:const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Text('Editar Grupo',style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold)),
              ),
            ),
            content: SizedBox(
              width: 300,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreCtrl,
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
                            g.nombre.toLowerCase() == nuevo.toLowerCase()
                            && g.id != grupo.id
                          );
                          if (duplicado) {
                            return 'Ya existe un grupo con ese nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                
                      TypeAheadField<Usuario>(
  // 1) Aquí contruyes tú mismo el TextField:
  builder: (BuildContext context, TextEditingController tc, FocusNode fn) {
    return TextField(
      controller: tc,
      focusNode: fn,
      decoration: InputDecoration(
        labelText: 'Añadir usuario',
        prefixIcon: Icon(Icons.search, color: scheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  },
  // 2) Callback de sugerencias (igual que antes)
  suggestionsCallback: (input) {
    final q = input.toLowerCase();
    return _usuarios.where((usuario) {
      if (usuarios.any((miembro) => miembro.id == usuario.id)) return false;
      return usuario.email.toLowerCase().contains(q);
    }).toList();
  },
  // 3) Cómo pintar cada sugerencia
  itemBuilder: (BuildContext ctx, Usuario usuario) {
    return ListTile(
      title: Text(usuario.email),
    );
  },
  // 4) ¡OJO! el parámetro ya no es onSuggestionSelected, sino onSelected:
  onSelected: (Usuario usuario) {
    setDialog(() {
      usuarios.add(usuario);
    });
    buscarCtrl.clear();
  },
  // 5) Y noItemsFoundBuilder ahora es emptyBuilder
  emptyBuilder: (BuildContext ctx) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('No se encontraron alumnos'),
    );
  },
),


                      const SizedBox(height: 24),
                
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Usuario actuales', style: TextStyle(fontWeight: FontWeight.w600, color: scheme.primary)),
                      ),
                      const SizedBox(height: 8),
                
                      Column(
                        children: usuarios.map((usuario) {
                          return ListTile(
                            title: Text(usuario.email),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle, color:scheme.error),
                              onPressed: () {
                                setDialog(() {
                                  usuarios.remove(usuario);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---- ACCIONES ----
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: (){
                  Navigator.of(ctx).pop();
                }, 
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Cancelar', style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: scheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Guardar', style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final nuevoNombre = nombreCtrl.text.trim();
                  final usuariosIds = usuarios.map((u) => u.id).toList();
                  try { 
                    await GrupoService.actualizarGrupo(id: grupo.id!, nombre: nuevoNombre,usuariosIds: usuariosIds);
                    Navigator.of(ctx).pop();
                    await _recargar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Grupo actualizado')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar: $e')),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}