// ============================================================================
// Tests for AppPrimaryButton widget
// ============================================================================
import 'package:batchit/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildButton(AppPrimaryButton button) => MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 300, child: button),
      ),
    );

void main() {
  group('AppPrimaryButton renders correctly', () {
    testWidgets('shows label text', (tester) async {
      await tester.pumpWidget(
        buildButton(
          AppPrimaryButton(label: 'Submit', onPressed: () {}),
        ),
      );
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows FilledButton when isSecondary is false', (tester) async {
      await tester.pumpWidget(
        buildButton(
          AppPrimaryButton(label: 'Go', onPressed: () {}),
        ),
      );
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows OutlinedButton when isSecondary is true', (tester) async {
      await tester.pumpWidget(
        buildButton(
          AppPrimaryButton(label: 'Cancel', onPressed: () {}, isSecondary: true),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(
        buildButton(
          AppPrimaryButton(label: 'Wait', onPressed: () {}, isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Wait'), findsNothing); // label hidden while loading
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        buildButton(
          AppPrimaryButton(
            label: 'Add',
            onPressed: () {},
            icon: Icons.add,
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('AppPrimaryButton interactions', () {
    testWidgets('fires onPressed when tapped', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        buildButton(
          AppPrimaryButton(label: 'Click', onPressed: () => taps++),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      expect(taps, 1);
    });

    testWidgets('does not fire when isLoading is true', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        buildButton(
          AppPrimaryButton(
            label: 'Wait',
            onPressed: () => taps++,
            isLoading: true,
          ),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      expect(taps, 0); // button is disabled during loading
    });

    testWidgets('does not fire when onPressed is null', (tester) async {
      await tester.pumpWidget(
        buildButton(
          const AppPrimaryButton(label: 'Disabled', onPressed: null),
        ),
      );
      // Should render without throwing
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('destructive secondary uses OutlinedButton', (tester) async {
      await tester.pumpWidget(
        buildButton(
          AppPrimaryButton(
            label: 'Delete',
            onPressed: () {},
            isSecondary: true,
            isDestructive: true,
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });
}
