import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riber_republic_fichaje_app/model/ausencia.dart';
import 'package:riber_republic_fichaje_app/model/grupo.dart';
import 'package:riber_republic_fichaje_app/model/usuario.dart';

class ExcelExporter {

  /// Exporta todos los alumnos en una misma hoja de excel con:
  /// ('Nombre', 'Apellidos', 'Email', 'Nº Ausencias', 'Grupo')
  static Future<void> exportarTodosGruposAExcel({
    required BuildContext context,
    required List<Grupo> grupos,
    required List<Usuario> usuarios,
    required List<Ausencia> ausencias,
  }) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final nombreFichero = 'Todos_los_Grupos_$fecha.xlsx';
      final path = await getSavePath(
        acceptedTypeGroups: [
          const XTypeGroup(label: 'Excel', extensions: ['xlsx'])
        ],
        suggestedName: nombreFichero,
      );

      if (path == null) return;

      // Crea un mapa con el id del grupo y su nombre
      final grupoNombres = { for (var grupo in grupos) grupo.id!: grupo.nombre };

      // Coge los gruposIds menos "Sin Asignar"
      final gruposIdsValidos = grupos
        .where((g) => g.nombre != 'Sin Asignar')
        .map((g) => g.id)
        .toSet();
        
      // Coge los usuarios que pertenezcan a los grupos validados
      final usuariosFiltrados = usuarios
        .where((u) => gruposIdsValidos.contains(u.grupoId))
        .toList();

      if (usuariosFiltrados.isEmpty) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('No hay usuarios para exportar')),
        );
        return;
      }

      // Ordena por grupo, nombre y apellido
      usuariosFiltrados.sort((a, b) {
        final ga = grupoNombres[a.grupoId]!;
        final gb = grupoNombres[b.grupoId]!;
        // compara los grupos teniendo en cuenta el case insensitive
        final cmpG = ga.toLowerCase().compareTo(gb.toLowerCase());
        if (cmpG != 0) return cmpG;
        // compara los usuarios primero por nombre teniendo en cuenta el case insensitive
        final nombreA = a.nombre.toLowerCase();
        final nombreB = b.nombre.toLowerCase();
        final cmpN = nombreA.compareTo(nombreB);
        if (cmpN != 0) return cmpN;

        // y sino los compara por apellido1 con case insensitive
        return a.apellido1.toLowerCase()
                .compareTo(b.apellido1.toLowerCase());
      });

      // Obtengo la hoja
      final excel = Excel.createExcel();
      final nombreHoja = excel.getDefaultSheet()!;
      final hoja = excel[nombreHoja];

      // Estilo para la cabecera y el cuerpo
      final estiloCabecera = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontColorHex: "#FFFFFF",
        backgroundColorHex: "#4472C4",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      final estiloCuerpo = CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        backgroundColorHex: "#DDEBF7",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      // Pinta las primeras celdas para la cabecera con el estilo y auto ajustandose
      final cabecera = ['Nº', 'Nombre', 'Apellidos', 'Email', 'Nº Ausencias', 'Grupo'];
      for (var col = 0; col < cabecera.length; col++) {
        final celda = hoja.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        celda.value = cabecera[col];
        celda.cellStyle = estiloCabecera;
        hoja.setColAutoFit(col);
      }

      // Recorre los usuarios y va rellenando las celdas se pinta la sigueinte fila 
      // por el indice del for 
      for (var i = 0; i < usuariosFiltrados.length; i++) {
        final usuario = usuariosFiltrados[i];
        final grupoNombre = grupoNombres[usuario.grupoId]!;
        final ausenciasNoAceptadas = ausencias
          .where((a) => a.usuario.id == usuario.id && a.estado != EstadoAusencia.aceptada)
          .length;

        final fila = [
          i + 1,
          usuario.nombre,
          (usuario.apellido2 != null && usuario.apellido2!.isNotEmpty)
            ? '${usuario.apellido1} ${usuario.apellido2}'
            : usuario.apellido1,
          usuario.email,
          ausenciasNoAceptadas,
          grupoNombre,
        ];
        // esto es lo que pinta los valores en si(el nombre, apellido...)
        for (var col = 0; col < fila.length; col++) {
          final celda = hoja.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1),
          );
          celda.value = fila[col];
          celda.cellStyle = estiloCuerpo;
        }
      }

      // Convierte todo lo que hemos pintado en un array de bytes
      final bytes = excel.encode();
      if (bytes == null) throw Exception('Error codificando Excel');
      // Crea el fichero y escribe los bytes
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);

      scaffold.showSnackBar(
        SnackBar(content: Text('✅ Excel guardado en: $path')),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Error al generar Excel de todos los grupos: $e')),
      );
    }
  }
  /// Exporta el grupo seleccionado a excel:
  /// ('Nombre', 'Apellidos', 'Email', 'Nº Ausencias')
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
      final nombreHoja = excel.getDefaultSheet()!;
      final hoja = excel[nombreHoja];

      // Defino los estilos del cuerpo y cabecera
      final estiloCabecera = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontColorHex: "#FFFFFF",
        backgroundColorHex: "#4472C4",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      final estiloCuerpo = CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        backgroundColorHex: "#DDEBF7",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final cabecera = ['Nº', 'Nombre', 'Apellidos', 'Email', 'Nº Ausencias'];
      for (var col = 0; col < cabecera.length; col++) {
        hoja.setColAutoFit(col);
        final cell = hoja.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = cabecera[col];
        cell.cellStyle = estiloCabecera;
      }

      // Recorre los usuarios y va rellenando las celdas se pinta la siguiente fila 
      // por el indice del for 
      for (var i = 0; i < usuarios.length; i++) {
        final usuario = usuarios[i];
        final ausenciasNoAceptadas = ausencias
            .where((a) => a.usuario.id == usuario.id && a.estado != EstadoAusencia.aceptada)
            .length;

        final fila = [
          i + 1,
          usuario.nombre,
          usuario.apellido2 != null && usuario.apellido2!.isNotEmpty
              ? '${usuario.apellido1} ${usuario.apellido2}'
              : usuario.apellido1,
          usuario.email,
          ausenciasNoAceptadas,
        ];
        // esto es lo que pinta los valores en si(el nombre, apellido...)
        for (var col = 0; col < fila.length; col++) {
          final celda = hoja.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1),
          );
          celda.value = fila[col];
          celda.cellStyle = estiloCuerpo;
        }
      }
      // Convierte el excel a bytes
      final bytes = excel.encode();
      if (bytes == null){
        throw Exception('Error al codificar el Excel');
      }
      // Crea el archivo y escribe los bytes
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);

      scaffold.showSnackBar(
        SnackBar(content: Text('✅ Excel guardado en: $path')),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Error al generar Excel: $e')),
      );
    }
  }
}

