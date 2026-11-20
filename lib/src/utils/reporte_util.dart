import 'package:flutter/material.dart';

const List<String> estados = ['pendiente', 'en proceso', 'resuelto'];

IconData iconoCategoria(String categoria) {
  switch (categoria) {
    case 'bache':
      return Icons.warning_amber;
    case 'luminaria':
      return Icons.lightbulb_outline;
    case 'basura':
      return Icons.delete_outline;
    default:
      return Icons.report_problem;
  }
}

Color colorEstado(String estado) {
  switch (estado) {
    case 'pendiente':
      return Colors.orange.shade100;
    case 'en proceso':
      return Colors.blue.shade100;
    case 'resuelto':
      return Colors.green.shade100;
    default:
      return Colors.grey.shade200;
  }
}

String capitalizar(String texto) {
  if (texto.isEmpty) return texto;
  return texto[0].toUpperCase() + texto.substring(1);
}

String formatearFecha(DateTime? fecha) {
  if (fecha == null) return 'Sin fecha';
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year} $hora:$minuto';
}
