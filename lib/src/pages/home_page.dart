import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, String>> _reportes = const [
    {
      'categoria': 'bache',
      'titulo': 'Bache profundo en la calzada',
      'direccion': 'Av. Libertador 1200',
      'estado': 'pendiente',
    },
    {
      'categoria': 'luminaria',
      'titulo': 'Farola apagada hace una semana',
      'direccion': 'Calle Mitre 450',
      'estado': 'en proceso',
    },
    {
      'categoria': 'basura',
      'titulo': 'Basura acumulada en la esquina',
      'direccion': 'Av. Rawson 800',
      'estado': 'resuelto',
    },
    {
      'categoria': 'bache',
      'titulo': 'Pozo frente a la escuela',
      'direccion': 'Calle Sarmiento 95',
      'estado': 'pendiente',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixly'),
        centerTitle: true,
      ),
      body: _crearLista(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, 'nuevo');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo reporte'),
      ),
    );
  }

  Widget _crearLista() {
    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: _reportes.map((reporte) => _crearTarjeta(reporte)).toList(),
    );
  }

  Widget _crearTarjeta(Map<String, String> reporte) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(_iconoCategoria(reporte['categoria']!), color: Colors.blue),
        ),
        title: Text(reporte['titulo']!),
        subtitle: Text(reporte['direccion']!),
        trailing: _crearEstado(reporte['estado']!),
        onTap: () {},
      ),
    );
  }

  Widget _crearEstado(String estado) {
    return Chip(
      label: Text(estado),
      backgroundColor: _colorEstado(estado),
    );
  }

  IconData _iconoCategoria(String categoria) {
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

  Color _colorEstado(String estado) {
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
}
