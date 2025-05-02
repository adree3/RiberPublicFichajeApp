import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/screens/login_screen.dart';
import 'package:riber_republic_fichaje_app/service/fichaje_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/utils/fichajeUtils.dart';
import 'package:riber_republic_fichaje_app/widgets/fichaje_card.dart';

class FichajesScreen extends StatefulWidget {
  const FichajesScreen({super.key});

  @override
  State<FichajesScreen> createState() => FichajesScreenState();
}

class FichajesScreenState extends State<FichajesScreen> {
  Timer? _timer;

  late Future<HorarioHoy> _horarioFuture;
  late Future<List<Fichaje>> _fichajesFuture;
  int? _idUsuario;
  
  @override
  void initState() {
    super.initState();
    __cargarUsuarioYFuturos();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }



  // metodo para coger el usuario del provider y obtener tanto el horario de hoy como los fichajes del usuario
  void __cargarUsuarioYFuturos() {
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    _idUsuario = usuario?.id;
    if (_idUsuario != null) {
      _horarioFuture  = UsuarioService.getHorarioDeHoy(_idUsuario!);
      _fichajesFuture = FichajeService.getFichajesPorUsuario(_idUsuario!);
    }
  }

  // este metodo se utiliza desde home para recargar los fichajes
  void recargarFichajes() {
    if (_idUsuario != null) {
      setState(() {
        // vuelve a crear el future para forzar la llamada a la API
        _fichajesFuture = FichajeService.getFichajesPorUsuario(_idUsuario!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Fichaje> _fichajesDeHoy = [];
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    // si el usuario es null vuelve al login, para que se logge, 
    //utilizo esta forma ya que si utilizo el navigator.push directamente da un error de setState.
    if (usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold();
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: FutureBuilder<HorarioHoy>(
          future: _horarioFuture,
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
                          "Fichajes de ${usuario!.nombre}",
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
                    future: _fichajesFuture,
                    builder: (context, fichajeSnapshot) {
                      if (fichajeSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (fichajeSnapshot.hasError) {
                        return Center(child: Text("Error: ${fichajeSnapshot.error}"));
                      }
                      if (!fichajeSnapshot  .hasData || fichajeSnapshot.data!.isEmpty) {
                        return const Center(child: Text("No hay fichajes"));
                      }
                      final fichajes = fichajeSnapshot.data!;
                      _fichajesDeHoy = FichajeUtils.filtradosDeHoy(fichajes);


                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        itemCount: fichajes.length,
                        separatorBuilder: (context, __) => const SizedBox(height: 14),
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
