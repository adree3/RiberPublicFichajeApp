import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/screens/olvidarContrasena_screen.dart';
import 'package:riber_republic_fichaje_app/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/usuario_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _guardarSesion = false;

  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final authService = AuthService();
    final usuario = await authService.login(
      _emailController.text,
      _passController.text,
    );

    setState(() => _loading = false);

    if (usuario != null) {
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
      usuarioProvider.setUsuario(usuario);

      if (_guardarSesion) {
        final prefs = await SharedPreferences.getInstance();
        final usuarioJson = jsonEncode(usuario.toJson());
        await prefs.setString('usuario', usuarioJson);
      }

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Credenciales incorrectas")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Container(
                    width: 120, 
                    height: 120, 
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.image, size: 60, color: Colors.grey[700]),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Correo electrónico",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) => value!.isEmpty ? "Introduce tu email" : null,
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _passController,
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? "Introduce tu contraseña" : null,
                        ),
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Checkbox(
                                value: _guardarSesion,
                                onChanged: (value) {
                                  setState(() {
                                    _guardarSesion = value ?? false;
                                  });
                                },
                              ),
                              const Text("Guardar sesión"),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () => _login(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(double.infinity, 50), 
                                  backgroundColor: const Color(0xFF008080), 
                                ),
                                child: const Text("INICIAR SESION", style: TextStyle(color: Colors.white),),
                              ),
                        const SizedBox(height: 20),
                        
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (i) => OlvideContrasenaScreen()));
                          },
                          child: const Text(
                            "¿Olvidaste la contraseña?",
                            style: TextStyle(
                              color: Color(0xFF008080), 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
