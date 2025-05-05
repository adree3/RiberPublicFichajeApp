import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/providers/tema_provider.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/screens/cambiar_contrasena_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _selectedLang = 'es'; // 'es' or 'en'

  @override
  Widget build(BuildContext context) {
  final temaProv = Provider.of<ThemeProvider>(context);
  final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
  final scheme  = Theme.of(context).colorScheme;
  final textTheme  = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: scheme.secondaryContainer,
                        child: Icon(Icons.person, size: 80, color: scheme.onSurface),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Editar avatar
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.onSurface.withOpacity(0.2),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: scheme.onSurface
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                  ),
                  const SizedBox(height: 16),
                  Text(
                    usuario!.email,
                    style: textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold, color: scheme.primary),
                  ),
                ],
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                color: scheme.surface,
                child: Column(
                  children: [
                    // Tema oscuro
                    SwitchListTile(
                      title: const Text('Tema Oscuro'),
                      subtitle: Text('Elige entre tema claro u oscuro.', style: textTheme.bodySmall),
                      value: temaProv.esOscuro,
                      onChanged: (_) => temaProv.toggle(),
                      secondary: const Icon(Icons.nights_stay),
                    ),
                    const Divider(height: 1),

                    // Idioma
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Idioma'),
                      subtitle: Text('Cambia el idioma de la aplicación.', style: textTheme.bodySmall),
                      trailing: DropdownButton<String>(
                        value: _selectedLang,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'es',
                            child: Text('🇪🇸 Español'),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('🇬🇧 English'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedLang = v);
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    // Cambiar contraseña
                    ListTile(
                      leading: Icon(Icons.lock, color: scheme.primary),
                      title: Text('Cambiar Contraseña', style: textTheme.bodyMedium),
                      subtitle: Text('Para esta función necesitarás introducir la contraseña actual.',style: textTheme.bodySmall,),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CambiarContrasenaScreen())
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // Cerrar sesión
                    ListTile(
                      leading: Icon(Icons.exit_to_app, color: scheme.error),
                      title: Text(
                        'Cerrar sesión',
                        style: textTheme.bodyMedium!.copyWith(color: scheme.error),
                      ),
                      subtitle: Text(
                        'Se cerrará la sesión de tu cuenta actual.',
                        style: textTheme.bodySmall,
                      ),
                      onTap: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            // Título centrado con icono y texto en negrita
                            title: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.exit_to_app, color: scheme.error),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cerrar sesión',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            content: const Text(
                              '¿Estás seguro de que quieres cerrar sesión?',
                              textAlign: TextAlign.center,
                              
                            ),
                            
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: scheme.error,
                                ),
                                child: const Text('Cerrar sesión'),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true) {
                          Provider.of<UsuarioProvider>(context, listen: false).cerrarSesion();

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('usuario');

                          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

