import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _password = '';
  bool _ocultarPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _crearLogo(),
                  const SizedBox(height: 40),
                  _crearEmail(),
                  const SizedBox(height: 20),
                  _crearPassword(),
                  const SizedBox(height: 30),
                  _crearBotonIngresar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearLogo() {
    return Column(
      children: const [
        Icon(Icons.build_circle, size: 90, color: Colors.blue),
        SizedBox(height: 10),
        Text(
          'Fixly',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text('Reportá problemas de tu ciudad'),
      ],
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

  Widget _crearBotonIngresar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _ingresar,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text('Ingresar'),
        ),
      ),
    );
  }

  void _ingresar() {
    if (_email.isEmpty || _password.isEmpty) {
      _mostrarAlerta('Completá el email y la contraseña.');
      return;
    }
    Navigator.pushReplacementNamed(context, 'home');
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
