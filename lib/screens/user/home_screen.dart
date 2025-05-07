import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/screens/user/perfil_screen.dart';
import 'package:riber_republic_fichaje_app/screens/user/fichajes_screen.dart';
import 'package:riber_republic_fichaje_app/service/fichaje_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/utils/fichajeUtils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // esto lo utilizo para que cuando navegue a fichajes sepa que tiene que actualizar los fichajes
  final _fichajesKey = GlobalKey<FichajesScreenState>();

  // conjunto de pantallas para navegar. En la de fichajes le añado la key de arriba
  late final List<Widget> _screens = [
    const HomeContent(),
    FichajesScreen(key: _fichajesKey),
    const PerfilScreen(),
  ];

  // se actualiza la pantalla seleccionada y si es la de fichajes se recargan los fichajes
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 1) {
      _fichajesKey.currentState?.recargarFichajes();
    }
  }
  /// appbar para las pantallas, si es la 2 va sin icono
  PreferredSizeWidget? _buildAppBar() {
    if (_currentIndex == 2) return null;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      automaticallyImplyLeading: false, 
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      // IndexStack, lo utilizo para que cuando esta pantalla este en segundo plano, siga en memoria (lo necesito para el timer)
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      appBar: _buildAppBar(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: scheme.primary,
        selectedItemColor: scheme.onPrimary,
        unselectedItemColor: scheme.onPrimary.withOpacity(0.7),
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

class _HomeContentState extends State<HomeContent>  with AutomaticKeepAliveClientMixin<HomeContent>{

  // es necesario por el AutomaticKeepAliveClientMixin para que el dispose, no elimine el state aunque no este visible
  @override
  bool get wantKeepAlive => true;

  // sirve para ejecutar solo una vez el cargaInicial.
  late Future<void> _initFuture;

  bool _trabajando = false;
  Fichaje? _fichajeEnCurso;
  DateTime? _inicioActual;
  Timer? _timer;
  List<Fichaje> _fichajesDeHoy = [];
  HorarioHoy? _horarioHoy;
  Duration _acumulado = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initFuture = _cargaInicial();
  }

  Future<void> _cargaInicial() async {
    // usuario de la sesión actual
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario!;
    // horario de hoy para el usuario
    final horario = await UsuarioService.getHorarioDeHoy(usuario.id);
    // fichajes realizados por el usuario
    final fichajes = await FichajeService.getFichajesPorUsuario(usuario.id);

    // filtra los fichajes para quedarme con los fichajes de hoy
    _fichajesDeHoy = FichajeUtils.filtradosDeHoy(fichajes);

    // obtengo el primer fichaje de hoy que no tenga hora de salida
    _fichajeEnCurso = _fichajesDeHoy.firstWhereOrNull((f) => f.fechaHoraSalida == null);
    // si hay un fichaje en curso sera true (para el boton rojo o azul)
    _trabajando   = _fichajeEnCurso != null;
    // guardo el horario en otra variable privada
    _horarioHoy   = horario;

    // calcula el tiempo trabajado contando solo los fichajes con hora de salida
    _acumulado = FichajeUtils.calcularFichajesHoy(_fichajesDeHoy);
  
    // si ya había una sesión abierta, inicia el timer
    if (_trabajando) {
      _inicioActual = _fichajeEnCurso!.fechaHoraEntrada;
      _iniciarTimer();
    }
  }

  // inicia el timer
  void _iniciarTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }
    setState(() {
    });
  });
}

  // cuando no se este visualizando la pantalla, para el timer
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onBotonPulsado() async {
    // obtengo el usuario que ha iniciado sesi
    final usuario = Provider.of<UsuarioProvider>(context, listen: false).usuario!;

    if (!_trabajando) {
      // Abre el fichaje de hoy
      final fichaje = await FichajeService.abrirFichaje(usuario.id, nfcUsado: true, ubicacion: "Oficina Principal");
      setState(() {
        _fichajeEnCurso = fichaje;
        _trabajando = true;
        _inicioActual = fichaje.fechaHoraEntrada;
      });
      _iniciarTimer();
    } else {
      _timer?.cancel();
      // Cierra el fichaje de hoy
      final fichajeCerrado = await FichajeService.cerrarFichaje(usuario.id);
      setState(() {
        _trabajando   = false;
        // Suma al tiempo total lo de este fichaje
        if (_inicioActual != null && fichajeCerrado.fechaHoraSalida != null) {
          _acumulado += fichajeCerrado.fechaHoraSalida!
              .difference(_inicioActual!);
        }
        _fichajeEnCurso = null;
        _inicioActual   = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    super.build(context);
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_horarioHoy == null) {
          return const Center(child: Text("Error cargando horario"));
        } 
        // obtengo el momento
        final ahora = DateTime.now();
        // suma todas las sesiones cerradas de hoy, si estoy en jornada calcula la diferencia que llevo en jornada
        final total = _acumulado +
          (_trabajando && _inicioActual != null
            ? ahora.difference(_inicioActual!)
            : Duration.zero);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: scheme.surface,
                  child: Icon(Icons.image, size: 60, color: scheme.onSurface),
                ),
                const SizedBox(height: 10),
                Text("¡Hola ${Provider.of<UsuarioProvider>(context, listen: false).usuario?.nombre ?? 'Usuario'}!",
                  style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: scheme.primary),
                ),
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text("Horas trabajadas", style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text(_formateaDuracion(total),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: scheme.error
                          )
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Horas estimadas", style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text(_formateaDuracion(_horarioHoy!.horasEstimadas),
                           style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: scheme.secondary
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: scheme.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: scheme.secondary
                      ),
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
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      backgroundColor: _trabajando ? scheme.error : scheme.primaryContainer
                    ),
                    child: Text(
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

  // formatea un duration al formato (HH:MM:SS) siempre con dos digitos
  String _formateaDuracion(Duration duracion) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(duracion.inHours)}:"
           "${two(duracion.inMinutes.remainder(60))}:"
           "${two(duracion.inSeconds.remainder(60))}";
  }
}