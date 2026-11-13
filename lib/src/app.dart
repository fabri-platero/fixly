import 'package:fixly/src/provider/auth_provider.dart';
import 'package:fixly/src/routes/routes.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fixly',
      initialRoute: authProvider.usuario == null ? '/' : 'home',
      routes: getAplicationRoutes(),
    );
  }
}
