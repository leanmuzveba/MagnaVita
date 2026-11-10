import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/ruva_logo.dart';
import '../../data/account.dart';
import '../../state/providers.dart';

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
const minPasswordLength = 8;

String authProblemText(AppLocalizations l, AuthProblem p) => switch (p) {
  AuthProblem.invalidCredentials => l.authWrongPassword,
  AuthProblem.emailTaken => l.authEmailTaken,
  AuthProblem.weakPassword => l.authWeakPassword,
  AuthProblem.emailNotConfirmed => l.authNotConfirmed,
  AuthProblem.offline => l.authOffline,
  AuthProblem.googleNotSetUp => l.authGoogleNotSetUp,
  AuthProblem.canceled => l.authCanceled,
  AuthProblem.other => l.authFailed,
};

/// Create an account, sign in (email or Google), or carry on without one.
/// Shown after the age check; also opened from Settings ([fromSettings]).
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.fromSettings = false});
  final bool fromSettings;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _signUp = true;
  bool _busy = false;
  bool _showPassword = false;
  final _name = TextEditingController();
  final _mail = TextEditingController();
  final _password = TextEditingController();
  String? _nameError, _mailError, _passwordError, _message;

  @override
  void dispose() {
    for (final c in [_name, _mail, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  void _done() {
    if (widget.fromSettings && mounted) Navigator.of(context).pop();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _message = authProblemText(context.l10n, e.problem));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final name = _name.text.trim(), mail = _mail.text.trim(), password = _password.text;
    setState(() {
      _nameError = _signUp && name.isEmpty ? l.authNameNeeded : null;
      _mailError = _email.hasMatch(mail) ? null : l.authEmailInvalid;
      _passwordError = password.length < minPasswordLength ? l.authPasswordShort(minPasswordLength) : null;
    });
    if (_nameError != null || _mailError != null || _passwordError != null) return;
    final service = ref.read(accountServiceProvider);
    await _run(() async {
      if (_signUp) {
        final r = await service.signUp(name: name, email: mail, password: password);
        if (r == SignUpResult.confirmEmail) {
          if (mounted) {
            setState(() {
              _signUp = false;
              _message = l.authConfirmEmail(mail);
            });
          }
          return;
        }
        await ref.read(accountActionsProvider).signedIn(name: name);
      } else {
        await service.signIn(email: mail, password: password);
        await ref.read(accountActionsProvider).signedIn();
      }
      _done();
    });
  }

  Future<void> _google() => _run(() async {
    await ref.read(accountServiceProvider).signInWithGoogle();
    await ref.read(accountActionsProvider).signedIn();
    _done();
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
              Semantics(
                header: true,
                child: Text(
                  _signUp ? l.authCreateTitle : l.authSignInTitle,
                  style: AppText.title.copyWith(fontSize: 22),
                ),
              ),
              const SizedBox(height: 6),
              Text(l.authWhy, style: AppText.body.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 22),
              if (_signUp) ...[
                RuvaTextField(
                  controller: _name,
                  label: l.authName,
                  errorText: _nameError,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
              ],
              RuvaTextField(
                controller: _mail,
                label: l.authEmail,
                keyboardType: TextInputType.emailAddress,
                errorText: _mailError,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              RuvaTextField(
                controller: _password,
                label: l.authPassword,
                obscureText: !_showPassword,
                errorText: _passwordError,
                autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                textInputAction: TextInputAction.done,
                suffix: IconButton(
                  tooltip: _showPassword ? l.authHidePassword : l.authShowPassword,
                  icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 14),
                Semantics(
                  liveRegion: true,
                  child: Text(_message!, style: AppText.body.copyWith(color: AppColors.primary)),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(label: _signUp ? l.authCreate : l.authSignIn, onPressed: _busy ? null : _submit),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l.authOr, style: AppText.small),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _busy ? null : _google,
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: AppColors.track, width: 1.5),
                    foregroundColor: AppColors.text,
                    backgroundColor: AppColors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'G',
                        style: AppText.title.copyWith(fontSize: 18, color: const Color(0xFF4285F4)),
                        semanticsLabel: '',
                      ),
                      const SizedBox(width: 10),
                      Text(l.authGoogle, style: AppText.link.copyWith(fontSize: 15, color: AppColors.text)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _signUp = !_signUp;
                        _message = null;
                        _nameError = null;
                      }),
                child: Text(_signUp ? l.authHaveAccount : l.authNeedAccount),
              ),
              if (_busy) const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
              if (!widget.fromSettings) ...[
                const Divider(height: 32, color: AppColors.divider),
                TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: _busy ? null : () => ref.read(accountActionsProvider).useWithoutAccount(),
                  child: Text(l.authSkip),
                ),
                Text(l.authSkipSub, textAlign: TextAlign.center, style: AppText.small),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
