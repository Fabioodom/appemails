// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'     show kIsWeb;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Implementaciones web de Firebase
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Tus pantallas
import 'screens/email_form_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // 1) Registra las implementaciones web
    FirebaseCoreWeb.registerWith(webPluginRegistrar);
    FirebaseAuthWeb.registerWith(webPluginRegistrar);
    FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
    // 2) Instala el manejador de mensajes
    webPluginRegistrar.registerMessageHandler();
  }

  // 3) Inicializa FirebaseApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App Mail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      // Al arrancar, va primero a EmailFormScreen
      initialRoute: '/',
      routes: {
        // Ruta por defecto: formulario de email
        '/': (context) => EmailFormScreen(),
        // Pantalla de privacidad
        '/privacy': (context) => PrivacyScreen(),
        // Login de admin
        '/login': (context) => LoginScreen(),
        // Panel de admin
        '/admin': (context) => AdminScreen(),
      },
    );
  }
}
