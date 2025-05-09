// lib/screens/admin/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/service/grupo_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/utils/tamanos.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/admin_crear_usuario_dialog.dart';
import 'package:riber_republic_fichaje_app/widgets/admin/admin_editar_usuario_dialog.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});
  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  late Future<void> _initData;
  List<Usuario> _usuarios = [];
  List<Grupo> _grupos = [];

  final _emailFiltroCtrl = TextEditingController();
  Grupo? _filtrarGrupo;

  /// Al iniciar el state se obtienen los grupos y usuarios
  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }

  /// Obtiene de la Api los grupos y usuarios y lo iguala a las listas de usuarios y grupos
  Future<void> _cargarDatos() async {
    final grupos = await GrupoService().getGrupos();
    final usuarios = await UsuarioService().getUsuarios();
    setState(() {
      _grupos = grupos;
      _usuarios = usuarios;
    });
  }

  /// Vuelve a pedir los grupos y usuarios de la API
  Future<void> _recargar() async {
    await _cargarDatos();
  }

  /// Filtra los usuarios, y devuelve los usuarios que cumplan los criterios de emaiIgual y grupoIgual
  List<Usuario> get _flitros {
    return _usuarios.where((usuario) {
      // comprueba que el usuario que esta recorriendo sea igual al del textForm
      final emailIgual = usuario.email.toLowerCase().contains(
            _emailFiltroCtrl.text.toLowerCase(),
          );
      // comprueba que el id del grupo es igual al indicado en el dropDownButton 
      final grupoIgual = _filtrarGrupo == null
          ? true
          : usuario.grupoId == _filtrarGrupo!.id;
      return emailIgual && grupoIgual;
    }).toList();
  }

  /// Hace un color "random" a partir del id del usuario y dividendolo con los colores primarios, para tener siempre un color diferente
  Color _avatarColor(int id) {
    return Colors.primaries[id % Colors.primaries.length];
  }

  Future<bool?> _mostrarConfirmacion(BuildContext context, Usuario usuario, ColorScheme scheme) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              'Eliminar usuario',
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        content: Text(
          '¿Está seguro de que deseas eliminar a\n'
          '${usuario.nombre} ${usuario.apellido1}?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 12),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dctx, false),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              foregroundColor: scheme.primary,
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(dctx, true),
            style: ElevatedButton.styleFrom(
              elevation: 2,
              backgroundColor: scheme.error,
              foregroundColor: scheme.onPrimary,
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // esquema de los colores
    final scheme = Theme.of(context).colorScheme;
    // booleano, true si el tamaño de la pantalla es menor que el valor de movilMaxAnchura (600)
    final isMobile = MediaQuery.of(context).size.width < Tamanos.movilMaxAnchura;

    return FutureBuilder<void>(
      future: _initData,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          // si no es vista movil no pone el appBar
          appBar: isMobile
              ? null
              : AppBar(
                  title: const Text('Usuarios'),
                  centerTitle: true,
                ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailFiltroCtrl,
                        decoration: InputDecoration(
                          labelText: 'Filtrar por email',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (_){
                          setState(() {});
                        }
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<Grupo>(
                        value: _filtrarGrupo,
                        decoration: InputDecoration(
                          labelText: 'Grupo',
                          prefixIcon: Icon(Icons.group),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: [
                          const DropdownMenuItem<Grupo>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          // con el spread operator, convierte cada g de _grupos en el dropDownMenuItem
                          // el spread operator itera la lista de lo que sea, en este caso de _grupos
                          ..._grupos.map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g.nombre),
                              )),
                        ],
                        onChanged: (g) {
                          setState(() {
                            _filtrarGrupo = g;
                          });
                        }
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                // El refeshIndicator, es para que se actualice la lista cuando subes o bajas
                child: RefreshIndicator(
                  onRefresh: _recargar,
                  child: ListView.separated(
                    padding:const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: _flitros.length,
                    separatorBuilder: (_, __) =>const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final usuario = _flitros[i];
                      final iniciales ='${usuario.nombre[0]}${usuario.apellido1[0]}';
                      final colorFondo = _avatarColor(usuario.id);
                      // coge el primer grupo (el nombre) de la lista de grupos que cumpla el requisito, sino pone un vacio
                      final grupo = _grupos
                              .firstWhere(
                                (g) => g.id == usuario.grupoId,
                                orElse: () => Grupo(
                                  id: 0,
                                  nombre: '—',
                                  faltasTotales: 0,
                                  usuarios: [],
                                  horarios: [],
                                ),
                              )
                              .nombre;
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:BorderRadius.circular(12)
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorFondo,
                            foregroundColor: scheme.onPrimary,
                            child: Text(iniciales),
                          ),
                          title: Text('${usuario.nombre} ${usuario.apellido1}'),
                          subtitle: Column(
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              Text(usuario.email),
                              Text('Grupo: $grupo'),
                            ],
                          ),
                          // para reservar 3 lineas al listTile
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: scheme.error),
                                onPressed: () async {
                                  final confirmar = await _mostrarConfirmacion(context, usuario, scheme);
                                  if (confirmar == true) {
                                    await UsuarioService().eliminarUsuario(usuario.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Usuario eliminado')),
                                    );
                                    _recargar();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _onEdit(usuario, scheme),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton:FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
            onPressed:(){
              _onCreate(scheme);
            },
          ),
        );
      },
    );
  }

  void _onCreate(ColorScheme scheme) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                'Crear Usuario',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            width: 360,
            child: AdminUsuarioCrearDialogo(
              onCreated: () => Navigator.of(context).pop(true),
            ),
          ),
        );
      },
    ).then((created) {
      if (created == true) {
        _recargar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado correctamente')),
        );
      }
    });
  }

  void _onEdit(Usuario usuario, ColorScheme scheme) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                'Editar Usuario',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            width: 360,
            child: AdminUsuarioEditarDialog(
              usuario: usuario,
              onEdited: () => Navigator.of(context).pop(true),
            ),
          ),
        );
      },
    ).then((edited) {
      if (edited == true) {
        _recargar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado')),
        );
      }
    });
  }
}
