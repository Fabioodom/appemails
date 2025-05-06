// lib/services/subscriber_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriberService {
  static final _col = FirebaseFirestore.instance.collection('subscribers');

  /// Añade (o actualiza) un suscriptor identificado por su email.
  static Future<void> addSubscriber({
    required String email,
    required String name,
  }) async {
    await _col.doc(email).set({
      'email': email,
      'name': name,
      'subscribedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Recupera la lista de emails de todos los suscriptores.
  static Future<List<String>> getAllSubscriberEmails() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => (d.data()['email'] as String).trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
