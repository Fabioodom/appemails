// lib/firebase_registrant.dart

// Por defecto (Android/iOS) carga el stub:
//   firebase_registrant_mobile.dart
// Pero si estamos en Web (dart.library.html) carga en su lugar:
//   firebase_registrant_web.dart
export 'firebase_registrant_mobile.dart'
    if (dart.library.html) 'firebase_registrant_web.dart';
