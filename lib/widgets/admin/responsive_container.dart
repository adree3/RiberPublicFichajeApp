import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/utils/tamanos.dart';

/// Un contenedor que centra y limita el ancho de formularios
/// para que en móviles use todo el ancho disponible,
/// y en pantallas anchas (tablet/escritorio) no exceda un máximo.
class ResponsiveFormContainer extends StatelessWidget {
  final Widget child;
  const ResponsiveFormContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Se define un ancho máximo para tablet/escritorio;
    // en móvil usamos todo el ancho (double.infinity).
    final maxWidth = width < Tamanos.movilMaxAnchura
        ? double.infinity
        : 600.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
