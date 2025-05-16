import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';

typedef OnUsuarioEdited = void Function();

class AdminUsuarioEditarDialog extends StatefulWidget {
  final Usuario usuario;
  final OnUsuarioEdited onEdited;

  const AdminUsuarioEditarDialog({
    super.key,
    required this.usuario,
    required this.onEdited,
  });

  @override
  _AdminUsuarioEditarDialogState createState() =>
      _AdminUsuarioEditarDialogState();
}

class _AdminUsuarioEditarDialogState extends State<AdminUsuarioEditarDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellido1Ctrl;
  late TextEditingController _apellido2Ctrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _contraCtrl;

  Rol? _rolSeleccionado;
  Grupo? _grupoSeleccionado;
  Estado? _estadoSeleccionado;

  late Future<List<dynamic>> _futureData;

  bool _mostrarContrasena = true;
  bool _loading = false;
  bool _checkingEmail = false;
  String? _emailError;

  /// Al iniciar la pantalla, carga los datos del usuario a editar
  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _nombreCtrl = TextEditingController(text: u.nombre);
    _apellido1Ctrl = TextEditingController(text: u.apellido1);
    _apellido2Ctrl = TextEditingController(text: u.apellido2 ?? '');
    _emailCtrl = TextEditingController(text: u.email);
    _contraCtrl = TextEditingController();
    _rolSeleccionado = u.rol;
    _estadoSeleccionado = u.estado;
    _futureData = Future.wait([
      GrupoService().getGrupos(),
      UsuarioService().getUsuariosActivos(),
    ]);
  }

  /// Si se va a destruir la pantalla, elimina los datos
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellido1Ctrl.dispose();
    _apellido2Ctrl.dispose();
    _emailCtrl.dispose();
    _contraCtrl.dispose();
    super.dispose();
  }

  /// Inputdeoration para reutilizar codigo
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      errorMaxLines: 2,
    );
  }

  /// Comprueba el correo introducido
  Future<void> _comprobarCorreo(
      String email, List<Usuario> todosUsuarios) async {
    setState(() => _checkingEmail = true);
    final otros = todosUsuarios
        .where((u) => u.id != widget.usuario.id)
        .toList();
    final enUso = otros.any(
        (u) => u.email.toLowerCase() == email.toLowerCase().trim());
    setState(() {
      _emailError = enUso ? 'Este correo ya está registrado' : null;
      _checkingEmail = false;
    });
    _formKey.currentState?.validate();
  }

  /// Metodo para editar el usuario, no utilizo el objeto usuario, porque si no introduce la contraseña
  /// para editar, no quiero que se envie.
  Future<void> _editarUsuario(int grupoId) async {
    setState(() => _loading = true);
    try {
      final usuarioEditar = <String, dynamic>{
        'nombre': _nombreCtrl.text.trim(),
        'apellido1': _apellido1Ctrl.text.trim(),
        'apellido2': _apellido2Ctrl.text.trim().isEmpty
            ? null
            : _apellido2Ctrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'rol': _rolSeleccionado!.name,
        'estado': _estadoSeleccionado!.name,
      };
      final nuevaContra = _contraCtrl.text.trim();
      if (nuevaContra.isNotEmpty) {
        usuarioEditar['contrasena'] = nuevaContra;
      }

      await UsuarioService.editarUsuario(widget.usuario.id, usuarioEditar, grupoId);
      widget.onEdited();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el usuario')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<dynamic>>(
      future: _futureData,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('Error cargando datos')),
          );
        }

        final grupos = snap.data![0] as List<Grupo>;
        final usuarios = snap.data![1] as List<Usuario>;

        _grupoSeleccionado ??= grupos.firstWhere(
          (g) => g.id == widget.usuario.grupoId,
          orElse: () => grupos.first,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: _inputDecoration('Nombre', Icons.person),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Introduce un nombre' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _apellido1Ctrl,
                  decoration: _inputDecoration('Apellido 1', Icons.badge),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Introduce un apellido'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _apellido2Ctrl,
                  decoration: _inputDecoration(
                      'Apellido 2 (opcional)', Icons.badge_outlined),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailCtrl,
                  decoration: _inputDecoration('Email', Icons.email).copyWith(
                    suffixIcon: _checkingEmail
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  onChanged: (val) {
                    if (_emailError != null) setState(() => _emailError = null);
                    _comprobarCorreo(val.trim(), usuarios);
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Introduce un correo';
                    if (_emailError != null) return _emailError;
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _contraCtrl,
                  decoration: _inputDecoration(
                    'Nueva contraseña (opcional)', Icons.lock
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarContrasena
                          ? Icons.visibility
                          : Icons.visibility_off
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarContrasena = !_mostrarContrasena;
                        });
                      },
                    ),
                  ),
                  obscureText: _mostrarContrasena,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
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
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<Rol>(
                  value: _rolSeleccionado,
                  decoration:
                      _inputDecoration('Rol', Icons.admin_panel_settings),
                  items: Rol.values
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r.name)))
                      .toList(),
                  onChanged: (r) => setState(() => _rolSeleccionado = r),
                  validator: (v) => v == null ? 'Selecciona un rol' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<Grupo>(
                  value: _grupoSeleccionado,
                  decoration: _inputDecoration('Grupo', Icons.group),
                  items: grupos
                      .map((g) =>
                          DropdownMenuItem(value: g, child: Text(g.nombre)))
                      .toList(),
                  onChanged: (g) => setState(() => _grupoSeleccionado = g),
                  validator: (v) => v == null ? 'Selecciona un grupo' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<Estado>(
                  value: _estadoSeleccionado,
                  decoration:
                      _inputDecoration('Estado', Icons.toggle_on),
                  items: Estado.values
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (e) => setState(() => _estadoSeleccionado = e),
                  validator: (v) => v == null ? 'Selecciona estado' : null,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                          backgroundColor: scheme.onPrimary
                        ),
                        child: Text('Cancelar', style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 8,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _editarUsuario(_grupoSeleccionado!.id!);
                            }
                          },
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                          backgroundColor: scheme.primary
                        ),
                        child: Text('Actualizar', style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
