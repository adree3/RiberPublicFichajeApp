import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/utils/tamanos.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/admin_crear_usuario_dialog.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/admin_editar_usuario_dialog.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  late Future<List<Usuario>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _futureUsers = UsuarioService().getUsuarios();
  }

  Future<void> _refresh() async {
    _loadUsers();
    await _futureUsers;
    setState(() {});
  }

  void _onCreate() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Crear Usuario',style: TextStyle(fontWeight: FontWeight.bold))),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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
        _refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado correctamente')),
        );
      }
    });
  }

  void _onEdit(Usuario usuario) async {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Editar Usuario',style: TextStyle(fontWeight: FontWeight.bold))),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          content:  SizedBox(
            width: 360,
            child: AdminUsuarioEditarDialog(
              usuario: usuario,
              onEdited: () => Navigator.of(context).pop(true),
            ),
          ),
        );
      }
    ).then((edited) {
      if (edited == true) {
        _refresh(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado')),
        );
      }
    });
  }

  void _onDeleteConfirmed(Usuario usuario) async {
    try {
      await UsuarioService().eliminarUsuario(usuario.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado')),
      );
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el usuario')),
      );
    }
  }

  Color _avatarColor(int id) {
    // Lista de colores base
    final colors = Colors.primaries;
    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final esMovil = constraints.maxWidth < Tamanos.movilMaxAnchura;

      return Scaffold(
        appBar: esMovil
            ? null
            : AppBar(
                title: const Text('Usuarios'),
                centerTitle: true,
              ),
        body: FutureBuilder<List<Usuario>>(
          future: _futureUsers,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final lista = snap.data!;
            if (lista.isEmpty) {
              return const Center(child: Text('No hay usuarios registrados.'));
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                // Añado padding bottom para que el FAB no cubra el último Card
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final usuario = lista[i];
                  final initials = '${usuario.nombre[0]}${usuario.apellido1[0]}';
                  final bgColor = _avatarColor(usuario.id);
                  return Dismissible(
                    key: ValueKey(usuario.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async => await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: const Text('Eliminar usuario'),
                        content: Text('¿Eliminar a ${usuario.nombre} ${usuario.apellido1}?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(dctx, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(dctx, true),
                              child: const Text('Eliminar')),
                        ],
                      ),
                    ),
                    onDismissed: (_) => _onDeleteConfirmed(usuario),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: bgColor,
                          foregroundColor: Colors.white,
                          child: Text(initials),
                        ),
                        title: Text('${usuario.nombre} ${usuario.apellido1}'),
                        subtitle: Text(usuario.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _onEdit(usuario),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
          onPressed: _onCreate,
        ),
      );
    });
  }
}
