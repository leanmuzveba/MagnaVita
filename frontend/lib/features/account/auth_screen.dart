import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/ruva_logo.dart';
import '../../data/account.dart';
import '../../state/providers.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _codePattern = RegExp(r'^\d{6,10}$');
const minPasswordLength = 8;

String authProblemText(AppLocalizations l, AuthProblem p) => switch (p) {
  AuthProblem.invalidCredentials => l.authWrongPassword,
  AuthProblem.emailTaken => l.authEmailTaken,
  AuthProblem.weakPassword => l.authWeakPassword,
  AuthProblem.emailNotConfirmed => l.authNotConfirmed,
  AuthProblem.codeInvalid => l.authCodeInvalid,
  AuthProblem.tooManyEmails => l.authTooManyEmails,
  AuthProblem.offline => l.authOffline,
  AuthProblem.other => l.authFailed,
};

/// What the screen is asking for.
enum _Mode { signUp, signIn, confirm, forgot, reset }

/// Create an account (confirmed with a code from the inbox), sign in, reset a
/// forgotten password with a code, or carry on without an account. Shown
/// after the age check; also opened from Profile → Account ([fromSettings]).
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.fromSettings = false});
  final bool fromSettings;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  _Mode _mode = _Mode.signUp;
  bool _busy = false;
  bool _showPassword = false;
  final _name = TextEditingController();
  final _mail = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  String? _nameError, _mailError, _passwordError, _codeError, _message;

  @override
  void dispose() {
    for (final c in [_name, _mail, _password, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  AccountService get _service => ref.read(accountServiceProvider);
  String get _email => _mail.text.trim();

  void _go(_Mode mode, {String? message}) => setState(() {
    _mode = mode;
    _message = message;
    _nameError = _mailError = _passwordError = _codeError = null;
    if (mode == _Mode.confirm || mode == _Mode.reset) _code.clear();
    if (mode == _Mode.reset) _password.clear();
  });

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (!mounted) return;
      if (e.problem == AuthProblem.emailNotConfirmed) {
        // Signing in before confirming: ask for the code (and send a fresh one).
        _go(_Mode.confirm, message: context.l10n.authNotConfirmed);
        try {
          await _service.resendSignUpCode(_email);
        } on AuthFailure {
          // The earlier code may still work.
        }
      } else {
        setState(() => _message = authProblemText(context.l10n, e.problem));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signedIn({String? name}) async {
    await ref.read(accountActionsProvider).signedIn(name: name);
    if (widget.fromSettings && mounted) Navigator.of(context).pop();
  }

  bool _validate({bool name = false, bool mail = false, bool password = false, bool code = false}) {
    final l = context.l10n;
    setState(() {
      _nameError = name && _name.text.trim().isEmpty ? l.authNameNeeded : null;
      _mailError = mail && !_emailPattern.hasMatch(_email) ? l.authEmailInvalid : null;
      _passwordError = password && _password.text.length < minPasswordLength
          ? l.authPasswordShort(minPasswordLength)
          : null;
      _codeError = code && !_codePattern.hasMatch(_code.text.trim()) ? l.authCodeFormat : null;
    });
    return _nameError == null && _mailError == null && _passwordError == null && _codeError == null;
  }

  Future<void> _submit() async {
    final l = context.l10n;
    switch (_mode) {
      case _Mode.signUp:
        if (!_validate(name: true, mail: true, password: true)) return;
        final name = _name.text.trim();
        await _run(() async {
          final r = await _service.signUp(name: name, email: _email, password: _password.text);
          if (r == SignUpResult.signedIn) return _signedIn(name: name);
          if (mounted) _go(_Mode.confirm, message: l.authCodeSent(_email));
        });
      case _Mode.signIn:
        if (!_validate(mail: true, password: true)) return;
        await _run(() async {
          await _service.signIn(email: _email, password: _password.text);
          await _signedIn();
        });
      case _Mode.confirm:
        if (!_validate(code: true)) return;
        await _run(() async {
          await _service.confirmSignUp(email: _email, code: _code.text.trim());
          await _signedIn(name: _name.text.trim().isEmpty ? null : _name.text.trim());
        });
      case _Mode.forgot:
        if (!_validate(mail: true)) return;
        await _run(() async {
          await _service.sendPasswordResetCode(_email);
          if (mounted) _go(_Mode.reset, message: l.authResetSent(_email));
        });
      case _Mode.reset:
        if (!_validate(code: true, password: true)) return;
        await _run(() async {
          await _service.resetPassword(email: _email, code: _code.text.trim(), newPassword: _password.text);
          await _signedIn();
        });
    }
  }

  Future<void> _resend() => _run(() async {
    if (_mode == _Mode.reset) {
      await _service.sendPasswordResetCode(_email);
    } else {
      await _service.resendSignUpCode(_email);
    }
    if (mounted) setState(() => _message = context.l10n.authCodeResent(_email));
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (title, intro, action) = switch (_mode) {
      _Mode.signUp => (l.authCreateTitle, l.authWhy, l.authCreate),
      _Mode.signIn => (l.authSignInTitle, l.authWhy, l.authSignIn),
      _Mode.confirm => (l.authConfirmTitle, l.authConfirmIntro(_email), l.authConfirm),
      _Mode.forgot => (l.authForgotTitle, l.authForgotIntro, l.authSendCode),
      _Mode.reset => (l.authResetTitle, l.authResetIntro(_email), l.authResetSave),
    };
    final passwordField = RuvaTextField(
      controller: _password,
      label: _mode == _Mode.reset ? l.authNewPassword : l.authPassword,
      obscureText: !_showPassword,
      errorText: _passwordError,
      autofillHints: [_mode == _Mode.signIn ? AutofillHints.password : AutofillHints.newPassword],
      textInputAction: TextInputAction.done,
      suffix: IconButton(
        tooltip: _showPassword ? l.authHidePassword : l.authShowPassword,
        icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
        onPressed: () => setState(() => _showPassword = !_showPassword),
      ),
    );
    final codeField = _CodeField(
      controller: _code,
      label: l.authCode,
      errorText: _codeError,
    );
    Widget link(String text, VoidCallback onTap) => TextButton(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      onPressed: _busy ? null : onTap,
      child: Text(text, textAlign: TextAlign.center),
    );

    return Scaffold(
      appBar: widget.fromSettings ? AppBar(backgroundColor: Colors.transparent) : null,
      body: SafeArea(
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            children: [
              Row(
                children: [
                  const RuvaLogo(size: 44, semanticLabel: null),
                  const SizedBox(width: 10),
                  Text(l.appName, style: AppText.brand),
                ],
              ),
              const SizedBox(height: 28),
              Semantics(header: true, child: Text(title, style: AppText.title.copyWith(fontSize: 22))),
              const SizedBox(height: 6),
              Text(intro, style: AppText.body.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 22),
              if (_mode == _Mode.signUp) ...[
                RuvaTextField(
                  controller: _name,
                  label: l.authName,
                  errorText: _nameError,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
              ],
              if (_mode case _Mode.signUp || _Mode.signIn || _Mode.forgot) ...[
                RuvaTextField(
                  controller: _mail,
                  label: l.authEmail,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _mailError,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
              ],
              if (_mode case _Mode.confirm || _Mode.reset) ...[codeField, const SizedBox(height: 14)],
              if (_mode case _Mode.signUp || _Mode.signIn || _Mode.reset) passwordField,
              if (_message != null) ...[
                const SizedBox(height: 14),
                Semantics(
                  liveRegion: true,
                  child: Text(_message!, style: AppText.body.copyWith(color: AppColors.primary)),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(label: action, onPressed: _busy ? null : _submit),
              const SizedBox(height: 8),
              ...switch (_mode) {
                _Mode.signUp => [link(l.authHaveAccount, () => _go(_Mode.signIn))],
                _Mode.signIn => [
                  link(l.authForgot, () => _go(_Mode.forgot)),
                  link(l.authNeedAccount, () => _go(_Mode.signUp)),
                ],
                _Mode.confirm || _Mode.reset => [
                  link(l.authResend, _resend),
                  Text(l.authCheckSpam, textAlign: TextAlign.center, style: AppText.small),
                  link(l.authBackToSignIn, () => _go(_Mode.signIn)),
                ],
                _Mode.forgot => [link(l.authBackToSignIn, () => _go(_Mode.signIn))],
              },
              if (_busy) const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
              if (!widget.fromSettings && (_mode == _Mode.signUp || _mode == _Mode.signIn)) ...[
                const Divider(height: 32, color: AppColors.divider),
                link(l.authSkip, () => ref.read(accountActionsProvider).useWithoutAccount()),
                Text(l.authSkipSub, textAlign: TextAlign.center, style: AppText.small),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The emailed code: digits only, one-time-code autofill.
class _CodeField extends StatelessWidget {
  const _CodeField({required this.controller, required this.label, this.errorText});
  final TextEditingController controller;
  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MonoLabel(label),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 10,
        style: AppText.title.copyWith(fontSize: 22, letterSpacing: 6),
        decoration: InputDecoration(
          counterText: '',
          errorText: errorText,
          filled: true,
          fillColor: AppColors.lime200,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primaryMid, width: 2),
          ),
        ),
      ),
    ],
  );
}
