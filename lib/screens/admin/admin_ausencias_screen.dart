 import 'package:flutter/material.dart';
  import 'package:riber_republic_fichaje_app/model/ausencia.dart';
  import 'package:riber_republic_fichaje_app/model/usuario.dart';
  import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';
  import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/widgets/snackbar.dart';

class AdminAusenciasScreen extends StatefulWidget {
  const AdminAusenciasScreen({super.key});
  @override
  AdminAusenciasScreenState createState() => AdminAusenciasScreenState();
}

class AdminAusenciasScreenState extends State<AdminAusenciasScreen> {
  late Future<void> _initData;
  List<Ausencia> _ausencias = [];
  List<Usuario> _usuarios = [];

  final _filtroCtrl = TextEditingController();
  EstadoAusencia? _filtroEstado;

  /// Llama a cargar datos al iniciar la pantalla
  @override
  void initState() {
    super.initState();
    _initData = _cargarDatos();
  }

  /// Recupera del API las a usencias y usuarios (solo carga las ausencias las cuales
  /// su usuario este activo)
  Future<void> _cargarDatos() async {
    final ausencias = await AusenciaService().getAusencias();
    final usuarios = await UsuarioService().getEmpleadosActivos();
    setState(() {
      _usuarios = usuarios;
      _ausencias = ausencias
        .where((a) => usuarios.any((u) => u.id == a.usuario.id))
        .toList()
        ..sort((a,b)=> b.fecha.compareTo(a.fecha));
    });
  }

  /// Vuelve a obtener las ausencias y usuarios
  Future<void> recargar() async {
    _cargarDatos();
  }

  /// Calcula el color del avatar dividiendo los colores primarios entre el id recibido
  Color _avatarColor(int id) =>
      Colors.primaries[id % Colors.primaries.length];

  /// Lista filtrada por texto y estado (agrupando vacio y pendiente en el mismo)
  List<Ausencia> get _filtradas {
    return _ausencias.where((a) {
      final usuario = _usuarios.firstWhere((u) => u.id == a.usuario.id, orElse: () => a.usuario);
      final nombreCompleto = '${usuario.nombre} ${usuario.apellido1}'.toLowerCase();
      // Filtro texto
      if (_filtroCtrl.text.isNotEmpty &&
          !nombreCompleto.contains(_filtroCtrl.text.toLowerCase())) {
        return false;
      }
      // Filtro estado
      if (_filtroEstado != null) {
        if (_filtroEstado == EstadoAusencia.pendiente) {
          if (a.estado != EstadoAusencia.pendiente && a.estado != EstadoAusencia.vacio) {
            return false;
          }
        } else if (a.estado != _filtroEstado) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initData,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    // Filtro de nombre
                    child: TextField(
                      controller: _filtroCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nombre y apellidos',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // Desplegable para el filtro estado
                    child: DropdownButtonFormField<EstadoAusencia?>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por estado',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      value: _filtroEstado,
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Todos'),
                        ),
                        DropdownMenuItem(
                          value: EstadoAusencia.pendiente,
                          child: Text('Pendiente'),
                        ),
                        DropdownMenuItem(
                          value: EstadoAusencia.aceptada,
                          child: Text('Aceptada'),
                        ),
                        DropdownMenuItem(
                          value: EstadoAusencia.rechazada,
                          child: Text('Rechazada'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filtroEstado = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: recargar,
                // Lista de Ausencias se recarga al bajar
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, kBottomNavigationBarHeight + 16),
                  itemCount: _filtradas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final ausencia = _filtradas[i];
                    final usuario = _usuarios.firstWhere(
                      (u) => u.id == ausencia.usuario.id,
                      orElse: () => ausencia.usuario,
                    );
                    Color colorCard;
                    Icon iconoEstadoCard;
                    switch (ausencia.estado) {
                      case EstadoAusencia.aceptada:
                        colorCard = Colors.green.shade50;
                        iconoEstadoCard = const Icon(Icons.check_circle, color: Colors.green);
                        break;
                      case EstadoAusencia.rechazada:
                        colorCard = Colors.red.shade50;
                        iconoEstadoCard = const Icon(Icons.cancel, color: Colors.red);
                        break;
                      default:
                        colorCard = Colors.white;
                        iconoEstadoCard = const Icon(Icons.hourglass_empty, color: Colors.grey);
                    }
                    return Card(
                      color: colorCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _avatarColor(usuario.id),
                          child: Text(
                            '${usuario.nombre[0]}${usuario.apellido1[0]}'.toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text('${usuario.nombre} ${usuario.apellido1} ${usuario.apellido2 ?? ""}')),
                            iconoEstadoCard,
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha: ${ausencia.fecha.toLocal().toString().split(' ')[0]}',
                            ),
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
                                DropdownButtonFormField<EstadoAusencia>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Cambiar estado',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: ausencia.estado,
                                  items: EstadoAusencia.values.map((estado) {
                                    return DropdownMenuItem(
                                      value: estado,
                                      child: Text(estado.name),
                                    );
                                  }).toList(),
                                  onChanged: (nuevoEstado) async {
                                    if (nuevoEstado == null) return;
                                    final viejo = ausencia.estado;
                                    setState(() {
                                      ausencia.estado = nuevoEstado;
                                      ausencia.justificada = (nuevoEstado == EstadoAusencia.aceptada);
                                    });
                                    try {
                                      await AusenciaService.actualizarAusencia(
                                        idAusencia: ausencia.id!,
                                        estado: nuevoEstado,
                                        detalles: ausencia.detalles,
                                      );
                                      AppSnackBar.show(
                                        context,
                                        message: 'Estado actualizado correctamente',
                                        backgroundColor: Colors.green.shade600,
                                        icon: Icons.check_circle,
                                      );

                                    } catch (e) {
                                      setState(() {
                                        ausencia.estado = viejo;
                                        ausencia.justificada =(viejo == EstadoAusencia.aceptada);
                                      });
                                      AppSnackBar.show(
                                        context,
                                        message: 'Error al actualizar el estado',
                                        backgroundColor: Colors.red.shade700,
                                        icon: Icons.error_outline,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text('Justificada: '),
                                    Chip(
                                      label: Text(
                                        ausencia.justificada ? 'Sí' : 'No',
                                        style: TextStyle(
                                          color: ausencia.justificada
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      backgroundColor: ausencia.justificada
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}