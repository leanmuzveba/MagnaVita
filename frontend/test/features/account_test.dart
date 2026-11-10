import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  testWidgets('after the age check: create an account → app, name carried over', (tester) async {
    await pumpApp(tester, accountChosen: false);
    expect(find.text('Create your account'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);

    await _fill(tester, {'Name': 'Rudo', 'Email': 'rudo@example.com', 'Password': 'long enough'});
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsNothing);
    expect(find.textContaining('Rudo'), findsWidgets, reason: 'home greets you by name');
    expect(accounts.current?.email, 'rudo@example.com');
  });

  testWidgets('sign in: wrong password explained, then signed in; Google not set up yet', (tester) async {
    await pumpApp(tester, accountChosen: false);
    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('NAME'), findsNothing);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('Google sign-in isn’t available yet. Use your email for now.'), findsOneWidget);

    await _fill(tester, {'Email': 'ann@example.com', 'Password': 'wrong password'});
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('That email and password don’t match.'), findsOneWidget);

    await _fill(tester, {'Password': 'correct horse'});
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('email confirmation: told to check the inbox, then sign in', (tester) async {
    await pumpApp(tester, accountChosen: false);
    accounts.confirmEmail = true;
    await _fill(tester, {'Name': 'Rudo', 'Email': 'rudo@example.com', 'Password': 'long enough'});
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('we sent a link to rudo@example.com'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('continue without an account, sign in later from Profile, then sign out', (tester) async {
    await pumpApp(tester, accountChosen: false);
    await tester.tap(find.text('Continue without an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsNothing);

    tester.view.physicalSize = const Size(390, 2400);
    await tester.tap(find.bySemanticsLabel('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in or create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Continue without an account'), findsNothing);
    await _fill(tester, {'Email': 'ann@example.com', 'Password': 'correct horse'});
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('ann@example.com'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();
    expect(accounts.current, isNull);
    expect(find.text('Create your account'), findsOneWidget, reason: 'back to the account step');
  });

  testWidgets('delete my account', (tester) async {
    await pumpApp(tester);
    await accounts.signIn(email: 'ann@example.com', password: 'correct horse');
    tester.view.physicalSize = const Size(390, 2400);
    await tester.tap(find.bySemanticsLabel('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete my account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete my account').last);
    await tester.pumpAndSettle();
    expect(accounts.deleted, isTrue);
  });
}
