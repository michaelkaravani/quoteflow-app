import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, Stream<User?>? authStream})
      : _auth = auth,
        _authStream = authStream;

  final FirebaseAuth? _auth;
  final Stream<User?>? _authStream;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _authStream ?? _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
