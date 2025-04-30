import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/screens/perfil_screen.dart';
import 'package:riber_republic_fichaje_app/screens/fichajes_screen.dart';
import 'package:riber_republic_fichaje_app/service/fichaje_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static final List<Widget> _screens = [
    const HomeContent(),  
    const FichajesScreen(),
    const PerfilScreen()
  ];
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  PreferredSizeWidget? _buildAppBar() {
    if (_currentIndex == 2) return null;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Color(0xFF76BCAD)),
          onPressed: () {
            setState(() {
              _currentIndex = 2;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _screens[_currentIndex], 
      appBar: _buildAppBar(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF76BCAD),
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Fichajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _trabajando = false;
  int? _fichajeIdEnCurso;

  @override
  void initState() {
    super.initState();
    _compruebaFichajeAbierto();
  }

  Future<void> _compruebaFichajeAbierto() async {
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario!;
    final fichajes = await FichajeService.getFichajesPorUsuario(usuario.id);
    final hoy = DateTime.now();
    
    final abierto = fichajes.firstWhereOrNull((f) =>
      f.fechaHoraEntrada != null &&
      f.fechaHoraEntrada!.day == hoy.day &&
      f.fechaHoraSalida == null
    );
    
    if (abierto != null) {
      setState(() {
        _trabajando = true;
        _fichajeIdEnCurso = abierto.id;
      });
    }
  }

  Future<void> _onBotonPulsado() async {
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario!;
    if (!_trabajando) {
      final creado = await FichajeService.crearFichaje(
        usuario.id,
        fechaHoraEntrada: DateTime.now(),
        ubicacion: "Oficina Principal",
        nfcUsado: true,
      );
      setState(() {
        _trabajando = true;
        _fichajeIdEnCurso = creado.id;
      });
    } else {
      // Termina jornada
      await FichajeService.cerrarFichaje(
        _fichajeIdEnCurso!,
        fechaHoraSalida: DateTime.now(),
      );
      setState(() {
        _trabajando = false;
        _fichajeIdEnCurso = null;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    final int? idUsuario = usuario?.id;

    if (idUsuario == null) {
      return const Center(child: Text("No hay usuario logueado"));
    }

    return FutureBuilder(
      future: Future.wait([
        UsuarioService.getHorarioDeHoy(idUsuario),
        FichajeService.getFichajesPorUsuario(idUsuario),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No se pudo cargar la información.'));
        }

        final HorarioHoy horarioHoy = snapshot.data![0] as HorarioHoy;
        final List<Fichaje> fichajes = snapshot.data![1] as List<Fichaje>;

        final now = DateTime.now();
        final fichajesDeHoy = fichajes.where((f) =>
          f.fechaHoraEntrada != null &&
          f.fechaHoraEntrada!.day == now.day &&
          f.fechaHoraEntrada!.month == now.month &&
          f.fechaHoraEntrada!.year == now.year
        ).toList();

        Duration horasTrabajadas = Duration.zero;
        if (fichajesDeHoy.isNotEmpty) {
          final fichajeDeHoy = fichajesDeHoy.first;
          if (fichajeDeHoy.fechaHoraSalida != null) {
            horasTrabajadas = fichajeDeHoy.fechaHoraSalida!.difference(fichajeDeHoy.fechaHoraEntrada!);
          }
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.image, size: 60, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                Text(
                  "¡Hola ${usuario?.nombre ?? 'Usuario'}!",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF008080),
                  ),
                ),
                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text("Horas trabajadas", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            _formateaDuracion(horasTrabajadas),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF57C00),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Horas estimadas", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            _formateaDuracion(horarioHoy.horasEstimadas),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00796B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: Container(height: 3, color: const Color(0xFFF57C00)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(height: 3, color: const Color(0xFF00796B)),
                    ),
                  ],
                ),
                const SizedBox(height: 70),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onBotonPulsado, 
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold
                        ),
                      backgroundColor: _trabajando ? Colors.red : Colors.blue,
                    ),
                    child:  Text(
                      _trabajando ? "FINALIZAR JORNADA" : "EMPEZAR JORNADA",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formateaDuracion(Duration duracion) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final horas = twoDigits(duracion.inHours);
    final minutos = twoDigits(duracion.inMinutes.remainder(60));
    final segundos = twoDigits(duracion.inSeconds.remainder(60));
    return "$horas:$minutos:$segundos";
  }
}
