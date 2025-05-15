import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';

/// Provider utilizado para guardar el usuario loggeado
class UsuarioProvider with ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  bool get estaLogueado => _usuario != null;

  /// Añades el usuario logeado
  void setUsuario(Usuario? usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  /// ceirras sesion
  void cerrarSesion() {
    _usuario = null;
    notifyListeners();
  }
}
