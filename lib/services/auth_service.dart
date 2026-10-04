import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'هذا البريد الإلكتروني مستخدم مسبقًا.';

        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح.';

        case 'weak-password':
          return 'كلمة المرور ضعيفة. استخدمي كلمة مرور أقوى.';

        case 'operation-not-allowed':
          return 'تسجيل الحساب بالبريد الإلكتروني غير مفعّل في Firebase.';

        case 'network-request-failed':
          return 'تأكد من اتصالك بالإنترنت.';

        default:
          return 'حدث خطأ أثناء إنشاء الحساب.';
      }
    } catch (e) {
      return 'حدث خطأ غير متوقع.';
    }
  }

  Future<User?> login(
      String email,
      String password,
      ) async {
    final credential =
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Future<String?> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.';

        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح.';

        case 'network-request-failed':
          return 'تأكد من اتصالك بالإنترنت.';

        default:
          return 'حدث خطأ أثناء إرسال رابط تغيير كلمة المرور.';
      }
    }
  }
}