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
  bool _scanning = false;
  bool _resultReady = false;
  bool _ok = false;
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _startSession();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _startSession() async {
    if (_scanning) return;
    _scanning = true;
    if (!await NfcManager.instance.isAvailable()) {
      setState(() => _status = 'NFC no disponible');
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (tag) async {
      String result = 'Error inesperado';
      bool ok = false;

      try {
        final ndef = Ndef.from(tag);
        if (ndef == null) throw Exception('No es NDEF');
        await ndef.read();

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
              result = '¡Tarjeta válida!';
            } else {
              result = 'Tarjeta no válida: $text';
            }
            break;
          }
        }
      } catch (e) {
        result = 'Error lectura: $e';
      } finally {
        await NfcManager.instance.stopSession();
        _scanning = false;
      }

      // Animación de entrada
      setState(() {
        _status = result;
        _resultReady = true;
        _ok = ok;
      });

      await Future.delayed(const Duration(seconds: 1));
      if (ok) widget.onCompletar(widget.trabajando);
      // Cierra la pantalla tras mostrar el resultado
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isResult = _status != 'Acércate al NFC' && _animCtrl.status == AnimationStatus.completed;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo
          Image.asset('assets/images/nfc_background.png', fit: BoxFit.cover),

          // Capa semitransparente
          Container(color: Colors.black54),

          // Contenido
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // indicador o imagen de resultado
                if (!_resultReady)
                  SizedBox(
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    child: CircularProgressIndicator(
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

                // texto de estado
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _resultReady ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
