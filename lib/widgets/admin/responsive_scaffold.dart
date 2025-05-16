import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/utils/tamanos.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/admin_drawer.dart';

/// Adapta el scaffold, segun el tamaño de la pantalla
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final List<NavigationDestination> pantallas;
  final int selectedIndex;
  final ValueChanged<int> onIndexSelected;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.pantallas,
    required this.selectedIndex,
    required this.onIndexSelected,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final esMovil =MediaQuery.of(context).size.width < Tamanos.movilMaxAnchura;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(pantallas[selectedIndex].label),
        centerTitle: true,
      ),
      drawer: esMovil
      ? AdminDrawer(
          esMovil: true,
          selectedIndex: selectedIndex,
          onIndexSelected: onIndexSelected,
          pantallas: pantallas,
        )
      : null,
      body: esMovil 
      ? body
      : Row(
        children: [
          AdminDrawer(
            esMovil: false,
            selectedIndex: selectedIndex,
            onIndexSelected: onIndexSelected,
            pantallas: pantallas,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
