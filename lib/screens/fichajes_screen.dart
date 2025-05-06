import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/screens/login_screen.dart';
import 'package:riber_republic_fichaje_app/service/ausencia_service.dart';
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

  int? _idUsuario;
  
  @override
  void initState() {
    super.initState();
    __cargarUsuarioYFuturos();
  }



  // metodo para coger el usuario del provider y obtener tanto el horario de hoy, los fichajes del usuario como la ausencia de hoy.
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
        _fichajesFuture = FichajeService.getFichajesPorUsuario(_idUsuario!);
      });
    }
  }

  bool _mismaFecha(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
 
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
                final todosFichajes = fichSnap.data!;

                final trabajadoTotalPorDia = FichajeUtils.sumarHorasPorDia(todosFichajes);
                // coge el map de trabajadoTotalPorDia y lo ordena, para poner primero la reciente a la mas antigua.
                final dias = trabajadoTotalPorDia.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  itemCount: dias.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, idx) {
                    final dia = dias[idx];
                    final durTotal = trabajadoTotalPorDia[dia]!;

                    final fichaDelDia = todosFichajes.firstWhere(
                      (f) => _mismaFecha(f.fechaHoraEntrada!, dia),
                    );
                    return FutureBuilder<bool>(
                      future: AusenciaService.existeAusencia(usuario.id, dia),
                      builder: (ctx, ausSnap) {
                        final existe = ausSnap.data == true;
                        // mientras carga o en error, deshabilitamos
                        final disabled = ausSnap.connectionState != ConnectionState.done || existe;

                        return FichajeCard(
                          fichaje: fichaDelDia,
                          horarioHoy: horarioHoy,
                          totalTrabajado: durTotal,
                          yaJustificado: disabled,
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
