import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth;

  final FirebaseAuth? _auth;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register({required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  String translateError(Object? error) {
    final code = error.toString();
    if (code.contains('invalid-credential') ||
        code.contains('wrong-password') ||
        code.contains('user-not-found')) {
      return 'כתובת האימייל או הסיסמה שגויים';
    }
    if (code.contains('email-already-in-use')) {
      return 'כתובת האימייל כבר רשומה במערכת';
    }
    if (code.contains('weak-password')) {
      return 'הסיסמה חייבת להכיל לפחות 6 תווים';
    }
    if (code.contains('invalid-email')) {
      return 'נא להזין כתובת אימייל תקינה';
    }
    if (code.contains('network-request-failed')) {
      return 'בעיית תקשורת. בדוק את החיבור לאינטרנט';
    }
    if (code.contains('too-many-requests')) {
      return 'יותר מדי ניסיונות. נא לנסות שוב מאוחר יותר';
    }
    return 'אירעה שגיאה. נא לנסות שוב';
  }
}
