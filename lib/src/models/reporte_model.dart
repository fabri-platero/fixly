import 'package:cloud_firestore/cloud_firestore.dart';

class Reporte {
  final String id;
  final String categoria;
  final String titulo;
  final String descripcion;
  final String direccion;
  final String estado;
  final String uid;
  final String email;
  final String foto;
  final double? latitud;
  final double? longitud;
  final DateTime? fecha;

  Reporte({
    this.id = '',
    required this.categoria,
    required this.titulo,
    this.descripcion = '',
    required this.direccion,
    this.estado = 'pendiente',
    required this.uid,
    this.email = '',
    this.foto = '',
    this.latitud,
    this.longitud,
    this.fecha,
  });

  factory Reporte.fromMap(String id, Map<String, dynamic> data) {
    final timestamp = data['fecha'] as Timestamp?;
    return Reporte(
      id: id,
      categoria: data['categoria'] ?? '',
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      direccion: data['direccion'] ?? '',
      estado: data['estado'] ?? 'pendiente',
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      foto: data['foto'] ?? '',
      latitud: (data['latitud'] as num?)?.toDouble(),
      longitud: (data['longitud'] as num?)?.toDouble(),
      fecha: timestamp?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'titulo': titulo,
      'descripcion': descripcion,
      'direccion': direccion,
      'estado': estado,
      'uid': uid,
      'email': email,
      'foto': foto,
      'latitud': latitud,
      'longitud': longitud,
      'fecha': FieldValue.serverTimestamp(),
    };
  }
}
