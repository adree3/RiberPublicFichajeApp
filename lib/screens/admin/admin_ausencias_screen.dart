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
      print('--- Montando AdminAusenciasScreen ---');
      _initData = _cargarDatos();
    }

    Future<void> _cargarDatos() async {
      final aus = await AusenciaService().getAusencias();
      final us = await UsuarioService().getUsuarios();
      setState(() {
        _ausencias = aus;
        _usuarios = us;
      });
      print(_ausencias);
      
    }
    

    Future<void> _refresh() async => _cargarDatos();

    Color _avatarColor(int id) =>
        Colors.primaries[id % Colors.primaries.length];

    @override
    Widget build(BuildContext context) {
      print('--- build Ausencias: estado de conexión del FutureBuilder ---');
      return FutureBuilder<void>(
        future: _initData,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: _ausencias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = _ausencias[i];
                final usuario = _usuarios.firstWhere(
                  (u) => u.id == a.usuario.id,
                  orElse: () => a.usuario,
                );
                final initials =
                    '${usuario.nombre[0]}${usuario.apellido1[0]}';
                final bg = _avatarColor(usuario.id);
                return Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 2,
  child: ExpansionTile(
    leading: CircleAvatar(
      backgroundColor: bg,
      child: Text(initials),
    ),
    title: Text('${usuario.nombre} ${usuario.apellido1}'),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha: ${a.fecha.toLocal().toString().split(' ')[0]}',
        ),
        Text('Motivo: ${a.motivo.name}'),
        // si el motivo es 'otro', mostramos detalles
        if (a.motivo == Motivo.otro && a.detalles != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Descripción: ${a.detalles}'),
          ),
      ],
    ),
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown para editar Estado
            DropdownButtonFormField<EstadoAusencia>(
              decoration: const InputDecoration(
                labelText: 'Estado de la tarea',
                border: OutlineInputBorder(),
              ),
              value: a.estado,
              items: EstadoAusencia.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (nuevoEstado) {
                if (nuevoEstado == null) return;
                setState(() {
                  a.estado = nuevoEstado;
                });
              },
            ),
            const SizedBox(height: 12),
            // Toggle para justificada
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Justificada'),
              value: a.justificada,
              onChanged: (v) {
                setState(() {
                  a.justificada = v;
                });
              },
            ),
            const SizedBox(height: 12),
            // Botón para guardar cambios
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                onPressed: () async {
                  // Lógica para enviar a servidor:
                  try {
                    await AusenciaService.crearAusencia(
                      idUsuario: a.usuario.id,
                      fecha: a.fecha,
                      motivo: a.motivo,
                      detalles: a.detalles,
                    );
                    // suponiendo que crearAusencia devuelve la ausencia actualizada...
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ausencia actualizada')),
                    );
                    _refresh();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar: $e')),
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
              },
            ),
          );
        },
      );
    }
  }
