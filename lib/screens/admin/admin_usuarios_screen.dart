import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/admin_crear_usuario_dialog.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/admin_editar_usuario_dialog.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});
  @override
  State<AdminUsuariosScreen> createState() => AdminUsuariosScreenState();
}

class AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  late Future<void> _initData;
  List<Usuario> _usuarios = [];
  List<Grupo> _grupos = [];

  final _emailFiltroCtrl = TextEditingController();
  Grupo? _filtrarGrupo;

  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final grupos = await GrupoService().getGrupos();
    final usuarios = await UsuarioService().getUsuarios();
    setState(() {
      _grupos = grupos;
      _usuarios = usuarios;
    });
  }

  Future<void> _recargar() async => _cargarDatos();

  List<Usuario> get _filtros {
    return _usuarios.where((usuario) {
      final emailIgual = usuario.email
          .toLowerCase()
          .contains(_emailFiltroCtrl.text.toLowerCase());
      final grupoIgual = _filtrarGrupo == null
          ? true
          : usuario.grupoId == _filtrarGrupo!.id;
      return emailIgual && grupoIgual;
    }).toList();
  }

  Color _avatarColor(int id) =>
      Colors.primaries[id % Colors.primaries.length];

  void onCreate() {
    final scheme = Theme.of(context).colorScheme;
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                'Crear Usuario',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            width: 360,
            child: AdminUsuarioCrearDialogo(
              onCreated: () => Navigator.of(context).pop(true),
            ),
          ),
        );
      },
    ).then((created) {
      if (created == true) {
        _recargar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado correctamente')),
        );
      }
    });
  }

  void _onEdit(Usuario usuario, ColorScheme scheme) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                'Editar Usuario',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            width: 360,
            child: AdminUsuarioEditarDialog(
              usuario: usuario,
              onEdited: () => Navigator.of(context).pop(true),
            ),
          ),
        );
      },
    ).then((edited) {
      if (edited == true) {
        _recargar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado')),
        );
      }
    });
  }
  Future<bool?> _mostrarConfirmacion(BuildContext context, Usuario usuario, ColorScheme scheme) {
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
              'Eliminar usuario',
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        content: Text(
          '¿Está seguro de que deseas eliminar a\n'
          '${usuario.email}?',
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<void>(
      future: _initData,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailFiltroCtrl,
                      decoration: InputDecoration(
                        labelText: 'Filtrar por email',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<Grupo>(
                      isExpanded: true,
                      value: _filtrarGrupo,
                      decoration: InputDecoration(
                        labelText: 'Grupo',
                        prefixIcon: const Icon(Icons.group),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      items: [
                        const DropdownMenuItem<Grupo>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ..._grupos.map((grupo) => DropdownMenuItem<Grupo>(
                              value: grupo,
                              child: Text(grupo.nombre),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filtrarGrupo = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _recargar,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: _filtros.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final usuario = _filtros[i];
                    final iniciales =
                        '${usuario.nombre[0]}${usuario.apellido1[0]}';
                    final colorFondo = _avatarColor(usuario.id);
                    final grupo = _grupos
                        .firstWhere(
                          (g) => g.id == usuario.grupoId,
                          orElse: () => Grupo(
                            id: 0,
                            nombre: '—',
                            faltasTotales: 0,
                            usuarios: [],
                            horarios: [],
                          ),
                        )
                        .nombre;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorFondo,
                          child: Text(iniciales),
                        ),
                        title: Text('${usuario.nombre} ${usuario.apellido1} ${usuario.apellido2 ?? ""}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(usuario.email),
                            Text('Grupo: $grupo'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: scheme.primary),
                              onPressed: () {
                                _onEdit(usuario, scheme);
                              }
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: scheme.error),
                              onPressed: () async {
                                final confirmar = await _mostrarConfirmacion(context, usuario, scheme);
                                if (confirmar == true) {
                                  await UsuarioService().eliminarUsuario(usuario.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Usuario eliminado')),
                                  );
                                  _recargar();
                                }
                              },
                            ),
                            
                          ],
                        ),
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
}
