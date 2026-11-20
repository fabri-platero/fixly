import 'dart:convert';
import 'dart:typed_data';

import 'package:fixly/src/models/reporte_model.dart';
import 'package:fixly/src/provider/auth_provider.dart';
import 'package:fixly/src/provider/reportes_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NuevoReportePage extends StatefulWidget {
  const NuevoReportePage({super.key});

  @override
  State<NuevoReportePage> createState() => _NuevoReportePageState();
}

class _NuevoReportePageState extends State<NuevoReportePage> {
  final List<String> _categorias = [
    'Bache',
    'Luminaria',
    'Basura',
    'Semáforo',
    'Árbol caído',
    'Pérdida de agua',
    'Vereda rota',
    'Señalización',
    'Otro',
  ];

  String _categoria = 'Bache';
  String _titulo = '';
  String _descripcion = '';
  String _direccion = '';
  Uint8List? _imagen;

  Reporte? _editando;
  bool _iniciado = false;
  bool _guardando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    final argumento = ModalRoute.of(context)!.settings.arguments;
    if (argumento is Reporte) {
      _editando = argumento;
      _categoria = _categorias.firstWhere(
        (categoria) => categoria.toLowerCase() == argumento.categoria,
        orElse: () => _categorias.first,
      );
      _titulo = argumento.titulo;
      _descripcion = argumento.descripcion;
      _direccion = argumento.direccion;
      if (argumento.foto.isNotEmpty) {
        _imagen = base64Decode(argumento.foto);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando == null ? 'Nuevo reporte' : 'Editar reporte'),
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
            onChanged: _editando == null
                ? (valor) {
                    setState(() {
                      _categoria = valor!;
                    });
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _crearTitulo() {
    return TextFormField(
      initialValue: _titulo,
      maxLength: 100,
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
    return TextFormField(
      initialValue: _descripcion,
      maxLines: 4,
      maxLength: 500,
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
    return TextFormField(
      initialValue: _direccion,
      maxLength: 150,
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
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: _imagen == null
              ? const Center(
                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                )
              : Image.memory(_imagen!, fit: BoxFit.cover),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
            ),
            OutlinedButton.icon(
              onPressed: () => _cargarFoto(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
            ),
          ],
        ),
        if (_imagen != null)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _imagen = null;
              });
            },
            icon: const Icon(Icons.close),
            label: const Text('Quitar foto'),
          ),
      ],
    );
  }

  Future<void> _tomarFoto() async {
    final permiso = await Permission.camera.request();
    if (!mounted) return;
    if (permiso.isGranted) {
      await _cargarFoto(ImageSource.camera);
    } else if (permiso.isPermanentlyDenied) {
      _mostrarPermisoBloqueado();
    } else {
      _mostrarAlerta(
        'Permiso denegado',
        'Necesitamos la cámara para sacar una foto del problema.',
      );
    }
  }

  Future<void> _cargarFoto(ImageSource origen) async {
    final archivo = await ImagePicker().pickImage(
      source: origen,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 50,
    );
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    if (!mounted) return;
    if (bytes.length > 500000) {
      _mostrarAlerta('Foto muy pesada', 'Elegí otra foto más liviana.');
      return;
    }
    setState(() {
      _imagen = bytes;
    });
  }

  void _mostrarPermisoBloqueado() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permiso bloqueado'),
          content: const Text(
            'Bloqueaste el permiso de cámara. Para usarla, activalo desde los ajustes de la app.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Abrir ajustes'),
            ),
          ],
        );
      },
    );
  }

  Widget _crearBotonEnviar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardando ? null : _enviar,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_editando == null ? 'Enviar reporte' : 'Guardar cambios'),
        ),
      ),
    );
  }

  Future<void> _enviar() async {
    if (_titulo.trim().isEmpty || _direccion.trim().isEmpty) {
      _mostrarAlerta('Faltan datos', 'Completá el título y la dirección.');
      return;
    }
    setState(() {
      _guardando = true;
    });
    if (_editando != null) {
      await _guardarCambios(_editando!);
      return;
    }
    final reporte = Reporte(
      categoria: _categoria.toLowerCase(),
      titulo: _titulo.trim(),
      descripcion: _descripcion.trim(),
      direccion: _direccion.trim(),
      uid: authProvider.usuario!.uid,
      email: authProvider.usuario!.email ?? '',
      foto: _imagen == null ? '' : base64Encode(_imagen!),
    );
    final error = await reportesProvider.agregar(reporte);
    await _terminar(error);
  }

  Future<void> _terminar(String? error, [Reporte? resultado]) async {
    if (!mounted) return;
    setState(() {
      _guardando = false;
    });
    if (error == reportesProvider.mensajePendiente) {
      await _mostrarAlerta('Conexión inestable', error!);
      if (!mounted) return;
      Navigator.pop(context, resultado);
      return;
    }
    if (error != null) {
      _mostrarAlerta('Error', error);
      return;
    }
    Navigator.pop(context, resultado);
  }

  Future<void> _guardarCambios(Reporte original) async {
    final actualizado = Reporte(
      id: original.id,
      categoria: original.categoria,
      titulo: _titulo.trim(),
      descripcion: _descripcion.trim(),
      direccion: _direccion.trim(),
      estado: original.estado,
      uid: original.uid,
      email: original.email,
      foto: _imagen == null ? '' : base64Encode(_imagen!),
      fecha: original.fecha,
    );
    final error = await reportesProvider.actualizar(actualizado);
    await _terminar(error, actualizado);
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
