import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:riber_republic_fichaje_app/model/fichaje.dart';
import 'package:riber_republic_fichaje_app/model/horarioHoy.dart';
import 'package:riber_republic_fichaje_app/providers/usuario_provider.dart';
import 'package:riber_republic_fichaje_app/screens/user/perfil_screen.dart';
import 'package:riber_republic_fichaje_app/screens/user/fichajes_screen.dart';
import 'package:riber_republic_fichaje_app/service/fichaje_service.dart';
import 'package:riber_republic_fichaje_app/service/usuario_service.dart';
import 'package:riber_republic_fichaje_app/utils/fichajeUtils.dart';
import 'package:riber_republic_fichaje_app/utils/geolocalizacion.dart';
import 'package:riber_republic_fichaje_app/widgets/snackbar.dart';
import 'package:riber_republic_fichaje_app/widgets/user/fichaje_nfc.dart';

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
  /// Calcula el color por el id recibio
  Color _avatarColor(int id) =>
      Colors.primaries[id % Colors.primaries.length];

  /// Appbar para las pantallas, si es la 2 va sin icono
  PreferredSizeWidget? _buildAppBar() {
    final scheme = Theme.of(context).colorScheme;

    if (_currentIndex == 2) return null;
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuario;
    final iniciales = usuario != null
      ? '${usuario.nombre[0]}${usuario.apellido1[0]}'.toUpperCase()
      : '';
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, 
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = 2;
              });
            },
            child: CircleAvatar(
              backgroundColor: _avatarColor(usuario!.id),
              child: Text(
                iniciales,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
  /// Recibe del service los datos de horarios y fichajes
  Future<void> _cargaInicial() async {
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuario!;
    final horario = await UsuarioService.getHorarioDeHoy(usuario.id);
    final fichajes = await FichajeService.getFichajesPorUsuario(usuario.id);

    // filtra los fichajes para quedarme con los fichajes de hoy
    _fichajesDeHoy = FichajeUtils.filtradosDeHoy(fichajes);

    // obtengo el primer fichaje de hoy que no tenga hora de salida
    _fichajeEnCurso = _fichajesDeHoy.firstWhereOrNull((f) => f.fechaHoraSalida == null);
    // si hay un fichaje en curso sera true (para el boton rojo o azul)
    _trabajando   = _fichajeEnCurso != null;
    _horarioHoy   = horario;

    // calcula el tiempo trabajado contando solo los fichajes con hora de salida
    _acumulado = FichajeUtils.calcularFichajesHoy(_fichajesDeHoy);
  
    // si ya había una sesión abierta, inicia el timer
    if (_trabajando) {
      _inicioActual = _fichajeEnCurso!.fechaHoraEntrada;
      _iniciarTimer();
    }
  }

  /// inicia el timer
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

  /// cuando no se este visualizando la pantalla, para el timer
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<Position> _obtenerPosicion() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// ModalBottom para selecionar si quieres fichar con o sin nfc
  void _mostrarOpcionesFichaje(ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Cómo quieres fichar?' ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.nfc, color: scheme.primary),
                title: const Text('Con NFC'),
                onTap: ()async {
                  Navigator.pop(context);
                  
                  Position posicion;
                  try{
                    posicion = await _obtenerPosicion();
                  }catch (e){
                    AppSnackBar.show(
                      context,
                      message: 'Error al obtener la ubicación',
                      backgroundColor: Colors.red.shade600,
                      icon: Icons.error_outline,
                    );
                    return;
                  }

                  final distancia = calcularDistancia(GeofenceConfiguracion.latitude, GeofenceConfiguracion.longitud, posicion.latitude, posicion.longitude);
                  if (distancia > GeofenceConfiguracion.radioMetros) {
                    AppSnackBar.show(
                      context,
                      message: 'Solo puedes fichar en el instituto',
                      backgroundColor: Colors.red.shade600,
                      icon: Icons.error_outline,
                    );
                    return;
                  }
                  // Navega a pantalla NFC y decide abrir/cerrar allí:
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FichajeNfcScreen(
                      trabajando: _trabajando,
                      onCompletar: (cerrado) => _onFichajeCompletado(cerrado, true),
                    ),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.dangerous_outlined, color: scheme.primary),
                title: const Text('Sin NFC'),
                onTap: () async {
                  Navigator.pop(context);

                  Position posicion;
                  try{
                    posicion = await _obtenerPosicion();
                  }catch (e){
                    AppSnackBar.show(
                      context,
                      message: 'Error al obtener la ubicación',
                      backgroundColor: Colors.red.shade600,
                      icon: Icons.error_outline,
                    );
                    return;
                  }

                  final distancia = calcularDistancia(GeofenceConfiguracion.latitude, GeofenceConfiguracion.longitud, posicion.latitude, posicion.longitude);
                  if (distancia > GeofenceConfiguracion.radioMetros) {
                    AppSnackBar.show(
                      context,
                      message: 'Solo puedes fichar en el instituto',
                      backgroundColor: Colors.red.shade600,
                      icon: Icons.error_outline,
                    );
                    return;
                  }
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      titlePadding: EdgeInsets.zero,
                      title: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.exit_to_app, color: scheme.onPrimary),
                              const SizedBox(width: 8),
                              Text(
                                'Fichar sin NFC',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      content: const Text('Se generara una ausencia al fichar sin NFC', textAlign: TextAlign.center),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  minimumSize: const Size.fromHeight(40),
                                ),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  backgroundColor: scheme.error,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  minimumSize: const Size.fromHeight(40),
                                ),
                                child: Text(
                                  'Confirmar',
                                  style: TextStyle(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                  if (confirmar == true) {
                    _onFichajeCompletado(_trabajando, false);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuario!;

    super.build(context);
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (ctx, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 72, color: scheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes un horario definido para hoy.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: scheme.error),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _initFuture = _cargaInicial();
                      });
                    },
                    icon:  Icon(Icons.refresh, color: scheme.onPrimary),
                    label: Text('Recargar', style: TextStyle(color: scheme.onPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (_horarioHoy == null) {
          return const Center(child: Text("Error cargando horario"));
        }
        final ahora = DateTime.now();
        // suma todas las sesiones cerradas de hoy, si estoy en jornada calcula la diferencia que llevo en jornada
        final total = _acumulado +
          (_trabajando && _inicioActual != null
            ? ahora.difference(_inicioActual!)
            : Duration.zero);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 110,
                  backgroundColor: scheme.surface,
                  backgroundImage: const AssetImage('assets/images/logo.png'),
                ),
                const SizedBox(height: 5),
                Text("¡Hola ${usuario.nombre} ${usuario.apellido1} ${usuario.apellido2??""}!",
                  style: TextStyle(color: scheme.primary, fontSize: 30), textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
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
                              .copyWith(color: scheme.error)
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
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:() async{
                      final status = await Permission.location.request();
                      if (status.isGranted) {
                        _mostrarOpcionesFichaje(scheme);
                      }
                      else if (status.isPermanentlyDenied) {
                        AppSnackBar.show(
                          context,
                          message: 'Activa la ubicación en los ajustes',
                          backgroundColor: Colors.red.shade600,
                          icon: Icons.error_outline,
                        );
                        await openAppSettings();
                      }
                      else {
                        AppSnackBar.show(
                          context,
                          message: 'Para fichar es necesaria la ubicación en el dispositivo',
                          backgroundColor: Colors.red.shade600,
                          icon: Icons.error_outline,
                        );
                      }
                    },
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

  // formatea un duration al formato (HH:MM:SS) con dos digitos
  String _formateaDuracion(Duration duracion) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(duracion.inHours)}:"
           "${two(duracion.inMinutes.remainder(60))}:"
           "${two(duracion.inSeconds.remainder(60))}";
  }

  /// Crea el fichaje
  Future<void> _onFichajeCompletado(bool fichajeAbierto, bool nfcUsado) async {
    final usuario = Provider.of<AuthProvider>(context, listen: false).usuario!;
    if (!fichajeAbierto) {
      final fichaje = await FichajeService.abrirFichaje(
        usuario.id,
        nfcUsado: nfcUsado,
        ubicacion: 'Oficina Principal',
      );
      setState(() {
        _fichajeEnCurso = fichaje;
        _trabajando = true;
        _inicioActual = fichaje.fechaHoraEntrada;
      });
      _iniciarTimer();
    } else {
      _timer?.cancel();
      final fichajeCerrado = await FichajeService.cerrarFichaje(
        idUsuario: usuario.id,
        nfcUsado: nfcUsado,
      );
      setState(() {
        _trabajando = false;
        if (_inicioActual != null && fichajeCerrado.fechaHoraSalida != null) {
          _acumulado += fichajeCerrado
            .fechaHoraSalida!
            .difference(_inicioActual!);
        }
        _fichajeEnCurso = null;
        _inicioActual   = null;
      });
    }
  }
}