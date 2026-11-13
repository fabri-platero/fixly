import 'package:fixly/src/provider/auth_provider.dart';
import 'package:flutter/material.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  String _email = '';
  String _password = '';
  String _confirmar = '';
  bool _ocultarPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _crearEmail(),
                  const SizedBox(height: 20),
                  _crearPassword(),
                  const SizedBox(height: 20),
                  _crearConfirmar(),
                  const SizedBox(height: 30),
                  _crearBotonRegistrar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearEmail() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email),
      ),
      onChanged: (valor) {
        setState(() {
          _email = valor;
        });
      },
    );
  }

  Widget _crearPassword() {
    return TextField(
      obscureText: _ocultarPassword,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: 'Contraseña',
        helperText: 'Mínimo 6 caracteres',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _ocultarPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _ocultarPassword = !_ocultarPassword;
            });
          },
        ),
      ),
      onChanged: (valor) {
        setState(() {
          _password = valor;
        });
      },
    );
  }

  Widget _crearConfirmar() {
    return TextField(
      obscureText: _ocultarPassword,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: 'Repetir contraseña',
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      onChanged: (valor) {
        setState(() {
          _confirmar = valor;
        });
      },
    );
  }

  Widget _crearBotonRegistrar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _registrar,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text('Crear cuenta'),
        ),
      ),
    );
  }

  Future<void> _registrar() async {
    if (_email.isEmpty || _password.isEmpty || _confirmar.isEmpty) {
      _mostrarAlerta('Faltan datos', 'Completá todos los campos.');
      return;
    }
    if (_password != _confirmar) {
      _mostrarAlerta('Error', 'Las contraseñas no coinciden.');
      return;
    }
    final error = await authProvider.registrar(_email.trim(), _password);
    if (!mounted) return;
    if (error != null) {
      _mostrarAlerta('Error', error);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }

  void _mostrarAlerta(String titulo, String mensaje) {
    showDialog(
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
