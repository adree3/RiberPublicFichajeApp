import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider utilizado para el tema oscuro o claro
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeProvider() {
    _cargarPreferencias();
  }

  ThemeMode get mode => _mode;

  bool get esOscuro => _mode == ThemeMode.dark;

  /// Al llamarlo cambia de oscuro a claro y al reves
  Future<void> toggle() async {
    _mode = esOscuro ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', esOscuro);
  }

  /// Carga las preferencias al sharedPreferences y notifica
  Future<void> _cargarPreferencias() async {
    final preferencia = await SharedPreferences.getInstance();
    final oscuro = preferencia.getBool('darkMode') ?? false;
    _mode = oscuro ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
