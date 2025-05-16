import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';

typedef OnUsuarioCreated = void Function();

class AdminUsuarioCrearDialogo extends StatefulWidget {
  final OnUsuarioCreated onCreated;
  const AdminUsuarioCrearDialogo({super.key, required this.onCreated});

  @override
  _AdminUsuarioCrearDialogoState createState() => _AdminUsuarioCrearDialogoState();
}

class _AdminUsuarioCrearDialogoState extends State<AdminUsuarioCrearDialogo> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellido1Ctrl = TextEditingController();
  final _apellido2Ctrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contraCtrl = TextEditingController();

  Rol? _rolSeleccionado;
  Grupo? _grupoSeleccionado;

  bool _mostrarContrasena = true;
  bool _loading = false;
  bool _comprobandoCorreo = false;
  String? _emailError;

  late Future<List<dynamic>> _futureData;


  /// Al iniciar obtiene los grupos y usuarios
  @override
  void initState() {
    super.initState();
    _futureData = Future.wait([
      GrupoService().getGrupos(),
      UsuarioService().getUsuariosActivos()
    ]);
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

  /// InputDecoration para reciclar codigo
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
  

  /// Llama al servicio para comprobar si el email existe
   Future<void> _comprobarCorreo(String email, List<Usuario> usuarios) async {
    setState(() {
      _comprobandoCorreo = true;
    });
    final correo = '${email.trim().toLowerCase()}@educa.jcyl.es';
    final enUso = usuarios.any((usuario) => usuario.email.toLowerCase() == correo);
    setState(() {
      _emailError = enUso ? 'Este correo ya está registrado' : null;
      _comprobandoCorreo = false;
    });
    _formKey.currentState?.validate();
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
      final correo = _emailCtrl.text.trim().toLowerCase();
      final correoFinal  = '$correo@educa.jcyl.es';
      final nuevoUsuario = Usuario(
        id: 0,
        nombre: _nombreCtrl.text.trim(),
        apellido1: _apellido1Ctrl.text.trim(),
        apellido2: _apellido2Ctrl.text.trim().isEmpty
            ? null
            : _apellido2Ctrl.text.trim(),
        email: correoFinal,
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // obtener los colores
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
            child: Center(child: Text('Error cargando los datos')),
          );
        }
        final grupos = snap.data![0] as List<Grupo>;
        final usuarios = snap.data![1] as List<Usuario>;
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
                    suffixText: '@educa.jcyl.es',
                    suffixIcon: _comprobandoCorreo
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
                  onChanged: (value) {
                    if (_emailError != null) {
                      setState(() {
                        _emailError = null;
                      });
                    }
                    _comprobarCorreo(value.trim(), usuarios);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduce un correo';
                    }
                    if (_emailError != null) {
                      return _emailError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contraCtrl,
                  decoration: _inputDecoration('Contraseña', Icons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarContrasena ? Icons.visibility : Icons.visibility_off
                      ),
                      onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
                    ),
                  ),
                  obscureText: _mostrarContrasena,
                  validator: (value) {
                    if (value  == null|| value.isEmpty){
                      return "Introduce una contraseña";
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
                const SizedBox(height: 12),
                DropdownButtonFormField<Rol>(
                  value: _rolSeleccionado,
                  decoration: _inputDecoration('Rol', Icons.admin_panel_settings),
                  items: Rol.values
                      .map((rol) => DropdownMenuItem(value: rol, child: Text(rol.name)))
                      .toList(),
                  onChanged: (value)  {
                    setState(() {
                      _rolSeleccionado = value;
                    });
                  },
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
                  onChanged: (value) {
                    setState(() {
                      _grupoSeleccionado = value;
                    });
                  },
                  validator: (value) {
                    if (value  == null){
                      return "Selecciona un rol";
                    }
                    return null;
                  }
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar', style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: scheme.primary
                        ),
                        onPressed: _loading ? null : _crearUsuario,
                        child: Text('Crear', style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold)),
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
