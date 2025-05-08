import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';

typedef OnUsuarioCreated = void Function();

class AdminUsuarioDialog extends StatefulWidget {
  final OnUsuarioCreated onCreated;
  const AdminUsuarioDialog({super.key, required this.onCreated});

  @override
  _AdminUsuarioDialogState createState() => _AdminUsuarioDialogState();
}

class _AdminUsuarioDialogState extends State<AdminUsuarioDialog> {
  // controladores para los textFormFields
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellido1Ctrl = TextEditingController();
  final _apellido2Ctrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contraCtrl = TextEditingController();

  Rol? _rolSeleccionado;
  Grupo? _grupoSeleccionado;
  late Future<List<Grupo>> _futureGrupos;
  bool _loading = false;
  bool _checkingEmail = false;
  String? _emailError;

  /// Al iniciar obtiene los grupos
  @override
  void initState() {
    super.initState();
    _futureGrupos = GrupoService().getGrupos();
  }

  /// Cuando la aplicacion se va a "destruir", elimina la informacion de los atributos
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellido1Ctrl.dispose();
    _apellido2Ctrl.dispose();
    _emailCtrl.dispose();
    _contraCtrl.dispose();

    super.dispose();
  }

  /// Un InputDecoration para reciclar codigo
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Llama al servicio para comprobar si el email existe
  Future<void> _comprobarMail(String email) async {
    setState(() {
      _checkingEmail = true;
    });
    try {
      final enUso = await UsuarioService().emailEnUso(email);
      setState(() {
        _emailError = enUso ? 'Este correo ya está registrado' : null;
      });
    } catch (_) {
      // opcional: manejar error de red…
    } finally {
      setState(() {
        _checkingEmail = false;
      });
      _formKey.currentState?.validate();
    }
  }

  /// Valida el usuario y llama al servicio para crearlo
  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rolSeleccionado == null || _grupoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona rol y grupo')),
      );
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      final nuevoUsuario = Usuario(
        id: 0,
        nombre: _nombreCtrl.text.trim(),
        apellido1: _apellido1Ctrl.text.trim(),
        apellido2: _apellido2Ctrl.text.trim().isEmpty
            ? null
            : _apellido2Ctrl.text.trim(),
        email: _emailCtrl.text.trim(),
        contrasena: _contraCtrl.text.trim(),
        rol: _rolSeleccionado!,
        grupoId: _grupoSeleccionado!.id,
        estado: Estado.activo,
      );
      await UsuarioService().crearUsuario(nuevoUsuario, _grupoSeleccionado!.id!);
      // con esto confirmo a la clase padre de que se a creado el usuario para que haga un refresh
      widget.onCreated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el usuario')),
      );
    } finally {
      // mounted es una propiedad de Setstate que sirve para saber si el state esta "montado" 
      //y si no lo esta no se hace el setState para que no salte un error
      if (mounted){
        setState(() {
           _loading = false;
        });
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // obtener los colores
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Grupo>>(
      future: _futureGrupos,
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
            child: Center(child: Text('Error cargando los grupos')),
          );
        }
        final grupos = snap.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: _inputDecoration('Nombre', Icons.person),
                  validator: (value) {
                    if (value  == null|| value.isEmpty){
                      return "Introduce un nombre";
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apellido1Ctrl,
                  decoration: _inputDecoration('Apellido 1', Icons.badge),
                  validator: (value) {
                    if (value  == null|| value.isEmpty){
                      return "Introduce un apellido";
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apellido2Ctrl,
                  decoration: _inputDecoration('Apellido 2 (opcional)', Icons.badge_outlined),
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
                    errorText: _emailError,
                  ),

                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) {
                    // reseteamos el error local
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                    // y lanzamos la comprobación si lleva un '@'
                    if (val.contains('@')) {
                      _comprobarMail(val.trim());
                    }
                  },
                  validator: (value) {
                    if (value  == null|| value.isEmpty){
                      return "Introduce un correo";
                    }
                    if (_emailError != null){
                      return _emailError;
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contraCtrl,
                  decoration: _inputDecoration('Contraseña', Icons.lock),
                  obscureText: false,
                  validator: (value) {
                    if (value  == null|| value.isEmpty){
                      return "Introduce una contraseña";
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Rol>(
                  value: _rolSeleccionado,
                  decoration: _inputDecoration('Rol', Icons.admin_panel_settings),
                  items: Rol.values
                      .map((rol) => DropdownMenuItem(value: rol, child: Text(rol.name)))
                      .toList(),
                  onChanged: (rol) => setState(() => _rolSeleccionado = rol),
                  validator: (value) {
                    if (value  == null){
                      return "Selecciona un rol";
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Grupo>(
                  value: _grupoSeleccionado,
                  decoration: _inputDecoration('Grupo', Icons.group),
                  items: grupos
                      .map((grupo) => DropdownMenuItem(value: grupo, child: Text(grupo.nombre)))
                      .toList(),
                  onChanged: (grupo) => setState(() => _grupoSeleccionado = grupo),
                  validator: (value) {
                    if (value  == null){
                      return "Selecciona un rol";
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _loading ? null : _crearUsuario,
                    child: const Text('Crear Usuario'),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: scheme.error
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar', style: TextStyle(color: scheme.onPrimary),),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
