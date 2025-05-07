// lib/widgets/responsive_scaffold.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/utils/tamanos.dart';
import 'package:riber_republic_fichaje_app/widgets/admin_drawer.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onIndexSelected;

  const ResponsiveScaffold({
    Key? key,
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onIndexSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    final title = destinations[selectedIndex].label;
    final isMobile = MediaQuery.of(context).size.width < Tamanos.tabletMaxAnchura;


    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(destinations[selectedIndex].label),
          centerTitle: true,
        ),
        drawer: AdminDrawer(
          selectedIndex: selectedIndex,
          onIndexSelected: onIndexSelected,
          destinations: destinations,
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
            destinations: destinations,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
