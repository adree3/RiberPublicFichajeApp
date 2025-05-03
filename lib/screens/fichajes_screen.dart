import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/model/totalHorasHoy.dart';
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

  late Future<HorarioHoy> _horarioFuture;
  late Future<List<Fichaje>> _fichajesFuture;
  late Future<TotalHorasHoy> _totalHoyFuture;

  int? _idUsuario;
  
  @override
  void initState() {
    super.initState();
    __cargarUsuarioYFuturos();
  }



  // metodo para coger el usuario del provider y obtener tanto el horario de hoy, los fichajes del usuario y el total trabajado hoy
  void __cargarUsuarioYFuturos() {
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    _idUsuario = usuario?.id;
    if (_idUsuario != null) {
      _horarioFuture  = UsuarioService.getHorarioDeHoy(_idUsuario!);
      _fichajesFuture = FichajeService.getFichajesPorUsuario(_idUsuario!);
      _totalHoyFuture = FichajeService.getTotalHorasHoy(_idUsuario!);
    }
  }

  // este metodo se utiliza desde home para recargar los fichajes
  void recargarFichajes() {
    if (_idUsuario != null) {
      setState(() {
        // vuelve a crear el future para forzar la llamada a la API
        _fichajesFuture = FichajeService.getFichajesPorUsuario(_idUsuario!);
        _totalHoyFuture = FichajeService.getTotalHorasHoy(_idUsuario!);
      });
    }
  }
  // metodo para que el formato sea (HH:mm:ss)
  Duration _parseDuration(String hms) {
    final parts = hms.split(':').map(int.parse).toList();
    return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
  }


 
  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<HorarioHoy>(
          future: _horarioFuture,
          builder: (context, horSnap) {
            if (horSnap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (horSnap.hasError) {
              return Center(child: Text("Error horario: ${horSnap.error}"));
            }
            final horarioHoy = horSnap.data!;

            return FutureBuilder<List<Fichaje>>(
              future: _fichajesFuture,
              builder: (context, fichSnap) {
                if (fichSnap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (fichSnap.hasError) {
                  return Center(child: Text("Error fichajes: ${fichSnap.error}"));
                }
                final allFichajes = fichSnap.data!;
                final fichajesHoy = FichajeUtils.filtradosDeHoy(allFichajes);

                return FutureBuilder<TotalHorasHoy>(
                  future: _totalHoyFuture,
                  builder: (context, totSnap) {
                    if (totSnap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (totSnap.hasError) {
                      return Center(child: Text("Error total horas: ${totSnap.error}"));
                    }
                    // Parseamos "HH:mm:ss" a Duration
                    final parts = totSnap.data!.totalHoras.split(':').map(int.parse).toList();
                    final totalHoy = Duration(
                      hours: parts[0],
                      minutes: parts[1],
                      seconds: parts[2],
                    );

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      itemCount: fichajesHoy.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, idx) {
                        return FichajeCard(
                          fichaje:       fichajesHoy[idx],
                          horarioHoy:    horarioHoy,
                          totalTrabajado: totalHoy,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
