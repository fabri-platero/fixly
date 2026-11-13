import 'package:firebase_auth/firebase_auth.dart';

class _AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuario => _auth.currentUser;

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
