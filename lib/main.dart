import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/providers/tema_provider.dart';
import 'package:riber_republic_fichaje_app/screens/home_screen.dart';
import 'package:riber_republic_fichaje_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/usuario_provider.dart';
void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final usuarioString = prefs.getString('usuario');

  Usuario? usuarioGuardado;
  if (usuarioString != null) {
    final json = jsonDecode(usuarioString);
    usuarioGuardado = Usuario.fromJson(json);
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()..setUsuario(usuarioGuardado)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(estaLogueado: usuarioGuardado != null),
    ),
  );
}


class MyApp extends StatelessWidget {
  final bool estaLogueado;
  const MyApp({super.key, required this.estaLogueado});
  @override
  Widget build(BuildContext context) {
    final temaProv = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF008080),   // tu verde-agua
          secondary: Color(0xFFF57C00), // tu naranja para estimadas
          primaryContainer: Color(0xFF1565C0), // aquí el azul oscuro
          secondaryContainer: Colors.grey,

        ),
        // asegúrate de que AppBar, FloatingActionButton, etc, usen el colorScheme:
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF008080),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF008080),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF008080),
          secondary: Color(0xFFF57C00),
          primaryContainer: Color(0xFF1565C0) 

        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF008080),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF008080),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
      ),
      themeMode: temaProv.mode,
      initialRoute: estaLogueado ? '/home' : '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
