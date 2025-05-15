// lib/screens/email_form_screen.dart

import 'package:flutter/material.dart';
import '../services/subscriber_service.dart';
import '../utils/validators.dart';
import 'package:flutter/services.dart';

class EmailFormScreen extends StatefulWidget {
  @override
  _EmailFormScreenState createState() => _EmailFormScreenState();
}

class _EmailFormScreenState extends State<EmailFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  bool _loading = false;

  static const Color _kGreen      = Color(0xFF2E7D32);
  static const Color _kLightGreen = Color(0xFFE8F5E9);
  static const Color _kYellow     = Color(0xFFFFEE58);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final fullPhone = '+34${_phoneCtrl.text.trim()}';
      await SubscriberService.addSubscriber(
        email: _emailCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        phone: fullPhone,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Gracias por suscribirte!'),
          backgroundColor: _kGreen,
        ),
      );
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al suscribir: $e'),
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
      appBar: AppBar(
        backgroundColor: _kGreen,
        iconTheme: IconThemeData(color: _kYellow),
        title: Text(
          'Suscríbete',
          style: TextStyle(color: _kYellow),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            color: _kYellow,
            tooltip: 'Ajustes',
            onPressed: () => Navigator.of(context).pushNamed('/privacy'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                controller: _nameCtrl,
                decoration: _buildDecoration('Nombre'),
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : 'Introduce tu nombre',
              ),
              SizedBox(height: 16),
              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: _buildDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    Validators.isEmail(v) ? null : 'Email no válido',
              ),

              SizedBox(height: 16),
              // Teléfono
              TextFormField(
                controller: _phoneCtrl,
                decoration: _buildDecoration('Teléfono').copyWith(
                  prefixText: '+34 ',
                  prefixStyle: TextStyle(color: _kGreen, fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,      // Solo dígitos tras el prefijo
                ],
                validator: (v) {
                  final entered = v?.trim() ?? '';
                  // Validamos el +34 + resto de dígitos
                  return Validators.isPhone('+34$entered')
                      ? null
                      : 'Teléfono no válido';
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _subscribe,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_kYellow),
                          ),
                        )
                      : Text(
                          'Suscribirme',
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
