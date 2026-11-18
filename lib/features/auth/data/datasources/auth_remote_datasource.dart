import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this.auth);
  final FirebaseAuth auth;
  Stream<User?> watch() => auth.authStateChanges();
  Future<void> verify(String id, String code) async {
    await auth.signInWithCredential(
      PhoneAuthProvider.credential(verificationId: id, smsCode: code),
    );
  }

  Future<void> signOut() => auth.signOut();
}
