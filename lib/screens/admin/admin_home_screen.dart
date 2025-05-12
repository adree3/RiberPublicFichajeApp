
import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_grupos_screen.dart';
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


  static final pantallas = [
    NavigationDestination(icon: Icon(Icons.person), label: 'Usuarios'),
    //NavigationDestination(icon: Icon(Icons.schedule),    label: 'Horarios'),
    NavigationDestination(icon: Icon(Icons.event_busy), label: 'Ausencias'),
    NavigationDestination(icon: Icon(Icons.group), label: 'Grupos'),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 3) Ahora sí puedes usar los keys
    _screens = [
      AdminUsuariosScreen(key: _usuariosKey),
      //const Placeholder(),           // Grupos
      AdminAusenciasScreen(key: _ausenciasKey),
      AdminGruposScreen()
    ];
  }

  

  /*@override
  Widget build(BuildContext context) {
    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = AdminUsuariosScreen(key: _usuariosKey);
        break;
      case 1:
        body = AdminAusenciasScreen();
        break;
      default:
        body = const SizedBox();
    }

    return ResponsiveScaffold(
      body: body,
      pantallas: pantallas,
      selectedIndex: _selectedIndex,
      onIndexSelected: (i) => setState(() => _selectedIndex = i),
      floatingActionButton: _buildCrear(),
    );
  }*/
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
            _usuariosKey.currentState?.onCreate();
          },
        );
      case 1: // Ausencias
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
