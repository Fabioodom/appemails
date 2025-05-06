// lib/widgets/subject_field.dart

import 'package:flutter/material.dart';
import '../utils/validators.dart';

/// Widget reutilizable para el campo de asunto del email.
class SubjectField extends StatelessWidget {
  /// Controlador para acceder y modificar el texto del asunto.
  final TextEditingController controller;

  /// Si el campo está habilitado o no.
  final bool enabled;

  const SubjectField({
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
        labelText: 'Asunto',
        border: OutlineInputBorder(),
      ),
      validator: (val) =>
          Validators.isNotEmpty(val) ? null : 'Asunto requerido',
    );
  }
}
