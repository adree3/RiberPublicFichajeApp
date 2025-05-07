import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';

/// Provider utilizado para guardar el usuario loggeado
class UsuarioProvider with ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  bool get estaLogueado => _usuario != null;

  void setUsuario(Usuario? usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void cerrarSesion() {
    _usuario = null;
    notifyListeners();
  }
}
