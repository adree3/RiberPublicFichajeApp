import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contrasenaActual = TextEditingController();
  final _nuevaContrasena = TextEditingController();
  final _confimarContrasena = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _contrasenaActual.dispose();
    _nuevaContrasena.dispose();
    _confimarContrasena.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // Llama a tu servicio (implementa UsuarioService.changePassword)
      await UsuarioService.changePassword(
        _contrasenaActual.text.trim(),
        _nuevaContrasena.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada'))
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTh = Theme.of(context).textTheme;

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
                validator: (v) =>
                  (v == null || v.isEmpty)
                    ? 'Introduce la contraseña actual'
                    : null,
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
                validator: (v) =>
                  (v == null || v.length < 6)
                    ? 'Mínimo 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confimarContrasena,
                decoration: const InputDecoration(
                  labelText: 'Confirma nueva contraseña',
                  prefixIcon: Icon(Icons.check),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirma la contraseña';
                  if (v != _nuevaContrasena.text)   return 'No coincide';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Guardar cambios'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
