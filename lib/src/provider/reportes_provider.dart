import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class _ReportesProvider {
  List<dynamic> reportes = [];
  bool _cargado = false;

  Future<List<dynamic>> cargarDatos() async {
    if (!_cargado) {
      final resp = await rootBundle.loadString('data/reportes.json');
      Map dataMap = json.decode(resp);
      reportes = dataMap['reportes'];
      _cargado = true;
    }
    return reportes;
  }

  void agregar(Map<String, String> reporte) {
    reportes.insert(0, reporte);
  }
}

final reportesProvider = _ReportesProvider();
