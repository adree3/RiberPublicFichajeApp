
import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_grupos_screen.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_horarios_screen.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_usuarios_screen.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_ausencias_screen.dart';
import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/responsive_scaffold.dart';
import 'package:riber_republic_fichaje_app/widgets/snackbar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  // se utilizan para poder llamar desde esta clase a los metodos de sus clases
  final _usuariosKey = GlobalKey<AdminUsuariosScreenState>();
  final _ausenciasKey  = GlobalKey<AdminAusenciasScreenState>();
  final _gruposkey  = GlobalKey<AdminGruposScreenState>();
  final _horarioskey  = GlobalKey<AdminHorariosScreenState>();

  /// Nombre e icono de las pantallas a navegar
  static final pantallas = [
    const NavigationDestination(icon: Icon(Icons.event_busy), label: 'Ausencias'),
    const NavigationDestination(icon: Icon(Icons.person), label: 'Usuarios'),
    const NavigationDestination(icon: Icon(Icons.group), label: 'Grupos'),
    const NavigationDestination(icon: Icon(Icons.schedule), label: 'Horarios'),
  ];

  late final List<Widget> _screens;

  /// Al iniciar la pantalla se almacenan la lista de screens a las que se van a acceder
  @override
  void initState() {
    super.initState();
    _screens = [
      AdminAusenciasScreen(key: _ausenciasKey),
      AdminUsuariosScreen(key: _usuariosKey),
      AdminGruposScreen(key: _gruposkey),
      AdminHorariosScreen(key: _horarioskey,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: _screens[_selectedIndex],
      pantallas: pantallas,
      selectedIndex: _selectedIndex,
      onIndexSelected: (i) => setState(() => _selectedIndex = i),
      floatingActionButton: _buildCrear(),
    );
  }

  /// Dependiendo de la pantalla genera un FAB distinto
  Widget? _buildCrear() {
    switch (_selectedIndex) {
      case 0: // Ausencias
        return FloatingActionButton.extended(
          icon: const Icon(Icons.refresh),
          label: const Text('Generar'),
          onPressed: () async{
            try {
              await AusenciaService.generarAusencias();
              _ausenciasKey.currentState?.recargar();
              AppSnackBar.show(
                context,
                message: 'Ausencias generadas',
                backgroundColor: Colors.green.shade600,
                icon: Icons.check_circle,
              );
            } catch (e) {
              AppSnackBar.show(
                context,
                message: 'Error al generar las ausencias',
                backgroundColor: Colors.red.shade600,
                icon: Icons.error_outline,
              );
            }
          },
        );
      case 1: // Usuarios
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
          onPressed: () {
            _usuariosKey.currentState?.crearUsuarioDialogo();
          },
        );
      case 2: // Grupos
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
          onPressed: () {
            _gruposkey.currentState?.crearGrupoDialogo();
          },
        );
      case 3: // Grupos
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
          onPressed: () {
            _horarioskey.currentState?.crearHorarioDialogo();
          },
        );
      
      default:
        return null;
    }
  }
}
