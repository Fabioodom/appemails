// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;

  // Colores del estilo de la app
  static const Color _kGreen      = Color(0xFF2E7D32);
  static const Color _kLightGreen = Color(0xFFE8F5E9);
  static const Color _kYellow     = Color(0xFFFFEE58);

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
      final isAdmin = await AuthService.instance.signInAsAdmin(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (isAdmin) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/admin', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credenciales no válidas'),
            backgroundColor: _kYellow,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en login: \$e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
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
                validator: (v) => Validators.isEmail(v) ? null : 'Email no válido',
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                decoration: _buildDecoration('Contraseña'),
                obscureText: true,
                validator: (v) => Validators.isNotEmpty(v) ? null : 'Requerido',
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
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(_kYellow),
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
  }
}