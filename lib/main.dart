// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// IMPORT CONDICIONAL:
// - Android/iOS: carga firebase_registrant_mobile.dart (stub vacío)
// - Web       : carga firebase_registrant_web.dart (registra plugins JS)
import 'firebase_registrant_mobile.dart'
    if (dart.library.html) 'firebase_registrant_web.dart';

import 'screens/email_form_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/whatsapp_groups_screen.dart';   // <-- Import de la pantalla WhatsApp

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // En móvil es no-op; en web registra los plugins JS de Firebase
  registerPlugins();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/admin':
        // Ruta protegida para la sección de Emails (AdminScreen)
        return MaterialPageRoute(
          builder: (_) => AdminGuard(child: AdminScreen()),
        );
      case '/whatsappGroups':
        // Ruta protegida para la sección de Grupos WhatsApp
        return MaterialPageRoute(
          builder: (_) => AdminGuard(child: WhatsappGroupsScreen()),
        );
      default:
        return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App Mail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EmailFormScreen(),
      routes: {
        '/login':   (_) => LoginScreen(),
        '/privacy': (_) => PrivacyScreen(),
      },
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

/// Widget genérico que protege cualquier pantalla de solo-admin
class AdminGuard extends StatefulWidget {
  final Widget child;

  const AdminGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

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
      Navigator.of(context).pushReplacementNamed('/login');
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
          // Si es admin, muestra la pantalla solicitada
          return widget.child;
        }
        // Si no, redirige a login
        _redirectToLogin();
        return const Scaffold();
      },
    );
  }
}
