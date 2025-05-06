// lib/screens/email_form_screen.dart

import 'package:flutter/material.dart';
import '../services/subscriber_service.dart';
import '../utils/validators.dart';

class EmailFormScreen extends StatefulWidget {
  @override
  _EmailFormScreenState createState() => _EmailFormScreenState();
}

class _EmailFormScreenState extends State<EmailFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  bool _loading = false;

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await SubscriberService.addSubscriber(
        email: _emailCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Gracias por suscribirte!')),
      );
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al suscribir: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Suscríbete'),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          tooltip: 'Administración',
          onPressed: () => Navigator.of(context).pushNamed('/admin'),
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
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  Validators.isNotEmpty(v) ? null : 'Introduce tu nombre',
            ),
            SizedBox(height: 16),
            // Email
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  Validators.isEmail(v) ? null : 'Email no válido',
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _subscribe,
                child: _loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Suscribirme'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}