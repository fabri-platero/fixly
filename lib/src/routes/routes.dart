import 'package:fixly/src/pages/detalle_reporte_page.dart';
import 'package:fixly/src/pages/home_page.dart';
import 'package:fixly/src/pages/login_page.dart';
import 'package:fixly/src/pages/nuevo_reporte_page.dart';
import 'package:fixly/src/pages/registro_page.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    "/": (BuildContext context) => const LoginPage(),
    "registro": (BuildContext context) => const RegistroPage(),
    "home": (BuildContext context) => const HomePage(),
    "nuevo": (BuildContext context) => const NuevoReportePage(),
    "detalle": (BuildContext context) => const DetalleReportePage(),
  };
}
