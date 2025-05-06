// lib/widgets/body_field.dart

import 'package:flutter/material.dart';
import '../utils/validators.dart';

/// Widget reutilizable para el campo de texto del cuerpo del email.
class BodyField extends StatelessWidget {
  /// Controlador para acceder y modificar el texto del cuerpo.
  final TextEditingController controller;

  /// Si el campo está habilitado o no.
  final bool enabled;

  const BodyField({
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
        labelText: 'Cuerpo',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
      maxLines: 8,
      validator: (val) =>
          Validators.isNotEmpty(val) ? null : 'Cuerpo requerido',
    );
  }
}
