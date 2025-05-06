// lib/widgets/email_field.dart

import 'package:flutter/material.dart';
import '../utils/validators.dart';

/// Widget reutilizable para el campo de destinatarios del email.
/// Permite introducir múltiples direcciones separadas por comas.
class EmailField extends StatelessWidget {
  /// Controlador para acceder y modificar el texto de los destinatarios.
  final TextEditingController controller;

  /// Si el campo está habilitado o no.
  final bool enabled;

  const EmailField({
    Key? key,
    required this.controller,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: 'Destinatarios',
        hintText: 'email1@ejemplo.com, email2@ejemplo.com',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Introduce al menos un email';
        }
        final emails = val.split(',').map((e) => e.trim());
        for (final email in emails) {
          if (!Validators.isEmail(email)) {
            return 'Email inválido: $email';
          }
        }
        return null;
      },
    );
  }
}
