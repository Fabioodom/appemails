// lib/routes.dart

import 'package:flutter/material.dart';
import 'screens/email_form_screen.dart';
import 'screens/admin_screen.dart';

/// Define aquí todas las rutas de la aplicación.
/// La ruta '/' muestra el formulario de envío y '/admin' la pantalla de administración.
final Map<String, WidgetBuilder> appRoutes = {
  '/': (BuildContext context) => EmailFormScreen(),
  '/admin': (BuildContext context) => AdminScreen(),
};
