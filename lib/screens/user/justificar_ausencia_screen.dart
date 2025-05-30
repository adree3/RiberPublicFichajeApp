
import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';
import 'package:riber_republic_fichaje_app/widgets/snackbar.dart'; 

class JustificarAusenciaScreen extends StatefulWidget {
  final Usuario usuario;
  final DateTime fecha;

  const JustificarAusenciaScreen({
    super.key,
    required this.usuario,
    required this.fecha,
  });

  @override
  State<JustificarAusenciaScreen> createState() => _JustificarAusenciaScreenState();
}

class _JustificarAusenciaScreenState extends State<JustificarAusenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  Motivo _selectedMotivo = Motivo.falta_injustificada;
  final _detallesCtrl = TextEditingController();
  bool _loading = false;

  /// Cuando se cierre se eliminan los datos para no perderlos
  @override
  void dispose() {
    _detallesCtrl.dispose();
    super.dispose();
  }

  /// Crea una ausencia
  Future<void> _crearAusencia() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AusenciaService.crearAusencia(
        idUsuario: widget.usuario.id,
        fecha: widget.fecha,
        motivo: _selectedMotivo,
        detalles: _detallesCtrl.text.trim(),
      );

      AppSnackBar.show(
        context,
        message: 'Ausencia generada',
        backgroundColor: Colors.green.shade600,
        icon: Icons.check_circle,
      );
      Navigator.of(context).pop();
    } catch (e) {
      AppSnackBar.show(
        context,
        message: 'Error al generar la ausencia',
        backgroundColor: Colors.red.shade600,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted){
        setState(() {
          _loading = false;
        });
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final txtScheme = Theme.of(context).textTheme;
    final fechaStr = '${widget.fecha.day}/${widget.fecha.month}/${widget.fecha.year}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Registrar ausencia'),
        backgroundColor: scheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Usuario: ${widget.usuario.nombre} ${widget.usuario.apellido1}',
                  style: txtScheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Fecha: $fechaStr', style: txtScheme.bodyLarge),
              const SizedBox(height: 24),

              DropdownButtonFormField<Motivo>(
                value: _selectedMotivo,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  border: OutlineInputBorder(),
                ),
                items: Motivo.values.map((m) {
                  String motivo;
                  switch (m) {
                    case Motivo.retraso: motivo = 'Retraso'; break;
                    case Motivo.permiso: motivo = 'Permiso'; break;
                    case Motivo.vacaciones: motivo = 'Vacaciones'; break;
                    case Motivo.enfermedad: motivo = 'Enfermedad'; break;
                    case Motivo.falta_injustificada: motivo = 'Falta injustificada'; break;
                    case Motivo.otro: motivo = 'Otro'; break;
                  }
                  return DropdownMenuItem(value: m, child: Text(motivo));
                }).toList(),
                onChanged: (value) {
                  if (value != null){
                    setState(() {
                      _selectedMotivo = value;
                    });
                  };
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _detallesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (_selectedMotivo == Motivo.otro && (value == null || value.isEmpty)) {
                    return 'Describe la ausencia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                onPressed: _crearAusencia,
                icon: Icon(Icons.send,color: scheme.onPrimary), 
                label: const Text('Generar ausencia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: txtScheme.labelLarge,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
