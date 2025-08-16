import 'package:firebase_auth/firebase_auth.dart';

class CCEAuthService {
  final _auth = FirebaseAuth.instance;

  Future<void> startPhoneVerification({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function() onVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        onVerified();
      },
      verificationFailed: (e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (verificationId, _) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  Future<void> verifyOtpAndLogin(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }
}
