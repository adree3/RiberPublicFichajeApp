 import 'package:flutter/material.dart';
  import 'package:riber_republic_fichaje_app/model/ausencia.dart';
  import 'package:riber_republic_fichaje_app/model/usuario.dart';
  import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';
  import 'package:riber_republic_fichaje_app/service/usuario_service.dart';

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
      final ausencia = await AusenciaService().getAusencias();
      final usuario = await UsuarioService().getUsuarios();
      setState(() {
        _ausencias = ausencia;
        _usuarios = usuario;
      });
      
    }
    

    Future<void> _recargar() async {
      _cargarDatos();
    }

    Color _avatarColor(int id) =>
        Colors.primaries[id % Colors.primaries.length];

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<void>(
        future: _initData,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: _ausencias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final ausencia = _ausencias[i];
                final usuario = _usuarios.firstWhere(
                  (u) => u.id == ausencia.usuario.id,
                  orElse: () => ausencia.usuario,
                );

                Color cardColor;
                switch (ausencia.estado) {
                  case EstadoAusencia.aceptada:
                    cardColor = Colors.green.shade50;
                    break;
                  case EstadoAusencia.rechazada:
                    cardColor = Colors.red.shade50;
                    break;
                  case EstadoAusencia.pendiente:
                    cardColor = Colors.white;
                    break;
                  case EstadoAusencia.vacio:
                    cardColor = Colors.white;
                    break;
                }

                Icon estadoIcon;
                switch (ausencia.estado) {
                  case EstadoAusencia.aceptada:
                    estadoIcon = Icon(Icons.check_circle, color: Colors.green);
                    break;
                  case EstadoAusencia.rechazada:
                    estadoIcon = Icon(Icons.cancel, color: Colors.red);
                    break;
                  default:
                    estadoIcon = Icon(Icons.hourglass_empty, color: Colors.grey);
                }

                return Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _avatarColor(usuario.id),
                      child: Text(
                        '${usuario.nombre[0]}${usuario.apellido1[0]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text('${usuario.nombre} ${usuario.apellido1}')),
                        estadoIcon, // el icono de estado
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${ausencia.fecha.toLocal().toString().split(' ')[0]}'),
                        Text('Motivo: ${ausencia.motivo.name}'),
                        if (ausencia.motivo == Motivo.otro && ausencia.detalles != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Descripción: ${ausencia.detalles}'),
                          ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1️⃣ Dropdown para cambiar el estado
                            DropdownButtonFormField<EstadoAusencia>(
                              decoration: const InputDecoration(
                                labelText: 'Estado de la ausencia',
                                border: OutlineInputBorder(),
                              ),
                              value: ausencia.estado,
                              items: EstadoAusencia.values.map((estado) {
                                return DropdownMenuItem(
                                  value: estado,
                                  child: Text(estado.name),
                                );
                              }).toList(),
                              onChanged: (nuevoEstado) {
                                if (nuevoEstado == null) return;
                                setState(() {
                                  ausencia.estado = nuevoEstado;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            // 2️⃣ Badge que muestra si está justificada o no
                            Row(
                              children: [
                                const Text('Justificada: '),
                                Chip(
                                  label: Text(
                                    ausencia.justificada ? 'Sí' : 'No',
                                    style: TextStyle(
                                      color: ausencia.justificada
                                          ? Colors.green[800]
                                          : Colors.red[800],
                                    ),
                                  ),
                                  backgroundColor: ausencia.justificada
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // 3️⃣ Botón de guardar
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Guardar'),
                                onPressed: () async {
                                  try {
                                    await AusenciaService.actualizarAusencia(
                                      idAusencia: ausencia.id!,
                                      estado: ausencia.estado,
                                      detalles: ausencia.detalles,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Ausencia actualizada')),
                                    );
                                    _recargar();
                                  } catch (_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Error al actualizar la ausencia')),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          );
        },
      );
    }
  }
