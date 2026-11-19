import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixly/src/models/reporte_model.dart';
import 'package:fixly/src/provider/auth_provider.dart';

class _ReportesProvider {
  final CollectionReference<Map<String, dynamic>> _coleccion =
      FirebaseFirestore.instance.collection('reportes');

  final Duration _espera = const Duration(seconds: 10);

  final String mensajeSinConexion =
      'Sin conexión. Revisá tu internet e intentá de nuevo.';

  final String mensajePendiente =
      'La conexión es inestable. El cambio quedó guardado en el teléfono y se enviará al recuperar internet.';

  Future<bool> _hayConexion() async {
    try {
      await _coleccion
          .where('uid', isEqualTo: authProvider.usuario!.uid)
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Reporte>> cargarDatos() async {
    final uid = authProvider.usuario!.uid;
    final snapshot = await _coleccion.where('uid', isEqualTo: uid).get();
    final reportes = snapshot.docs
        .map((doc) => Reporte.fromMap(doc.id, doc.data()))
        .toList();
    reportes.sort(
      (a, b) =>
          (b.fecha ?? DateTime.now()).compareTo(a.fecha ?? DateTime.now()),
    );
    return reportes;
  }

  Future<String?> agregar(Reporte reporte) async {
    if (!await _hayConexion()) return mensajeSinConexion;
    try {
      await _coleccion.add(reporte.toMap()).timeout(_espera);
      return null;
    } on TimeoutException {
      return mensajePendiente;
    } on FirebaseException catch (e) {
      return _mensajeError(e.code);
    }
  }

  Future<String?> actualizar(Reporte reporte) async {
    if (!await _hayConexion()) return mensajeSinConexion;
    try {
      await _coleccion
          .doc(reporte.id)
          .update({
            'titulo': reporte.titulo,
            'descripcion': reporte.descripcion,
            'direccion': reporte.direccion,
          })
          .timeout(_espera);
      return null;
    } on TimeoutException {
      return mensajePendiente;
    } on FirebaseException catch (e) {
      return _mensajeError(e.code);
    }
  }

  Future<String?> eliminar(String id) async {
    if (!await _hayConexion()) return mensajeSinConexion;
    try {
      await _coleccion.doc(id).delete().timeout(_espera);
      return null;
    } on TimeoutException {
      return mensajePendiente;
    } on FirebaseException catch (e) {
      return _mensajeError(e.code);
    }
  }

  String _mensajeError(String codigo) {
    switch (codigo) {
      case 'permission-denied':
        return 'No tenés permiso para realizar esta acción.';
      case 'unavailable':
        return 'Sin conexión. Revisá tu internet.';
      default:
        return 'No se pudo completar la operación.';
    }
  }
}

final reportesProvider = _ReportesProvider();
