import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixly/src/models/reporte_model.dart';
import 'package:fixly/src/provider/auth_provider.dart';

class _ReportesProvider {
  final CollectionReference<Map<String, dynamic>> _coleccion =
      FirebaseFirestore.instance.collection('reportes');

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
    try {
      await _coleccion.add(reporte.toMap());
      return null;
    } on FirebaseException catch (e) {
      return _mensajeError(e.code);
    }
  }

  String _mensajeError(String codigo) {
    switch (codigo) {
      case 'permission-denied':
        return 'No tenés permiso para guardar este reporte.';
      case 'unavailable':
        return 'Sin conexión. Revisá tu internet.';
      default:
        return 'No se pudo guardar el reporte.';
    }
  }
}

final reportesProvider = _ReportesProvider();
