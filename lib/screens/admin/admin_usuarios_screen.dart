// lib/screens/admin/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_crear_usuario_screen.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';

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

  void _onCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminUsuarioCrearScreen()),
    );
    if (result == true) _refresh();
  }

  void _onEdit(Usuario user) async {
    final result = await Navigator.pushNamed(
      context,
      '/admin/users/edit',
      arguments: user,
    ) as bool?;
    if (result == true) _refresh();
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
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
          final listaUsuarios = snap.data!;
          if (listaUsuarios.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off, size: 64, color: scheme.secondaryContainer),
                  SizedBox(height: 16),
                  Text('No hay usuarios registrados.',
                      style: TextStyle(fontSize: 18, color: scheme.secondaryContainer)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: listaUsuarios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final usuario = listaUsuarios[i];
                final iniciales = (usuario.nombre.isNotEmpty ? usuario.nombre[0] : '') +
                    (usuario.apellido1.isNotEmpty ? usuario.apellido1[0] : '');
                return Dismissible(
                  key: ValueKey(usuario.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar usuario'),
                        content: Text(
                            '¿Seguro que deseas eliminar a ${usuario.nombre} ${usuario.apellido1}?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Eliminar')),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => _onDeleteConfirmed(usuario),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            scheme.primaryContainer,
                        foregroundColor:
                            scheme.onPrimaryContainer,
                        child: Text(iniciales),
                      ),
                      title: Text('${usuario.nombre} ${usuario.apellido1}'),
                      subtitle: Text(usuario.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _onEdit(usuario),
                          ),
                        ],
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
        onPressed: _onCreate,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }
}
