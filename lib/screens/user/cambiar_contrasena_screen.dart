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
  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;

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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _contrasenaActual,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureActual ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureActual = !_obscureActual),
                  ),
                ),
                obscureText: _obscureActual,
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
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNueva ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureNueva = !_obscureNueva),
                  ),
                ),
                obscureText: _obscureNueva,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce la nueva contraseña';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                    return 'Debe incluir al menos una mayúscula';
                  }
                  if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                    return 'Debe incluir al menos un número';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confimarContrasena,
                decoration: InputDecoration(
                  labelText: 'Confirma la nueva contraseña',
                  prefixIcon: const Icon(Icons.check),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                  ),
                ),
                obscureText: _obscureConfirmar,
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
