// lib/widgets/admin_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexSelected;
  final List<NavigationDestination> destinations;

  const AdminDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onIndexSelected,
    required this.destinations,
  }) : super(key: key);

  String _getInitials(usuario) {
    if (usuario == null) return '';
    final n = usuario.nombre;
    final a = usuario.apellido1;
    return '${n.isNotEmpty ? n[0] : ''}${a.isNotEmpty ? a[0] : ''}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    final initials = _getInitials(usuario);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: scheme.onPrimary,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  usuario?.email ?? '',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Navegación
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: destinations.length,
              itemBuilder: (context, i) {
                final d = destinations[i];
                final isSelected = i == selectedIndex;
                return ListTile(
                  leading: Icon(
                    (d.icon as Icon).icon,
                    color: isSelected
                        ? scheme.secondary
                        : scheme.primary,
                  ),
                  title: Text(
                    d.label,
                    style: TextStyle(
                      color: isSelected
                          ? scheme.secondary
                          : scheme.primary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: scheme.primary,
                  // ¡Sin shape para que no tenga bordes redondeados!
                  onTap: () {
                    onIndexSelected(i);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text('Cerrar sesión',style: TextStyle(color: scheme.error, )), 
            onTap: () {
              // TODO: implementar logout
            },
          ),
        ],
      ),
    );
  }
}
