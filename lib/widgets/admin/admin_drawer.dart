import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';

class AdminDrawer extends StatelessWidget {
  final bool esMovil; 
  final int selectedIndex;
  final ValueChanged<int> onIndexSelected;
  final List<NavigationDestination> pantallas;

  const AdminDrawer({
    super.key,
    required this.esMovil,  
    required this.selectedIndex,
    required this.onIndexSelected,
    required this.pantallas,
  });

  String _obtenerIniciales(usuario) {
    if (usuario == null) return '';
    final nombre = usuario.nombre;
    final apellido = usuario.apellido1;
    return '${nombre.isNotEmpty ? nombre[0] : ''}${apellido.isNotEmpty ? apellido[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    final iniciales = _obtenerIniciales(usuario);

    return Drawer(
      backgroundColor: scheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(color: scheme.primary),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: scheme.onPrimary,
                  child: Text(
                    iniciales,
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
                    color: scheme.onPrimary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Opciones de navegación
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: pantallas.length,
              itemBuilder: (context, i) {
                final pantalla = pantallas[i];
                final isSelected = i == selectedIndex;
                return ListTile(
                  selected: isSelected,
                  // Fondo cuando está seleccionado:
                  selectedTileColor: scheme.onPrimary,
                  // Color de texto e icono cuando está seleccionado:
                  selectedColor: scheme.onSecondaryContainer,
                  // Icono
                  leading: Icon(
                    (pantalla.icon as Icon).icon,
                    // si no está seleccionado, usa este color
                    color: isSelected
                        ? scheme.onSecondaryContainer
                        : scheme.onPrimary,
                  ),
                  // Texto
                  title: Text(
                    pantalla.label,
                    style: TextStyle(
                      color: isSelected
                          ? scheme.onSecondaryContainer
                          : scheme.onPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    onIndexSelected(i);
                    if (esMovil) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),

          const Divider(height: 1, color: Colors.white24),

          // Logout con fondo blanco y letras rojas
          ListTile(
            tileColor: scheme.onPrimary,
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // TODO: implementar logout
            },
          ),
        ],
      ),
    );
  }
}
