// lib/routes.dart

import 'package:flutter/material.dart';
import 'screens/email_form_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/login_screen.dart';

/// Define aquí todas las rutas de la aplicación.
/// La ruta '/' muestra el formulario de envío y '/admin' la pantalla de administración.
final Map<String, WidgetBuilder> appRoutes = {
  '/': (BuildContext context) => EmailFormScreen(),
  '/privacy': (BuildContext context) => PrivacyScreen(),
  '/login': (BuildContext context) => LoginScreen(),
  '/admin': (BuildContext context) => AdminScreen(),
};
