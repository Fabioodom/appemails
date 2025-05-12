import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Intenta loguear y devuelve true si existe un doc in `admins/{uid}` con `isAdmin: true`
  Future<bool> signInAsAdmin({
    required String email,
    required String password,
  }) async {
    // 1) Autentica
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCred.user;
    if (user == null) return false;

    // 2) Verifica rol en Firestore
    final adminDoc = await _db.collection('admins').doc(user.uid).get();
    final data = adminDoc.data();
    return adminDoc.exists && (data?['isAdmin'] == true);
  }

  Future<void> signOut() async => _auth.signOut();
}
