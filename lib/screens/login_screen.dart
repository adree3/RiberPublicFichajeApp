import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
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
  bool _mostrarContrasena = true;

  /// Hace una peticion al service para comprobar el usuario y contraseña
  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    final email = '${_emailController.text.trim()}@educa.jcyl.es';
    final usuario = await AuthService.login(email,_passController.text);

    setState(() {
      _loading = false;
    });

    if (usuario != null) {
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
      usuarioProvider.setUsuario(usuario);

      if (_guardarSesion) {
        final prefs = await SharedPreferences.getInstance();
        final usuarioJson = jsonEncode(usuario.toJson());
        await prefs.setString('usuario', usuarioJson);
      }
      final esAdmin = usuario.rol == Rol.jefe;
      final ruta = esAdmin
        ? '/admin_home'
        : '/home';

      Navigator.pushReplacementNamed(context, ruta);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Credenciales incorrectas"), 
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    width: 350, 
                    height: 300, 
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),                  child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Correo electrónico",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: scheme.primary),
                          suffixText: '@educa.jcyl.es',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty){
                            return "Introduce tu usuario sin el @";
                          }else{
                            return null;
                          }
                        }
                      ),
                      const SizedBox(height: 20),
                  
                        TextFormField(
                          controller: _passController,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock, color: scheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mostrarContrasena ? Icons.visibility_off : Icons.visibility,
                                color: scheme.onSurface.withOpacity(0.6),
                              ),
                              onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
                            ),
                          ),
                          obscureText: _mostrarContrasena,
                          validator: (value){
                            if (value!.isEmpty){
                              return "Introduce tu contraseña";
                            }else{
                              return null;
                            }
                          } 
                        ),
                        const SizedBox(height: 20),
                  
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Checkbox(
                                value: _guardarSesion,
                                activeColor: scheme.primary,
                                onChanged: (value) {
                                  setState(() {
                                    _guardarSesion = value ?? false;
                                  });
                                },
                              ),
                              Text("Guardar sesión"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _loading
                        ? CircularProgressIndicator(color: scheme.primary)
                        : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _login(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text( "INICIAR SESIÓN",
                              style: TextStyle(color: scheme.onPrimary)
                            ),
                          ),
                        )
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
