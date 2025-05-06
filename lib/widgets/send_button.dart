// lib/widgets/send_button.dart

import 'package:flutter/material.dart';

/// Widget reutilizable para el botón de envío.
/// Muestra un indicador de carga cuando [loading] es true.
class SendButton extends StatelessWidget {
  /// Si está en estado de carga.
  final bool loading;

  /// Callback al pulsar el botón.
  /// Si [loading] es true o [onPressed] es null, el botón queda deshabilitado.
  final VoidCallback? onPressed;

  /// Texto del botón.
  final String label;

  const SendButton({
    Key? key,
    required this.onPressed,
    this.loading = false,
    this.label = 'Enviar Emails',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
