import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/loginResponse.dart';

/// Provider utilizado para guardar el usuario loggeado
class AuthProvider with ChangeNotifier {
  LoginResponse? _usuario;

  LoginResponse? get usuario => _usuario;

  bool get estaLogueado => _usuario != null;

  /// Añades el usuario logeado
  void setUsuario(LoginResponse? usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  /// Ceirras sesion
  void cerrarSesion() {
    _usuario = null;
    notifyListeners();
  }
}
