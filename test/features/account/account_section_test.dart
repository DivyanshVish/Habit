import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/account/domain/account_domain.dart';
import 'package:habit_tracker/features/account/presentation/account_section.dart';

import '../../helpers/pump_app.dart';

const _guest = GoogleLinkState(linked: false);
const _linked = GoogleLinkState(linked: true, email: 'ann@example.com');

void main() {
  group('AccountChangeCopy', () {
    test(
      'signing out of a guest account says the data cannot be recovered',
      () {
        final copy = AccountChangeCopy.signOut(_guest);

        expect(copy.losesData, isTrue);
        expect(copy.message, contains('cannot be recovered'));
        expect(copy.message, contains('Link Google first'));
        expect(copy.confirmLabel, 'Sign out anyway');
      },
    );

    test(
      'signing out of a linked account names the account and the way back',
      () {
        final copy = AccountChangeCopy.signOut(_linked);

        expect(copy.losesData, isFalse);
        expect(copy.message, contains('ann@example.com'));
        expect(copy.message, contains('new guest account'));
        expect(copy.message, isNot(contains('cannot be recovered')));
      },
    );

    test('switching away from a guest account warns the same way', () {
      final copy = AccountChangeCopy.switchAccount(_guest);

      expect(copy.losesData, isTrue);
      expect(copy.message, contains('cannot be recovered'));
      expect(copy.confirmLabel, 'Switch anyway');
    });

    test(
      'switching away from a linked account says it can be switched back',
      () {
        final copy = AccountChangeCopy.switchAccount(_linked);

        expect(copy.losesData, isFalse);
        expect(copy.message, contains('ann@example.com'));
        expect(copy.message, contains('switch back'));
      },
    );

    test('moving data explains who receives it and what is left behind', () {
      final copy = AccountChangeCopy.moveData(_linked);

      expect(copy.message, contains('groups'));
      expect(copy.message, contains('shared habits'));
      expect(copy.message, contains('no Habitry data'));
      expect(copy.message, contains('ann@example.com'));
      expect(copy.message, contains('empty'));
    });

    test('deleting says what goes, what stays and what to do first', () {
      for (final state in [_guest, _linked]) {
        final copy = AccountChangeCopy.deleteAccount(state);

        expect(copy.losesData, isTrue);
        expect(copy.message, contains('cannot be undone'));
        expect(copy.message, contains('Deleted user'));
        expect(copy.message, contains('hand it to someone else'));
        expect(copy.confirmLabel, 'Delete everything');
      }
    });

    test('a linked account without an email still reads naturally', () {
      final copy = AccountChangeCopy.signOut(
        const GoogleLinkState(linked: true),
      );

      expect(copy.message, contains('your Google account'));
    });
  });

  group('AccountSection', () {
    Future<void> pump(
      WidgetTester tester,
      GoogleLinkState state, {
      bool busy = false,
      List<String>? taps,
      double textScale = 1,
      bool withMove = true,
      bool withDelete = true,
    }) {
      return tester.pumpWidget(
        themedApp(
          Scaffold(
            body: SingleChildScrollView(
              child: AccountSection(
                state: state,
                busy: busy,
                onLink: () => taps?.add('link'),
                onSwitch: () => taps?.add('switch'),
                onSignOut: () => taps?.add('signOut'),
                onMove: withMove ? () => taps?.add('move') : null,
                onDelete: withDelete ? () => taps?.add('delete') : null,
              ),
            ),
          ),
          textScale: textScale,
        ),
      );
    }

    testWidgets('a guest sees the warning, Link, Switch and Sign out', (
      tester,
    ) async {
      await pump(tester, _guest);

      expect(find.textContaining('guest account'), findsOneWidget);
      expect(find.text('Link Google account'), findsOneWidget);
      expect(find.text('Switch account'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('a linked user sees their email and no Link button', (
      tester,
    ) async {
      await pump(tester, _linked);

      expect(find.textContaining('ann@example.com'), findsOneWidget);
      expect(find.text('Link Google account'), findsNothing);
      expect(find.text('Switch account'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('only a Google account is offered "Move my data"', (
      tester,
    ) async {
      await pump(tester, _guest);
      expect(find.text('Move my data to another account'), findsNothing);

      await pump(tester, _linked);
      expect(find.text('Move my data to another account'), findsOneWidget);
    });

    testWidgets('Move my data calls its action', (tester) async {
      final taps = <String>[];
      await pump(tester, _linked, taps: taps);

      await tester.tap(find.text('Move my data to another account'));

      expect(taps, ['move']);
    });

    testWidgets('a delete button is offered and calls its action', (
      tester,
    ) async {
      final taps = <String>[];
      await pump(tester, _guest, taps: taps);

      expect(find.text('Delete my account'), findsOneWidget);
      await tester.tap(find.text('Delete my account'));

      expect(taps, ['delete']);
    });

    testWidgets('no delete button without an action', (tester) async {
      await pump(tester, _guest, withDelete: false);

      expect(find.text('Delete my account'), findsNothing);
    });

    testWidgets('delete is disabled while something is running', (
      tester,
    ) async {
      final taps = <String>[];
      await pump(tester, _linked, busy: true, taps: taps);

      await tester.tap(find.text('Delete my account'));

      expect(taps, isEmpty);
    });

    testWidgets('each button calls its own action', (tester) async {
      final taps = <String>[];
      await pump(tester, _guest, taps: taps);

      await tester.tap(find.text('Link Google account'));
      await tester.tap(find.text('Switch account'));
      await tester.tap(find.text('Sign out'));

      expect(taps, ['link', 'switch', 'signOut']);
    });

    testWidgets('nothing can be tapped while an action is running', (
      tester,
    ) async {
      final taps = <String>[];
      await pump(tester, _guest, busy: true, taps: taps);

      await tester.tap(find.text('Switch account'));
      await tester.tap(find.text('Sign out'));
      await tester.tap(find.text('Please wait…'));

      expect(taps, isEmpty);
    });

    testWidgets('does not overflow at 2x text on a small phone', (
      tester,
    ) async {
      useSmallPhone(tester);
      await pump(tester, _linked, textScale: 2);

      expect(tester.takeException(), isNull);
    });

    testWidgets('the buttons are labelled for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, _guest);

      expect(find.bySemanticsLabel('Sign out'), findsOneWidget);
      expect(find.bySemanticsLabel('Switch account'), findsOneWidget);
      handle.dispose();
    });
  });
}
