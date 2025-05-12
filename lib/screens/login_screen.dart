// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      // 1) Intentar login con email + password
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
          );

      final user = cred.user;
      if (user == null) {
        throw Exception('Usuario no encontrado tras autenticar.');
      }

      // 2) Comprobar si existe en admins/{uid}
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        // 3a) Es admin → entrar
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        // 3b) No es admin → cerrar sesión
        await FirebaseAuth.instance.signOut();
        _showError('No autorizado como admin');
      }
    } on FirebaseAuthException catch (e) {
      _showError('Credenciales inválidas');
    } catch (e) {
      _showError('Error inesperado');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
