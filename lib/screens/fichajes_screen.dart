import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/service/fichaje_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/widgets/fichaje_card.dart';

class FichajesScreen extends StatelessWidget {
  const FichajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    final int? idUsuario = usuario?.id;

    if (idUsuario == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario logueado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: FutureBuilder<HorarioHoy?>(
          future: UsuarioService.getHorarioDeHoy(idUsuario),
          builder: (context, horarioSnapshot) {
            if (horarioSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (horarioSnapshot.hasError) {
              return Center(child: Text("Error cargando horario: ${horarioSnapshot.error}"));
            }
            if (!horarioSnapshot.hasData || horarioSnapshot.data == null) {
              return const Center(child: Text("No hay horario para hoy."));
            }

            final horarioHoy = horarioSnapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          "Fichajes de ${usuario?.nombre}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Divider(thickness: 1.5),
                ),
                Expanded(
                  child: FutureBuilder<List<Fichaje>>(
                    future: FichajeService.getFichajesPorUsuario(idUsuario),
                    builder: (context, fichajeSnapshot) {
                      if (fichajeSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (fichajeSnapshot.hasError) {
                        return Center(child: Text("Error: ${fichajeSnapshot.error}"));
                      }
                      if (!fichajeSnapshot.hasData || fichajeSnapshot.data!.isEmpty) {
                        return const Center(child: Text("No hay fichajes"));
                      }
                      final fichajes = fichajeSnapshot.data!;
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        itemCount: fichajes.length,
                        separatorBuilder: (context, idx) => const SizedBox(height: 14),
                        itemBuilder: (context, idx) {
                          return FichajeCard(
                            fichaje: fichajes[idx],
                            horarioHoy: horarioHoy,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
