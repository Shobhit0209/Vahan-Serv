import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cce_auth_service.dart';

class AuthProvidar extends ChangeNotifier {
  final CCEAuthService _authService = CCEAuthService();
  final _auth = FirebaseAuth.instance;
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _cceIdKey = 'cceId'; // Key for storing cceId
  static const String _cceNameKey = 'cceName'; // Key for storing cceName
  String? _verificationId;
  String? get verificationId => _verificationId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;
  Future<void> get checkLoginStatus => _checkLoginStatus();
  AuthProvidar() {
    _checkLoginStatus();
  }

  // Check if the user was previously logged in
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (_isLoggedIn) {
      _cceId = prefs.getString(_cceIdKey);
      _cceName = prefs.getString(_cceNameKey);
    }
    notifyListeners();
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  String? _cceId;
  String? get cceId => _cceId;

  String? _cceName;
  String? get cceName => _cceName;

  Future<String?> getiDtoken() {
    final token = _auth.currentUser?.getIdToken();
    return token!;
  }

  void startPhoneAuth({
    required String phone,
    required Function() onVerified,
    required Function(String error) onError,
    required Function() onCodeSent,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _authService.startPhoneVerification(
      phone: phone,
      onVerified: () async {
        _isLoading = false;
        _isLoggedIn = true; // Mark as logged in
        await _saveLoginStatus(true, null, null); // Save login status
        notifyListeners();
        onVerified();
      },
      onCodeSent: (id) {
        _isLoading = false;
        _verificationId = id;
        notifyListeners();
        onCodeSent();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
        onError(error);
      },
    );
  }

  Future<void> verifyOtp(String smsCode, Function() onSuccess,
      Function(String) onError, String? cceId, String cceName) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.verifyOtpAndLogin(_verificationId!, smsCode);
      _isLoggedIn = true;
      _cceId = cceId!; // Store cceId
      _cceName = cceName; // Mark as logged in
      await _saveLoginStatus(true, cceId, cceName); // Save login status
      final user = _auth.currentUser;
      // ignore: unused_local_variable
      final phoneNumber = user?.phoneNumber;
      _isLoading = false;
      notifyListeners();
      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _cceId = null;
    _cceName = null;
    await _saveLoginStatus(false, null, null); // Save logout status
    notifyListeners();
    await _auth.signOut(); // Sign out from Firebase
  }

  Future<void> _saveLoginStatus(
      bool isLoggedIn, String? cceId, String? cceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    if (cceId != null) {
      await prefs.setString(_cceIdKey, cceId);
    } else {
      await prefs.remove(_cceIdKey); // Clear cceId on logout
    }
    if (cceName != null) {
      await prefs.setString(_cceNameKey, cceName);
    } else {
      await prefs.remove(_cceNameKey); // Clear cceName on logout
    }
  }
}
