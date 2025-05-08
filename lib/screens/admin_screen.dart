// lib/screens/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const Color _kGreen      = Color(0xFF2E7D32);
  static const Color _kLightGreen = Color(0xFFE8F5E9);
  static const Color _kYellow     = Color(0xFFFFEE58);

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
      SnackBar(
        content: Text('Remitente guardado'),
        backgroundColor: _kYellow,
      ),
    );
  }

  Future<void> _sendToAll() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final count = await EmailService.sendBulkEmail(
        sender:  _senderCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        body:    _bodyCtrl.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enviados $count correos'),
          backgroundColor: _kYellow,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar: $e'),
          backgroundColor: Colors.redAccent,
        ),
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

  InputDecoration _buildDecoration(
    String label, {
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: _kLightGreen,
      labelText: label,
      labelStyle: TextStyle(color: _kGreen),
      alignLabelWithHint: alignLabelWithHint,
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
          'Administración',
          style: TextStyle(color: _kYellow),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Remitente
              TextFormField(
                controller: _senderCtrl,
                decoration: _buildDecoration('Correo remitente'),
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
                  style: TextButton.styleFrom(foregroundColor: _kGreen),
                  child: Text('Guardar remitente'),
                ),
              ),
              SizedBox(height: 16),

              // Asunto
              TextFormField(
                controller: _subjectCtrl,
                decoration: _buildDecoration('Asunto'),
                validator: (v) =>
                    Validators.isNotEmpty(v) ? null : 'Asunto requerido',
              ),
              SizedBox(height: 16),

              // Cuerpo
              TextFormField(
                controller: _bodyCtrl,
                decoration: _buildDecoration(
                  'Cuerpo del email',
                  alignLabelWithHint: true,
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
                          'Enviar a todos los suscriptores',
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
