// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'     show kIsWeb;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// implementaciones web de los plugins
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'screens/email_form_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // 1) registra las implementaciones web
    FirebaseCoreWeb.registerWith(webPluginRegistrar);
    FirebaseAuthWeb.registerWith(webPluginRegistrar);
    FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
    // 2) finalmente, instala el manejador de mensajes
    webPluginRegistrar.registerMessageHandler();
  }

  // 3) inicializa tu FirebaseApp normal
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
       routes: {
        'privacy': (context) => PrivacyScreen(),
        // Ruta de login
        '/login': (context) => LoginScreen(),
        // Ruta de panel de admin
        '/admin': (context) => AdminScreen(),
      },
    );
  }
}
