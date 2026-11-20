import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _rol = 'ciudadano';

  User? get usuario => _auth.currentUser;

  bool get esOperador => _rol == 'operador';

  String get rutaInicio => esOperador ? 'panel' : 'home';

  Future<void> cargarRol() async {
    try {
      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario!.uid)
          .get()
          .timeout(const Duration(seconds: 5));
      _rol = documento.data()?['rol'] ?? 'ciudadano';
    } catch (e) {
      _rol = 'ciudadano';
    }
  }

  Future<String?> ingresar(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeError(e.code);
    }
  }

  Future<String?> registrar(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeError(e.code);
    }
  }

  Future<void> salir() async {
    _rol = 'ciudadano';
    await _auth.signOut();
  }

  String _mensajeError(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El email no es válido.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sin conexión. Revisá tu internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Probá más tarde.';
      default:
        return 'No se pudo completar la operación.';
    }
  }
}

final authProvider = _AuthProvider();
