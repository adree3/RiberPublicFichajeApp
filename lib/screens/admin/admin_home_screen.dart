// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/screens/admin/admin_usuarios_screen.dart';
import '../../widgets/admin/responsive_scaffold.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  static const _titles = ['Usuarios', 'Horarios', 'Ausencias'];


  static final _screens = [
    const AdminUsuariosScreen(),
    //const AdminSchedulesScreen(),
    //const AdminAbsencesScreen(),
  ];

  static final  _destinations = [
    NavigationDestination(icon: Icon(Icons.person), label: 'Usuarios'),
    NavigationDestination(icon: Icon(Icons.schedule), label: 'Horarios'),
    NavigationDestination(icon: Icon(Icons.event_busy), label: 'Ausencias'),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: _screens[_selectedIndex],
      destinations: _destinations,
      selectedIndex: _selectedIndex,
      onIndexSelected: (i) => setState(() => _selectedIndex = i),
    );
  }
}
