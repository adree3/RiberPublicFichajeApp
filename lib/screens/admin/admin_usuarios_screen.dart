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

  /// Al inciar la pantalla cargan los datos
  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }
  
  /// Recibe del service los grupos y usuarios
  Future<void> _cargarDatos() async {
    final grupos = await GrupoService().getGrupos();
    final usuarios = await UsuarioService().getUsuarios();
    setState(() {
      _grupos = grupos;
      _usuarios = usuarios;
    });
  }

  /// Recarga llamando a recargar datos
  Future<void> _recargar() async {
    _cargarDatos();
  }

  /// Filtra por el email y grupo
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

  /// Calcula el color del avatar por el id
  Color _avatarColor(int id) =>
      Colors.primaries[id % Colors.primaries.length];

  /// Dialogo para crear un usuario
  void crearUsuarioDialogo() {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  /// Dialogo para editar un usuario
  void _editarUsuarioDialogo(Usuario usuario, ColorScheme scheme) {
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

  /// Dialogo para confirmar eliminar un usuario
  Future<bool?> _mostrarConfirmacion(BuildContext context, Usuario usuario, ColorScheme scheme) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => AlertDialog(
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
              'Eliminar Usuario',
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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


  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Filtra los usuarios activos
    final activos = _filtros
        .where((u) => u.estado == Estado.activo)
        .toList();
    // Filtra los usuarios inactivos
    final inactivos = _filtros
        .where((u) => u.estado != Estado.activo)
        .toList();
    
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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, kBottomNavigationBarHeight + 16),
                  children: [
                    if (activos.isNotEmpty) ...[
                      const Text('Usuarios Activos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...activos.map((u) => _buildUsuarioApartado(u, scheme)),
                      const Divider(thickness: 2),
                    ],
                    if (inactivos.isNotEmpty) ...[
                      const Text('Usuarios Inactivos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...inactivos.map((u) => _buildUsuarioApartado(u, scheme)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  /// Widget para reutilizar codigo
  Widget _buildUsuarioApartado(Usuario usuario, ColorScheme scheme) {
    final iniciales = '${usuario.nombre[0]}${usuario.apellido1[0]}'.toUpperCase();
    final colorFondo = _avatarColor(usuario.id);
    final grupo = _grupos
        .firstWhere((g) => g.id == usuario.grupoId, orElse: () => Grupo(
          id: 0, nombre: '—', faltasTotales: 0, usuarios: [], horarios: []))
        .nombre;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorFondo,
          child: Text(iniciales),
        ),
        title: Text('${usuario.nombre} ${usuario.apellido1} ${usuario.apellido2??""}'),
        subtitle: Text('${usuario.email}\nGrupo: $grupo'),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: scheme.primary),
              onPressed: () => _editarUsuarioDialogo(usuario, scheme),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: scheme.error),
              onPressed: () async {
                final ok = await _mostrarConfirmacion(context, usuario, scheme);
                if (ok == true) {
                  await UsuarioService().eliminarUsuario(usuario.id);
                  _recargar();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

}
