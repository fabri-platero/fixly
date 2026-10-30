import 'package:fixly/src/provider/reportes_provider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          Navigator.pushNamed(context, 'nuevo').then((_) {
            setState(() {});
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo reporte'),
      ),
    );
  }

  Widget _crearLista() {
    return FutureBuilder(
      future: reportesProvider.cargarDatos(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error al cargar los reportes'));
        }
        return ListView(
          padding: const EdgeInsets.all(10.0),
          children: snapshot.data!
              .map((reporte) => _crearTarjeta(reporte))
              .toList(),
        );
      },
    );
  }

  Widget _crearTarjeta(dynamic reporte) {
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
