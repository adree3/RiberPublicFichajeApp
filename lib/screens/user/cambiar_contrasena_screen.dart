import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';

class CambiarContrasenaScreen extends StatefulWidget {
  const CambiarContrasenaScreen({super.key});

  @override
  State<CambiarContrasenaScreen> createState() => _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState extends State<CambiarContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contrasenaActual = TextEditingController();
  final _nuevaContrasena = TextEditingController();
  final _confimarContrasena = TextEditingController();
  bool _loading = false;


  /// metodo para cuando se vaya a "destruir" el widget no se quede informacion flotando en la nada.
  @override
  void dispose() {
    _contrasenaActual.dispose();
    _nuevaContrasena.dispose();
    _confimarContrasena.dispose();
    super.dispose();
  }

  /// metodo para actualizar la contraseña en el API con la informacion obtenida del usuario
  Future<void> _actualizarContrasena() async {
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;

    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _loading = true;
    }); 
    try {
      await UsuarioService.cambiarContrasena(usuario!.id, _contrasenaActual.text.trim(), _nuevaContrasena.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada'))
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
    } finally {
      //siempre pone el loading a false para que no se quede pillado el circularProgress
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
        backgroundColor: scheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contrasenaActual,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if(value == null || value.isEmpty){
                    return 'Introduce la contraseña actual';
                  }
                  return null;   
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nuevaContrasena,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if(value == null || value.length < 6){
                    return 'Debe contener minimo 6 caracteres';
                  }else{
                    return null;
                  }
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confimarContrasena,
                decoration: const InputDecoration(
                  labelText: 'Confirma la nueva contraseña',
                  prefixIcon: Icon(Icons.check),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma la contraseña';
                  }
                  if (value != _nuevaContrasena.text){
                    return 'Debe coincidir la nueva contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _loading
              ? const CircularProgressIndicator()
              : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _actualizarContrasena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('ACTUALIZAR CONTRASEÑA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
