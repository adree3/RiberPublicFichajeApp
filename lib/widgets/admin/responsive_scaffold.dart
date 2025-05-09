import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/utils/tamanos.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/admin_drawer.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final List<NavigationDestination> pantallas;
  final int selectedIndex;
  final ValueChanged<int> onIndexSelected;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.pantallas,
    required this.selectedIndex,
    required this.onIndexSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    final title = pantallas[selectedIndex].label;
    final isMobile = MediaQuery.of(context).size.width < Tamanos.movilMaxAnchura;


    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(pantallas[selectedIndex].label),
          centerTitle: true,
        ),
        drawer: AdminDrawer(
          selectedIndex: selectedIndex,
          onIndexSelected: onIndexSelected,
          pantallas: pantallas,
        ),
        body: body,
      );
    }

    // Escritorio: sidebar fija
    return Scaffold(
      body: Row(
        children: [
          AdminDrawer(
            selectedIndex: selectedIndex,
            onIndexSelected: onIndexSelected,
            pantallas: pantallas,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
