import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Obtiene las iniciales del usuario para el circle avatar
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
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuario;
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
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: pantallas.length,
              itemBuilder: (context, i) {
                final pantalla = pantallas[i];
                final isSelected = i == selectedIndex;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: scheme.onPrimary,
                  selectedColor: scheme.onSecondaryContainer,
                  leading: Icon(
                    (pantalla.icon as Icon).icon,
                    color: isSelected
                        ? scheme.onSecondaryContainer
                        : scheme.onPrimary,
                  ),
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

          ListTile(
            tileColor: scheme.onPrimary,
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.exit_to_app, color: scheme.onPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  content: const Text(
                    '¿Estás seguro de que quieres cerrar sesión?',
                    textAlign: TextAlign.center,
                  ),
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
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
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: scheme.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size.fromHeight(40),
                            ),
                            child: Text(
                              'Cerrar sesión',
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
              // Si cierra sesion se elimina el usuario y el token de sharedPreferences
              if (confirmar == true) {
                Provider.of<AuthProvider>(context, listen: false).cerrarSesion();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('usuario');
                await prefs.remove('token');
                Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
