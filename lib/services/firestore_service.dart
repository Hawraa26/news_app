import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // إنشاء مستخدم جديد في Firestore
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // قراءة بيانات المستخدم من Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final document =
    await _firestore.collection('users').doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }
}