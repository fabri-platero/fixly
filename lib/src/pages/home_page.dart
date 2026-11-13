import 'package:fixly/src/models/reporte_model.dart';
import 'package:fixly/src/provider/auth_provider.dart';
import 'package:fixly/src/provider/reportes_provider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Reporte>> _reportes;

  @override
  void initState() {
    super.initState();
    _reportes = reportesProvider.cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixly'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _salir,
          ),
        ],
      ),
      body: _crearLista(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, 'nuevo').then((_) {
            setState(() {
              _reportes = reportesProvider.cargarDatos();
            });
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo reporte'),
      ),
    );
  }

  Future<void> _salir() async {
    await authProvider.salir();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _crearLista() {
    return FutureBuilder(
      future: _reportes,
      builder: (BuildContext context, AsyncSnapshot<List<Reporte>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error al cargar los reportes'));
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('Todavía no hay reportes'));
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

  Widget _crearTarjeta(Reporte reporte) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(_iconoCategoria(reporte.categoria), color: Colors.blue),
        ),
        title: Text(reporte.titulo),
        subtitle: Text(reporte.direccion),
        trailing: _crearEstado(reporte.estado),
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
