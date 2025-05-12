// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/validators.dart';
import '../../firebase_options.dart'; // Ajusta la ruta según tu estructura

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  late final Future<FirebaseApp> _initFirebase;

  // Colores del estilo de la app
  static const Color _kGreen      = Color(0xFF2E7D32);
  static const Color _kLightGreen = Color(0xFFE8F5E9);
  static const Color _kYellow     = Color(0xFFFFEE58);

  @override
  void initState() {
    super.initState();
    // Inicializamos Firebase
    _initFirebase = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 1) Validar formulario de forma segura
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _loading = true);

    try {
      // 2) Intentar login
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
          );

      // 3) Comprobar que cred.user no sea null
      final user = cred.user;
      if (user == null) {
        throw Exception('No se pudo obtener datos del usuario.');
      }

      // 4) Leer en Firestore admins/{uid}
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        // Es admin: navegar y reemplazar la pila
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        // No es admin: cerrar sesión y avisar
        await FirebaseAuth.instance.signOut();
        _showSnack('Usuario no autorizado como admin', isError: true);
      }
    } on FirebaseAuthException catch (e) {
      // Errores específicos de Auth
      _showSnack(_authErrorMessage(e), isError: true);
    } catch (e) {
      // Cualquier otro error
      _showSnack('Error inesperado: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Muestra un SnackBar con mensaje y color según sea error o no
  void _showSnack(String mensaje, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.redAccent : _kYellow,
      ),
    );
  }

  /// Traduce códigos de FirebaseAuthException a mensajes de usuario
  String _authErrorMessage(FirebaseAuthException e) {
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      return 'Credenciales no válidas';
    }
    return 'Error en login: ${e.message ?? e.code}';
  }

  InputDecoration _buildDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: _kLightGreen,
      labelText: label,
      labelStyle: TextStyle(color: _kGreen),
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kYellow, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initFirebase,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: _kLightGreen,
          appBar: AppBar(
            backgroundColor: _kGreen,
            iconTheme: IconThemeData(color: _kYellow),
            title: Text(
              'Login Admin',
              style: TextStyle(color: _kYellow),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: _buildDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        Validators.isEmail(v) ? null : 'Email no válido',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: _buildDecoration('Contraseña'),
                    obscureText: true,
                    validator: (v) =>
                        Validators.isNotEmpty(v) ? null : 'Requerido',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: _kYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(_kYellow),
                              ),
                            )
                          : Text(
                              'Entrar',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
