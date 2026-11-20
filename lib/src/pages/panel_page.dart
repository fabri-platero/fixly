import 'package:fixly/src/models/reporte_model.dart';
import 'package:fixly/src/provider/auth_provider.dart';
import 'package:fixly/src/provider/reportes_provider.dart';
import 'package:fixly/src/utils/reporte_util.dart';
import 'package:flutter/material.dart';

class PanelPage extends StatefulWidget {
  const PanelPage({super.key});

  @override
  State<PanelPage> createState() => _PanelPageState();
}

class _PanelPageState extends State<PanelPage> {
  late Future<List<Reporte>> _reportes;

  @override
  void initState() {
    super.initState();
    _reportes = reportesProvider.cargarTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de operador'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _recargar,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _salir,
          ),
        ],
      ),
      body: _crearLista(),
    );
  }

  void _recargar() {
    setState(() {
      _reportes = reportesProvider.cargarTodos();
    });
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
          return const Center(child: Text('No hay reportes'));
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
          child: Icon(iconoCategoria(reporte.categoria), color: Colors.blue),
        ),
        title: Text(reporte.titulo),
        subtitle: Text(
          '${reporte.direccion}\n${formatearFecha(reporte.fecha)}',
        ),
        isThreeLine: true,
        trailing: _crearSelectorEstado(reporte),
        onTap: () {
          Navigator.pushNamed(
            context,
            'detalle',
            arguments: reporte,
          ).then((_) => _recargar());
        },
      ),
    );
  }

  Widget _crearSelectorEstado(Reporte reporte) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colorEstado(reporte.estado),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DropdownButton<String>(
        value: estados.contains(reporte.estado) ? reporte.estado : null,
        underline: const SizedBox(),
        items: estados.map((estado) {
          return DropdownMenuItem(value: estado, child: Text(estado));
        }).toList(),
        onChanged: (valor) {
          if (valor != null && valor != reporte.estado) {
            _cambiarEstado(reporte, valor);
          }
        },
      ),
    );
  }

  Future<void> _cambiarEstado(Reporte reporte, String estado) async {
    final error = await reportesProvider.cambiarEstado(reporte.id, estado);
    if (!mounted) return;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${reporte.titulo}" ahora está $estado')),
      );
    } else if (error == reportesProvider.mensajePendiente) {
      await _mostrarAlerta('Conexión inestable', error);
    } else {
      await _mostrarAlerta('Error', error);
    }
    if (!mounted) return;
    _recargar();
  }

  Future<void> _mostrarAlerta(String titulo, String mensaje) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
