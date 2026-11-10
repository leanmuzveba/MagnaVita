import 'dart:async';
import 'dart:io' show SocketException;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';

/// The signed-in person.
class Account {
  const Account({required this.id, this.email, this.name = ''});
  final String id;
  final String? email;
  final String name;
}

enum AuthProblem {
  invalidCredentials,
  emailTaken,
  weakPassword,
  emailNotConfirmed,
  offline,
  googleNotSetUp,
  canceled,
  other,
}

class AuthFailure implements Exception {
  const AuthFailure(this.problem, [this.detail]);
  final AuthProblem problem;
  final String? detail;
  @override
  String toString() => 'AuthFailure($problem, $detail)';
}

/// What happened after signing up.
enum SignUpResult { signedIn, confirmEmail }

/// Accounts (Supabase Auth) and the profile row that goes with them.
abstract class AccountService {
  Account? get current;
  Stream<Account?> get changes;
  Future<SignUpResult> signUp({required String name, required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> deleteAccount();

  /// Your profile row, or null when there isn't one.
  Future<Map<String, dynamic>?> fetchProfile();
  Future<void> saveProfile(Map<String, Object?> fields);
}

class SupabaseAccountService implements AccountService {
  SupabaseClient get _db => Supabase.instance.client;
  GoTrueClient get _auth => _db.auth;

  static Account? _account(User? u) => u == null
      ? null
      : Account(
          id: u.id,
          email: u.email,
          name: (u.userMetadata?['name'] ?? u.userMetadata?['full_name'] ?? '') as String,
        );

  @override
  Account? get current => _account(_auth.currentUser);

  @override
  Stream<Account?> get changes => _auth.onAuthStateChange.map((s) => _account(s.session?.user));

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AuthFailure {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthFailure(switch (e.code) {
        'invalid_credentials' => AuthProblem.invalidCredentials,
        'user_already_exists' || 'email_exists' => AuthProblem.emailTaken,
        'weak_password' => AuthProblem.weakPassword,
        'email_not_confirmed' => AuthProblem.emailNotConfirmed,
        _ => AuthProblem.other,
      }, e.message);
    } on AuthRetryableFetchException {
      throw const AuthFailure(AuthProblem.offline);
    } on SocketException {
      throw const AuthFailure(AuthProblem.offline);
    } on GoogleSignInException catch (e) {
      throw AuthFailure(
        e.code == GoogleSignInExceptionCode.canceled ? AuthProblem.canceled : AuthProblem.other,
        e.description,
      );
    } on AuthException catch (e) {
      throw AuthFailure(AuthProblem.other, e.message);
    }
  }

  @override
  Future<SignUpResult> signUp({required String name, required String email, required String password}) =>
      _guard(() async {
        final r = await _auth.signUp(email: email, password: password, data: {'name': name});
        // Supabase answers an existing, confirmed email with a user that has no identities.
        if (r.user != null && (r.user!.identities?.isEmpty ?? false)) throw const AuthFailure(AuthProblem.emailTaken);
        return r.session == null ? SignUpResult.confirmEmail : SignUpResult.signedIn;
      });

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  bool _googleReady = false;

  @override
  Future<void> signInWithGoogle() => _guard(() async {
    if (googleWebClientId.isEmpty) throw const AuthFailure(AuthProblem.googleNotSetUp);
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(serverClientId: googleWebClientId);
      _googleReady = true;
    }
    final user = await google.authenticate(scopeHint: const ['email', 'profile']);
    final idToken = user.authentication.idToken;
    if (idToken == null) throw const AuthFailure(AuthProblem.other, 'No ID token from Google');
    final auth = await user.authorizationClient.authorizationForScopes(const ['email', 'profile']);
    await _auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken, accessToken: auth?.accessToken);
  });

  @override
  Future<void> signOut() => _guard(() async {
    await _auth.signOut();
    if (_googleReady) await GoogleSignIn.instance.signOut();
  });

  @override
  Future<void> deleteAccount() => _guard(() async {
    await _db.rpc<void>('delete_my_account');
    await signOut();
  });

  @override
  Future<Map<String, dynamic>?> fetchProfile() => _guard(() async {
    final id = _auth.currentUser?.id;
    if (id == null) return null;
    return _db.from('profiles').select().eq('id', id).maybeSingle();
  });

  @override
  Future<void> saveProfile(Map<String, Object?> fields) => _guard(() async {
    final id = _auth.currentUser?.id;
    if (id == null) return;
    await _db.from('profiles').upsert({'id': id, ...fields});
  });
}
