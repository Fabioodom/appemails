// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;

  // Colores de la app
  static const _kGreen      = Color(0xFF2E7D32);
  static const _kLightGreen = Color(0xFFE8F5E9);
  static const _kYellow     = Color(0xFFFFEE58);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // 1) Autenticar
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      final user = cred.user!;
      
      // 2) Comprobar si está en admins/{uid}
      final adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();

      if (adminDoc.exists) {
        // 3a) Es admin → pantalla de admin
        Navigator.of(context)
            .pushReplacementNamed('/admin');
      } else {
        // 3b) No es admin → cerrar sesión y avisar
        await FirebaseAuth.instance.signOut();
        _showSnack('Usuario no autorizado como admin', isError: true);
      }
    }
    on FirebaseAuthException catch (e) {
      // 4) Errores de Auth
      _showSnack(_authErrorMessage(e), isError: true);
    }
    catch (e) {
      // 5) Cualquier otro
      _showSnack('Error inesperado: $e', isError: true);
    }
    finally {
      setState(() => _loading = false);
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      return 'Credenciales no válidas';
    }
    return 'Error en login: ${e.message ?? e.code}';
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : _kYellow,
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
        filled: true,
        fillColor: _kLightGreen,
        labelText: label,
        labelStyle: TextStyle(color: _kGreen),
        border: OutlineInputBorder(),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: _kGreen)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _kYellow, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kLightGreen,
      appBar: AppBar(
        backgroundColor: _kGreen,
        iconTheme: IconThemeData(color: _kYellow),
        title: Text('Login Admin', style: TextStyle(color: _kYellow)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: _decoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    Validators.isEmail(v) ? null : 'Email no válido',
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                decoration: _decoration('Contraseña'),
                obscureText: true,
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : 'Requerido',
              ),
              SizedBox(height: 24),
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
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_kYellow),
                          ),
                        )
                      : Text('Entrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
