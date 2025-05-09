import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_ausencias_screen.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_usuarios_screen.dart';
import '../../widgets/admin/responsive_scaffold.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;


  static final _screens = [
    const AdminUsuariosScreen(),
    const Placeholder(),
    const AdminAusenciasScreen(),
    const Placeholder()
  ];

  static final  pantallas = [
    NavigationDestination(icon: Icon(Icons.person), label: 'Usuarios'),
    NavigationDestination(icon: Icon(Icons.schedule), label: 'Horarios'),
    NavigationDestination(icon: Icon(Icons.event_busy), label: 'Ausencias'),
    NavigationDestination(icon: Icon(Icons.group), label: 'Grupos'),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: _screens[_selectedIndex],
      pantallas: pantallas,
      selectedIndex: _selectedIndex,
      onIndexSelected: (i) => setState(() => _selectedIndex = i),
    );
  }
}
