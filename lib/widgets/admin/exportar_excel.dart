import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';

class ExcelExporter {
  /// Genera y guarda en dispositivo un .xlsx con los datos de [grupo],
  /// sus [usuarios] y el número de ausencias no aceptadas.
  static Future<void> exportarGrupoAExcel({
    required BuildContext context,
    required Grupo grupo,
    required List<Usuario> usuarios,
    required List<Ausencia> ausencias,
  }) async {
    final scaffold = ScaffoldMessenger.of(context);

    try {
      final fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final nombreFichero = '${grupo.nombre}_$fecha.xlsx';
      final path = await getSavePath(
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Excel', extensions: ['xlsx'])
        ],
        suggestedName: nombreFichero,
      );

      if (path == null) {
        return;
      }

      final excel = Excel.createExcel();
      final sheetName = excel.getDefaultSheet()!;
      final sheet = excel[sheetName];

      // 1) Estilo de cabecera
      final headerStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontColorHex: "#FFFFFF",
        backgroundColorHex: "#4472C4",    // azul oscuro
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final dataStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        backgroundColorHex: "#DDEBF7",    // azul muy claro
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final headers = ['Nº', 'Nombre', 'Apellidos', 'Email', 'Nº Ausencias'];
      for (var col = 0; col < headers.length; col++) {
        sheet.setColAutoFit(col);
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = headers[col];
        cell.cellStyle = headerStyle;
      }

      // 2) Datos numerados
      for (var i = 0; i < usuarios.length; i++) {
        final u = usuarios[i];
        final noAceptadas = ausencias
            .where((a) => a.usuario.id == u.id && a.estado != EstadoAusencia.aceptada)
            .length;

        final row = [
          i + 1,
          u.nombre,
          u.apellido2 != null && u.apellido2!.isNotEmpty
              ? '${u.apellido1} ${u.apellido2}'
              : u.apellido1,
          u.email,
          noAceptadas,
        ];

        for (var col = 0; col < row.length; col++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1),
          );
          cell.value = row[col];
          cell.cellStyle = dataStyle;
        }
      }

      // 3) Encode y guardar (como ya hacías)
      final bytes = excel.encode();
      if (bytes == null){
        throw Exception('Error al codificar el Excel');
      }
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);

      scaffold.showSnackBar(
        SnackBar(content: Text('✅ Excel guardado en: $path')),
      );
    } catch (e) {
      print(e);
      scaffold.showSnackBar(
        SnackBar(content: Text('Error al generar Excel: $e')),
      );
    }
  }
}

