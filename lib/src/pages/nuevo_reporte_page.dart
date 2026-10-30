import 'package:fixly/src/provider/reportes_provider.dart';
import 'package:flutter/material.dart';

class NuevoReportePage extends StatefulWidget {
  const NuevoReportePage({super.key});

  @override
  State<NuevoReportePage> createState() => _NuevoReportePageState();
}

class _NuevoReportePageState extends State<NuevoReportePage> {
  final List<String> _categorias = ['Bache', 'Luminaria', 'Basura'];

  String _categoria = 'Bache';
  String _titulo = '';
  String _descripcion = '';
  String _direccion = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo reporte'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  _crearCategoria(),
                  const SizedBox(height: 20),
                  _crearTitulo(),
                  const SizedBox(height: 20),
                  _crearDescripcion(),
                  const SizedBox(height: 20),
                  _crearDireccion(),
                  const SizedBox(height: 10),
                  _crearBotonUbicacion(),
                  const SizedBox(height: 20),
                  _crearFoto(),
                  const SizedBox(height: 30),
                  _crearBotonEnviar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearCategoria() {
    return Row(
      children: <Widget>[
        const Icon(Icons.category),
        const SizedBox(width: 20.0),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _categoria,
            items: _categorias.map((categoria) {
              return DropdownMenuItem(
                value: categoria,
                child: Text(categoria),
              );
            }).toList(),
            onChanged: (valor) {
              setState(() {
                _categoria = valor!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _crearTitulo() {
    return TextField(
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: 'Título',
        hintText: 'Ej: Bache profundo en la calzada',
        prefixIcon: const Icon(Icons.title),
      ),
      onChanged: (valor) {
        setState(() {
          _titulo = valor;
        });
      },
    );
  }

  Widget _crearDescripcion() {
    return TextField(
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: 'Descripción (opcional)',
        alignLabelWithHint: true,
      ),
      onChanged: (valor) {
        setState(() {
          _descripcion = valor;
        });
      },
    );
  }

  Widget _crearDireccion() {
    return TextField(
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: 'Dirección',
        hintText: 'Ej: Av. Libertador 1200',
        prefixIcon: const Icon(Icons.location_on),
      ),
      onChanged: (valor) {
        setState(() {
          _direccion = valor;
        });
      },
    );
  }

  Widget _crearBotonUbicacion() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.my_location),
        label: const Text('Usar mi ubicación actual'),
      ),
    );
  }

  Widget _crearFoto() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Center(
            child: Icon(Icons.image, size: 60, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _crearBotonEnviar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _enviar,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text('Enviar reporte'),
        ),
      ),
    );
  }

  void _enviar() {
    if (_titulo.isEmpty || _direccion.isEmpty) {
      _mostrarAlerta('Completá el título y la dirección.');
      return;
    }
    reportesProvider.agregar({
      'categoria': _categoria.toLowerCase(),
      'titulo': _titulo,
      'descripcion': _descripcion,
      'direccion': _direccion,
      'estado': 'pendiente',
    });
    Navigator.pop(context);
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Faltan datos'),
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
