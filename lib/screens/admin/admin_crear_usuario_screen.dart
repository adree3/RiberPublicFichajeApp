// lib/screens/admin/admin_user_form_screen.dart

import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/widgets/responsive_container.dart';

class AdminUsuarioCrearScreen extends StatefulWidget {
  final Usuario? usuario;
  const AdminUsuarioCrearScreen({super.key, this.usuario});

  @override
  State<AdminUsuarioCrearScreen> createState() => _AdminUsuarioCrearScreenState();
}

class _AdminUsuarioCrearScreenState extends State<AdminUsuarioCrearScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellido1Ctrl = TextEditingController();
  final _apellido2Ctrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Rol? _selectedRol;
  Grupo? _selectedGrupo;
  late Future<List<Grupo>> _futureGrupos;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _futureGrupos = GrupoService().getGrupos();
    if (widget.usuario != null) {
      final u = widget.usuario!;
      _nombreCtrl.text = u.nombre;
      _apellido1Ctrl.text = u.apellido1;
      _apellido2Ctrl.text = u.apellido2 ?? '';
      _emailCtrl.text = u.email;
      _selectedRol = u.rol;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellido1Ctrl.dispose();
    _apellido2Ctrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRol == null || _selectedGrupo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona rol y grupo')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final newUser = Usuario(
        id: widget.usuario?.id ?? 0,
        nombre: _nombreCtrl.text.trim(),
        apellido1: _apellido1Ctrl.text.trim(),
        apellido2: _apellido2Ctrl.text.trim().isEmpty ? null : _apellido2Ctrl.text.trim(),
        email: _emailCtrl.text.trim(),
        contrasena: _passCtrl.text.trim(),
        rol: _selectedRol!,
        grupoId: _selectedGrupo!.id,
        estado: Estado.activo,
      );
      if (widget.usuario == null) {
        await UsuarioService().crearUsuario(newUser, _selectedGrupo!.id!);
      } else {
        //await UsuarioService().act(newUser.id, newUser, _selectedGrupo!.id);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar usuario: \$e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.usuario != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Usuario' : 'Crear Usuario'),
      ),
      body: FutureBuilder<List<Grupo>>(
        future: _futureGrupos,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            debugPrint('─── ERROR getGrupos ───');
            debugPrint('Error: ${snap.error}');
            debugPrint('Stack: ${snap.stackTrace}');
            return Center(child: Text('Error cargando los grupos'));
          }
          final grupos = snap.data!;
          if (_selectedGrupo == null && isEdit) {
            _selectedGrupo = grupos.firstWhere(
              (g) => g.id == widget.usuario!.grupoId,
              orElse: () => grupos.first,
            );
          }
          return ResponsiveFormContainer(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => v!.isEmpty ? 'Introduce nombre' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _apellido1Ctrl,
                      decoration: const InputDecoration(labelText: 'Apellido 1'),
                      validator: (v) => v!.isEmpty ? 'Introduce apellido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _apellido2Ctrl,
                      decoration: const InputDecoration(labelText: 'Apellido 2 (opcional)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Introduce email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passCtrl,
                      decoration: InputDecoration(
                        labelText: isEdit ? 'Nueva contraseña (opcional)' : 'Contraseña',
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (!isEdit && v!.isEmpty) return 'Introduce contraseña';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Rol>(
                      value: _selectedRol,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: Rol.values.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(r.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (r) => setState(() => _selectedRol = r),
                      validator: (v) => v == null ? 'Selecciona rol' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Grupo>(
                      value: _selectedGrupo,
                      decoration: const InputDecoration(labelText: 'Grupo'),
                      items: grupos.map((g) {
                        return DropdownMenuItem(
                          value: g,
                          child: Text(g.nombre),
                        );
                      }).toList(),
                      onChanged: (g) => setState(() => _selectedGrupo = g),
                      validator: (v) => v == null ? 'Selecciona grupo' : null,
                    ),
                    const SizedBox(height: 24),
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _save,
                              child: Text(isEdit ? 'Actualizar' : 'Crear'),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}