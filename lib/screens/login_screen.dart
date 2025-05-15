// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/validators.dart';

/// Destinos posibles tras el login
enum Destination { whatsapp, email }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;

  /// Estado de la selección (por defecto, ir a Emails)
  Destination _dest = Destination.email;

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
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );

      final user = cred.user;
      if (user == null) {
        throw Exception('No se pudo obtener datos del usuario.');
      }

      final adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();

      if (!adminDoc.exists) {
        await FirebaseAuth.instance.signOut();
        _showSnack('Usuario no autorizado como admin', isError: true);
      } else {
        // Navegar según la selección del usuario
        switch (_dest) {
          case Destination.whatsapp:
            Navigator.of(context)
              .pushReplacementNamed('/whatsappGroups');
            break;
          case Destination.email:
            Navigator.of(context)
              .pushReplacementNamed('/admin');
            break;
        }
      }
    } on FirebaseAuthException {
      _showSnack('Credenciales inválidas', isError: true);
    } catch (e) {
      _showSnack('Error inesperado: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
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
              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: _decoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    Validators.isEmail(v) ? null : 'Email no válido',
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passCtrl,
                decoration: _decoration('Contraseña'),
                obscureText: true,
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : 'Requerido',
              ),
              const SizedBox(height: 24),

              // Selección de destino tras login
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<Destination>(
                      title: const Text('WhatsApp'),
                      value: Destination.whatsapp,
                      groupValue: _dest,
                      activeColor: _kGreen,
                      onChanged: (Destination? val) {
                        if (val != null) setState(() => _dest = val);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<Destination>(
                      title: const Text('Emails'),
                      value: Destination.email,
                      groupValue: _dest,
                      activeColor: _kGreen,
                      onChanged: (Destination? val) {
                        if (val != null) setState(() => _dest = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botón Entrar
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
