
import 'package:flutter/material.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/service/ausencia_service.dart'; 

class JustificarAusenciaScreen extends StatefulWidget {
  final Usuario usuario;
  final DateTime fecha;

  const JustificarAusenciaScreen({
    Key? key,
    required this.usuario,
    required this.fecha,
  }) : super(key: key);

  @override
  State<JustificarAusenciaScreen> createState() => _JustificarAusenciaScreenState();
}

class _JustificarAusenciaScreenState extends State<JustificarAusenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  Motivo _selectedMotivo = Motivo.falta_injustificada;
  final _detallesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _detallesCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarJustificante() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AusenciaService.crearAusencia(
        idUsuario: widget.usuario.id,
        fecha: widget.fecha,
        motivo: _selectedMotivo,
        detalles: _detallesCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ausencia generada correctamente')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error')),
      );
      print(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
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
                  style: txt.bodyLarge),
              const SizedBox(height: 8),
              Text('Fecha: $fechaStr', style: txt.bodyLarge),
              const SizedBox(height: 24),

              // Selector de motivo
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
                onChanged: (v) {
                  if (v != null) setState(() => _selectedMotivo = v);
                },
              ),
              const SizedBox(height: 16),

              // Detalles / descripción
              TextFormField(
                controller: _detallesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) {
                  // Si el motivo es "otro", obligamos un detalle
                  if (_selectedMotivo == Motivo.otro && (v == null || v.isEmpty)) {
                    return 'Describe la ausencia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                onPressed: _enviarJustificante,
                icon: Icon(Icons.send,color: scheme.onPrimary), 
                label: const Text('Generar ausencia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: txt.labelLarge,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
