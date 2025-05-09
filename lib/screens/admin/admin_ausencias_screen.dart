// lib/screens/admin/admin_ausencias_screen.dart

import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/utils/tamanos.dart';


class AdminAusenciasScreen extends StatefulWidget {
  const AdminAusenciasScreen({super.key});
  @override
  _AdminAusenciasScreenState createState() => _AdminAusenciasScreenState();
}

class _AdminAusenciasScreenState extends State<AdminAusenciasScreen> {
  late Future<void> _initData;
  List<Ausencia> _ausencias = [];
  List<Usuario> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final aus = await AusenciaService().getAusencias();
    final us = await UsuarioService().getUsuarios();
    setState(() {
      _ausencias = aus;
      _usuarios = us;
    });
  }

  Future<void> _refresh() async => _cargarDatos();

  Color _avatarColor(int id) => Colors.primaries[id % Colors.primaries.length];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < Tamanos.movilMaxAnchura;
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<void>(
      future: _initData,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: isMobile
              ? null
              : AppBar(title: const Text('Ausencias'), centerTitle: true),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: _ausencias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = _ausencias[i];
                // Buscar nombre de usuario
                final usuario = _usuarios.firstWhere(
                  (u) => u.id == a.usuario.id,
                  orElse: () => a.usuario,
                );
                final initials =
                    '${usuario.nombre[0]}${usuario.apellido1[0]}';
                final bg = _avatarColor(usuario.id);
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: bg,
                      foregroundColor: scheme.onPrimary,
                      child: Text(initials),
                    ),
                    title:
                        Text('${usuario.nombre} ${usuario.apellido1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha: ${a.fecha.toLocal().toString().split(' ')[0]}',
                        ),
                        Text('Motivo: ${a.motivo.name}'),
                        Text('Estado: ${a.estado.name}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Eliminar
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dctx) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  titlePadding:
                                      const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(
                                          40, 12, 24, 0),
                                  actionsPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                  title: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Eliminar ausencia',
                                        style: TextStyle(
                                          color: scheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  content: Text(
                                    '¿Seguro que quieres eliminar la ausencia del\n'
                                    '${usuario.nombre} ${usuario.apellido1}?',
                                    textAlign: TextAlign.center,
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.center,
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(dctx, false),
                                      style:
                                          ElevatedButton.styleFrom(
                                        elevation: 2,
                                        backgroundColor:
                                            scheme.error,
                                        minimumSize:
                                            const Size(100, 40),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancelar',
                                        style: TextStyle(
                                            color:
                                                scheme.onError),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(dctx, true),
                                      style:
                                          ElevatedButton.styleFrom(
                                        elevation: 2,
                                        backgroundColor:
                                            scheme.primary,
                                        minimumSize:
                                            const Size(100, 40),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Eliminar',
                                        style: TextStyle(
                                            color:
                                                scheme.onPrimary),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            /*if (confirm == true) {
                              await AusenciaService()
                                  .eliminarAusencia(a.id!);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Ausencia eliminada')),
                              );
                              _refresh();
                            }*/
                          },
                        ),
                        // Editar
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final edited = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) {
                                return AlertDialog(
                                  titlePadding: EdgeInsets.zero,
                                  title: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(12)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Editar Ausencia',
                                        style: TextStyle(
                                          color: scheme.onPrimary,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  insetPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 24),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(
                                          24, 0, 24, 24),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  /*content: SizedBox(
                                    width: 360,
                                    child:
                                        AdminUsuarioEditarDialog(
                                      // Sustituye por tu dialog de ausencias
                                      usuario: usuario,
                                      onEdited: () =>
                                          Navigator.of(ctx)
                                              .pop(true),
                                    ),
                                  ),*/
                                );
                              },
                            );
                            if (edited == true) {
                              _refresh();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Ausencia actualizada')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton:
              FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Nueva'),
            onPressed: () async {
              final created = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (ctx) {
                  return AlertDialog(
                    titlePadding: EdgeInsets.zero,
                    title: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                      child: Center(
                        child: Text(
                          'Crear Ausencia',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    insetPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 24),
                    contentPadding:
                        const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                    /*content: SizedBox(
                      width: 360,
                      child:
                          AdminCrearAusenciaDialog(
                        onCreated: () =>
                            Navigator.of(ctx).pop(true),
                      ),
                    ),*/
                  );
                },
              );
              if (created == true) {
                _refresh();
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Ausencia creada correctamente')),
                );
              }
            },
          ),
        );
      },
    );
  }
}
