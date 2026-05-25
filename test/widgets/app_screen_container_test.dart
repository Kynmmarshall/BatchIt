// ============================================================================
// Tests for AppScreenContainer widget
// ============================================================================
import 'package:batchit/themes/app_theme.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildContainer({
  Widget child = const Text('Hello'),
  ThemeData? theme,
  EdgeInsetsGeometry? padding,
}) {
  final app = MaterialApp(
    theme: theme ?? ThemeData.light(),
    home: Scaffold(
      body: padding != null
          ? AppScreenContainer(padding: padding, child: child)
          : AppScreenContainer(child: child),
    ),
  );
  return app;
}

void main() {
  // Suppress image-loading errors that occur because test assets don't exist
  setUp(() {
    FlutterError.onError = (details) {
      // Ignore asset loading errors — they are expected in widget tests
      if (details.exception.toString().contains('Unable to load asset') ||
          details.exception.toString().contains('asset') &&
              details.exception.toString().contains('png')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  group('AppScreenContainer', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(buildContainer(child: const Text('BatchIt')));
      expect(find.text('BatchIt'), findsOneWidget);
    });

    testWidgets('renders with custom padding', (tester) async {
      await tester.pumpWidget(
        buildContainer(
          child: const Text('Padded'),
          padding: const EdgeInsets.all(24),
        ),
      );
      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('renders with AppTheme (uses AppBackgroundTheme extension)',
        (tester) async {
      await tester.pumpWidget(
        buildContainer(
          child: const Text('Themed'),
          theme: AppTheme.light(),
        ),
      );
      expect(find.text('Themed'), findsOneWidget);
    });

    testWidgets('renders with dark AppTheme', (tester) async {
      await tester.pumpWidget(
        buildContainer(
          child: const Text('Dark'),
          theme: AppTheme.dark(),
        ),
      );
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('contains a SafeArea', (tester) async {
      await tester.pumpWidget(buildContainer());
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('contains an AnimatedContainer', (tester) async {
      await tester.pumpWidget(buildContainer());
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });
  });
}
