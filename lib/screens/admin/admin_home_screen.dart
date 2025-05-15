
import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_grupos_screen.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_horarios_screen.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_usuarios_screen.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_ausencias_screen.dart';
import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/responsive_scaffold.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  final _usuariosKey = GlobalKey<AdminUsuariosScreenState>();
  final _ausenciasKey  = GlobalKey<AdminAusenciasScreenState>();
  final _gruposkey  = GlobalKey<AdminGruposScreenState>();
  final _horarioskey  = GlobalKey<AdminHorariosScreenState>();

  static final pantallas = [
    const NavigationDestination(icon: Icon(Icons.person), label: 'Usuarios'),
    const NavigationDestination(icon: Icon(Icons.group), label: 'Grupos'),
    const NavigationDestination(icon: Icon(Icons.schedule), label: 'Horarios'),
    const NavigationDestination(icon: Icon(Icons.event_busy), label: 'Ausencias'),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminUsuariosScreen(key: _usuariosKey),
      AdminGruposScreen(key: _gruposkey),
      AdminHorariosScreen(key: _horarioskey,),
      AdminAusenciasScreen(key: _ausenciasKey),
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

  Widget? _buildCrear() {
    switch (_selectedIndex) {
      case 0: // Usuarios
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
          onPressed: () {
            _usuariosKey.currentState?.crearUsuarioDialogo();
          },
        );
      
      case 1: // Grupos
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
          onPressed: () {
            _gruposkey.currentState?.crearGrupoDialogo();
          },
        );
      case 2: // Grupos
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nuevo'),
          onPressed: () {
            _horarioskey.currentState?.crearHorarioDialogo();
          },
        );
      case 3: // Ausencias
        return FloatingActionButton.extended(
          icon: const Icon(Icons.refresh),
          label: const Text('Generar'),
          onPressed: () async{
            try {
              await AusenciaService.generarAusencias();
              _ausenciasKey.currentState?.recargar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ausencias generadas')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        );
      default:
        return null;
    }
  }
}
