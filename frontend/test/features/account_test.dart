import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart' show FakeAccountService;
import '../widget_test.dart' show accounts, pumpApp;

Future<void> _fill(WidgetTester tester, Map<String, String> fields) async {
  for (final MapEntry(key: label, value: text) in fields.entries) {
    final field = find.descendant(
      of: find.ancestor(of: find.text(label.toUpperCase()), matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    );
    await tester.enterText(field, text);
  }
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign up → code from the email → signed in, name carried over', (tester) async {
    await pumpApp(tester, accountChosen: false);
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);

    await _tap(tester, 'Create account');
    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);

    await _fill(tester, {'Name': 'Rudo', 'Email': 'rudo@example.com', 'Password': 'long enough'});
    await _tap(tester, 'Create account');
    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('We sent a code to rudo@example.com'), findsOneWidget);
    expect(accounts.sent, ['signup:rudo@example.com']);

    await _fill(tester, {'Code from the email': '999999'});
    await _tap(tester, 'Confirm');
    expect(find.textContaining('That code is wrong or has expired'), findsOneWidget);

    await _tap(tester, 'Send a new code');
    expect(find.text('A new code is on its way to rudo@example.com.'), findsOneWidget);
    expect(accounts.sent, hasLength(2));

    await _fill(tester, {'Code from the email': FakeAccountService.code});
    await _tap(tester, 'Confirm');
    expect(find.text('Check your email'), findsNothing);
    expect(find.textContaining('Rudo'), findsWidgets, reason: 'home greets you by name');
    expect(accounts.current?.email, 'rudo@example.com');
  });

  testWidgets('signing in before confirming asks for the code and sends a new one', (tester) async {
    await pumpApp(tester, accountChosen: false);
    accounts.users['new@example.com'] = (password: 'long enough', name: 'New');
    accounts.unconfirmed.add('new@example.com');
    await _tap(tester, 'Already have an account? Sign in');
    await _fill(tester, {'Email': 'new@example.com', 'Password': 'long enough'});
    await _tap(tester, 'Sign in');
    expect(find.text('Check your email'), findsOneWidget);
    expect(accounts.sent, ['signup:new@example.com']);
    await _fill(tester, {'Code from the email': FakeAccountService.code});
    await _tap(tester, 'Confirm');
    expect(accounts.current?.email, 'new@example.com');
  });

  testWidgets('sign in: wrong password explained, then signed in', (tester) async {
    await pumpApp(tester, accountChosen: false);
    await _tap(tester, 'Already have an account? Sign in');
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('NAME'), findsNothing);

    await _fill(tester, {'Email': 'ann@example.com', 'Password': 'wrong password'});
    await _tap(tester, 'Sign in');
    expect(find.text('That email and password don’t match.'), findsOneWidget);

    await _fill(tester, {'Password': 'correct horse'});
    await _tap(tester, 'Sign in');
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('forgot password: code by email, new password, signed in', (tester) async {
    await pumpApp(tester, accountChosen: false);
    await _tap(tester, 'Already have an account? Sign in');
    await _tap(tester, 'Forgot your password?');
    expect(find.text('Reset your password'), findsOneWidget);
    await _fill(tester, {'Email': 'ann@example.com'});
    await _tap(tester, 'Send code');
    expect(accounts.sent, ['reset:ann@example.com']);
    expect(find.text('Choose a new password'), findsOneWidget);

    await _fill(tester, {'Code from the email': FakeAccountService.code, 'New password': 'short'});
    await _tap(tester, 'Save and sign in');
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    await _fill(tester, {'New password': 'a brand new one'});
    await _tap(tester, 'Save and sign in');
    expect(accounts.current?.email, 'ann@example.com');
    expect(accounts.users['ann@example.com']!.password, 'a brand new one');
  });

  testWidgets('continue without an account, sign in later from Profile, then sign out', (tester) async {
    await pumpApp(tester, accountChosen: false);
    await _tap(tester, 'Continue without an account');
    expect(find.text('Create your account'), findsNothing);

    tester.view.physicalSize = const Size(390, 2400);
    await tester.tap(find.bySemanticsLabel('Profile').last);
    await tester.pumpAndSettle();
    await _tap(tester, 'Sign in or create an account');
    await _tap(tester, 'Already have an account? Sign in');
    expect(find.text('Continue without an account'), findsNothing);
    await _fill(tester, {'Email': 'ann@example.com', 'Password': 'correct horse'});
    await _tap(tester, 'Sign in');
    expect(find.text('ann@example.com'), findsOneWidget);

    await _tap(tester, 'Sign out');
    await _tap(tester, 'Sign out');
    expect(accounts.current, isNull);
    expect(find.text('Create your account'), findsOneWidget, reason: 'back to the account step');
  });

  testWidgets('delete my account', (tester) async {
    await pumpApp(tester);
    await accounts.signIn(email: 'ann@example.com', password: 'correct horse');
    tester.view.physicalSize = const Size(390, 2400);
    await tester.tap(find.bySemanticsLabel('Profile').last);
    await tester.pumpAndSettle();
    await _tap(tester, 'Delete my account');
    await _tap(tester, 'Delete my account');
    expect(accounts.deleted, isTrue);
  });
}
