import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: estaLogueado ? '/home' : '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
