import 'dart:convert';

import 'package:fixly/src/models/reporte_model.dart';
import 'package:fixly/src/provider/reportes_provider.dart';
import 'package:fixly/src/utils/reporte_util.dart';
import 'package:flutter/material.dart';

class DetalleReportePage extends StatefulWidget {
  const DetalleReportePage({super.key});

  @override
  State<DetalleReportePage> createState() => _DetalleReportePageState();
}

class _DetalleReportePageState extends State<DetalleReportePage> {
  Reporte? _reporte;

  @override
  Widget build(BuildContext context) {
    _reporte ??= ModalRoute.of(context)!.settings.arguments as Reporte;
    final reporte = _reporte!;
    final editable = reporte.estado == 'pendiente';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del reporte'),
        centerTitle: true,
        actions: editable
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar',
                  onPressed: _editar,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Eliminar',
                  onPressed: _confirmarEliminar,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _crearEncabezado(reporte),
                const SizedBox(height: 20),
                if (reporte.foto.isNotEmpty) _crearFoto(reporte.foto),
                _crearDato(
                  Icons.description,
                  'Descripción',
                  reporte.descripcion.isEmpty
                      ? 'Sin descripción'
                      : reporte.descripcion,
                ),
                _crearDato(Icons.location_on, 'Dirección', reporte.direccion),
                _crearDato(
                  Icons.calendar_today,
                  'Fecha',
                  formatearFecha(reporte.fecha),
                ),
                if (!editable) _crearAviso(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearEncabezado(Reporte reporte) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.shade50,
          child: Icon(iconoCategoria(reporte.categoria), color: Colors.blue),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reporte.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(capitalizar(reporte.categoria)),
            ],
          ),
        ),
        Chip(
          label: Text(reporte.estado),
          backgroundColor: colorEstado(reporte.estado),
        ),
      ],
    );
  }

  Widget _crearFoto(String foto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.memory(
          base64Decode(foto),
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _crearDato(IconData icono, String etiqueta, String valor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icono),
      title: Text(etiqueta),
      subtitle: Text(valor),
    );
  }

  Widget _crearAviso() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        'Este reporte ya está siendo atendido y no se puede modificar.',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Future<void> _editar() async {
    final actualizado = await Navigator.pushNamed(
      context,
      'nuevo',
      arguments: _reporte,
    );
    if (actualizado is Reporte) {
      setState(() {
        _reporte = actualizado;
      });
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar reporte'),
          content: const Text('¿Seguro que querés eliminar este reporte?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _eliminar();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminar() async {
    final error = await reportesProvider.eliminar(_reporte!.id);
    if (!mounted) return;
    if (error == reportesProvider.mensajePendiente) {
      await _mostrarAlerta('Conexión inestable', error!);
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    if (error != null) {
      _mostrarAlerta('Error', error);
      return;
    }
    Navigator.pop(context);
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
