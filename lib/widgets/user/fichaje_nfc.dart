import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class FichajeNfcScreen extends StatefulWidget {
  final bool trabajando;
  final ValueChanged<bool> onCompletar;
  const FichajeNfcScreen({
    super.key,
    required this.trabajando,
    required this.onCompletar,
  });
  @override
  _FichajeNfcScreenState createState() => _FichajeNfcScreenState();
}

class _FichajeNfcScreenState extends State<FichajeNfcScreen> with SingleTickerProviderStateMixin {
  String _status = 'Acércate al NFC';
  bool _escaneando = false;
  bool _resultReady = false;
  bool _ok = false;
  late final AnimationController _animacionCtrl;

  /// Al iniciar la pantalla declara la animacion y llama a empezar
  @override
  void initState() {
    super.initState();
    _animacionCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _empezar();
  }

  /// Si se destruye la pantalla eliminar el animacionCtrl
  @override
  void dispose() {
    _animacionCtrl.dispose();
    super.dispose();
  }

  /// Incia la lectura de NFC, comprueba que sea NFC y que el texto sea FICHAJE
  void _empezar() async {
    if (_escaneando) return;
    _escaneando = true;
    // Si el nfc no esta activado salta un mensaje
    if (!await NfcManager.instance.isAvailable()) {
      setState(() => _status = 'NFC no disponible');
      return;
    }

    // Incia la antena NFC
    NfcManager.instance.startSession(onDiscovered: (tag) async {
      String resultado = 'Error inesperado';
      bool ok = false;

      try {
        final ndef = Ndef.from(tag);
        if (ndef == null) throw Exception('No es NDEF');
        await ndef.read();

        // Recorre los registros y extrae el texto del NFC
        for (var record in ndef.cachedMessage!.records) {
          if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
              record.type.length == 1 &&
              record.type[0] == 0x54) {
            final payload = record.payload;
            final statusByte = payload[0];
            final langLen = statusByte & 0x3F;
            final text = utf8.decode(payload.sublist(1 + langLen));

            if (text == 'FICHAJE') {
              ok = true;
              resultado = '¡Tarjeta válida!';
            } else {
              resultado = 'Tarjeta no válida: $text';
            }
            break;
          }
        }
      } catch (e) {
        resultado = 'Error lectura: $e';
      } finally {
        // Cierra el nfc
        await NfcManager.instance.stopSession();
        _escaneando = false;
      }

      // Animación de entrada
      setState(() {
        _status = resultado;
        _resultReady = true;
        _ok = ok;
      });

      await _animacionCtrl.forward();
      
      // Al terminar espera 1 segundo para desaparecer y si coincide llama a onCompletar
      await Future.delayed(const Duration(seconds: 1));
      if (ok) widget.onCompletar(widget.trabajando);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isResult = _resultReady && _animacionCtrl.status == AnimationStatus.completed;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white)
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/nfc_background.png', fit: BoxFit.cover),
          Container(color: Colors.black54),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_resultReady)
                  SizedBox(
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    child: const CircularProgressIndicator(
                      strokeWidth: 8,
                      color: Colors.white70,
                    ),
                  )
                else
                  Image.asset(
                    _ok
                      ? 'assets/images/check.png'
                      : 'assets/images/cross.png',
                    width: size.width * 0.3,
                  ),

                const SizedBox(height: 24),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _resultReady ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isResult) ...[
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
