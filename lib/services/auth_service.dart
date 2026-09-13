import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '764750335904-lriafp256g49qagqkndo7a3qv0oqnelo.apps.googleusercontent.com',
    clientId: '764750335904-lriafp256g49qagqkndo7a3qv0oqnelo.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  static const String _keyToken = 'auth_jwt_token';
  static const String _keyUser = 'auth_user_data';

  /// Initialize auth state from local storage
  Future<void> init() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_keyToken);
      final savedUserJson = prefs.getString(_keyUser);

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        if (savedUserJson != null) {
          _user = json.decode(savedUserJson) as Map<String, dynamic>;
        }

        // Verify token with backend /api/auth/me
        try {
          final res = await http.get(
            Uri.parse('${ApiService.baseUrl}/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_token',
            },
          );
          if (res.statusCode == 200) {
            final body = json.decode(res.body) as Map<String, dynamic>;
            if (body['success'] == true && body['data'] != null) {
              _user = body['data'] as Map<String, dynamic>;
              await prefs.setString(_keyUser, json.encode(_user));
            }
          } else {
            // Token expired or invalid
            await signOut();
          }
        } catch (_) {
          // If offline, keep local stored token
        }
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        debugPrint('Google Sign-In plugin error: $e');
      }

      String? idToken;
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        idToken = googleAuth.idToken ?? googleAuth.accessToken;
      }

      // If running on desktop/emulator without Google Play Services or for testing,
      // fallback to dev mock token exchange if googleUser was obtained with an email
      if (idToken == null) {
        if (googleUser != null && googleUser.email.isNotEmpty) {
          idToken = 'mock-token-${googleUser.email}';
        } else {
          _errorMessage = 'Google Sign-In failed or was cancelled.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'] as Map<String, dynamic>;
          _token = data['token'] as String;
          _user = data['user'] as Map<String, dynamic>;

          // Persist credentials
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyToken, _token!);
          await prefs.setString(_keyUser, json.encode(_user));

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      _errorMessage = body['message'] as String? ?? 'Authentication failed';
    } catch (e) {
      _errorMessage = 'Could not sign in: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);

    notifyListeners();
  }
}
