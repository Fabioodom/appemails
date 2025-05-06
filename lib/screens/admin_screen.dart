// lib/screens/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import '../services/subscriber_service.dart';
import '../services/email_service.dart';
import '../utils/validators.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderCtrl  = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl    = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSenderEmail();
  }

  Future<void> _loadSenderEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _senderCtrl.text = prefs.getString('senderEmail') ?? '';
  }

  Future<void> _saveSender() async {
    if (!Validators.isEmail(_senderCtrl.text.trim())) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('senderEmail', _senderCtrl.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Remitente guardado')),
    );
  }

  Future<void> _sendToAll() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // 1) Leer lista de suscriptores
      

      // 2) Enviar
      final count = await EmailService.sendBulkEmail(
        sender:     _senderCtrl.text.trim(),
        subject:    _subjectCtrl.text.trim(),
        body:       _bodyCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enviados $count correos')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _senderCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administración')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Remitente
              TextFormField(
                controller: _senderCtrl,
                decoration: InputDecoration(
                  labelText: 'Correo remitente',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    Validators.isEmail(v) ? null : 'Email no válido',
                onFieldSubmitted: (_) => _saveSender(),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _saveSender,
                  child: Text('Guardar remitente'),
                ),
              ),
              SizedBox(height: 16),

              // Asunto
              TextFormField(
                controller: _subjectCtrl,
                decoration: InputDecoration(
                  labelText: 'Asunto',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : 'Asunto requerido',
              ),
              SizedBox(height: 16),

              // Cuerpo
              TextFormField(
                controller: _bodyCtrl,
                decoration: InputDecoration(
                  labelText: 'Cuerpo del email',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : 'Cuerpo requerido',
              ),
              SizedBox(height: 24),

              // Botón de envío
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _sendToAll,
                  child: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Enviar a todos los suscriptores'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
