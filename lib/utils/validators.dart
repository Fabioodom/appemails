// lib/utils/validators.dart

class Validators {
  // Expresión regular para validar emails
  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  // Expresión regular para validar teléfonos (formato E.164 opcional)
  static final RegExp _phoneRegExp = RegExp(r'^\+?\d{7,15}$');

  /// Comprueba si [value] es un email válido.
  static bool isEmail(String? value) {
    if (value == null) return false;
    return _emailRegExp.hasMatch(value.trim());
  }

  /// Comprueba que [value] no esté vacío (después de trim).
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Comprueba si [value] es un teléfono válido.
  /// Acepta dígitos con prefijo '+' opcional, de 7 a 15 caracteres.
  static bool isPhone(String? value) {
    if (value == null) return false;
    return _phoneRegExp.hasMatch(value.trim());
  }
}
