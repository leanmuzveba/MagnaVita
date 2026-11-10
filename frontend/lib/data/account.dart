import 'dart:async';
import 'dart:io' show SocketException;

import 'package:supabase_flutter/supabase_flutter.dart';

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
  codeInvalid,
  tooManyEmails,
  offline,
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

/// Accounts (Supabase Auth, email and password) and the profile row that
/// goes with them. New accounts confirm their email with a code from the
/// inbox; a forgotten password is reset with a code the same way.
abstract class AccountService {
  Account? get current;
  Stream<Account?> get changes;
  Future<SignUpResult> signUp({required String name, required String email, required String password});

  /// Confirms a new account with the code from the email, which signs in.
  Future<void> confirmSignUp({required String email, required String code});
  Future<void> resendSignUpCode(String email);
  Future<void> signIn({required String email, required String password});

  /// Emails a code for setting a new password.
  Future<void> sendPasswordResetCode(String email);

  /// Checks the code, sets [newPassword] and signs in.
  Future<void> resetPassword({required String email, required String code, required String newPassword});
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
      : Account(id: u.id, email: u.email, name: (u.userMetadata?['name'] ?? '') as String);

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
        'otp_expired' || 'otp_disabled' => AuthProblem.codeInvalid,
        'over_email_send_rate_limit' || 'over_request_rate_limit' => AuthProblem.tooManyEmails,
        _ => AuthProblem.other,
      }, e.message);
    } on AuthRetryableFetchException {
      throw const AuthFailure(AuthProblem.offline);
    } on SocketException {
      throw const AuthFailure(AuthProblem.offline);
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
  Future<void> confirmSignUp({required String email, required String code}) =>
      _guard(() => _auth.verifyOTP(email: email, token: code, type: OtpType.signup));

  @override
  Future<void> resendSignUpCode(String email) => _guard(() => _auth.resend(email: email, type: OtpType.signup));

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<void> sendPasswordResetCode(String email) => _guard(() => _auth.resetPasswordForEmail(email));

  @override
  Future<void> resetPassword({required String email, required String code, required String newPassword}) =>
      _guard(() async {
        await _auth.verifyOTP(email: email, token: code, type: OtpType.recovery);
        await _auth.updateUser(UserAttributes(password: newPassword));
      });

  @override
  Future<void> signOut() => _guard(() => _auth.signOut());

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
