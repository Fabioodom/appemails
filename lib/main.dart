// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'     show kIsWeb;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// implementaciones web de los plugins Firebase
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/email_form_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    FirebaseCoreWeb.registerWith(webPluginRegistrar);
    FirebaseAuthWeb.registerWith(webPluginRegistrar);
    FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
    webPluginRegistrar.registerMessageHandler();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/admin') {
      // Envolvemos AdminScreen en un guard
      return MaterialPageRoute(builder: (_) => AdminGuard());
    }
    // Devolvemos null para que Flutter use `routes:` o el fallback
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App Mail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      // 1) Siempre carga primero el formulario:
      home: EmailFormScreen(),

      // 2) Rutas sencillas:
      routes: {
        '/login':   (_) => LoginScreen(),
        '/privacy': (_) => PrivacyScreen(),
      },

      // 3) Solo para `/admin` pasamos por aquí:
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

/// Widget que verifica autenticación y rol antes de mostrar AdminScreen
class AdminGuard extends StatefulWidget {
  @override
  _AdminGuardState createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  late Future<bool> _check;

  @override
  void initState() {
    super.initState();
    _check = _verifyAdmin();
  }

  Future<bool> _verifyAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();
    return doc.exists;
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context)
        .pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _check,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data == true) {
          return AdminScreen();
        }
        // Si no está autorizado, redirigimos:
        _redirectToLogin();
        return const Scaffold(); // vacío mientras navegamos
      },
    );
  }
}
