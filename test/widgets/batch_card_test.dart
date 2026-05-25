// ============================================================================
// Tests for BatchCard widget
// ============================================================================
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/batch.dart';
import 'package:batchit/widgets/batch_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Batch makeBatch({
  String id = 'b1',
  String productName = 'Rice',
  double bulkSizeKg = 100,
  double currentQuantityKg = 50,
  String status = 'open',
  String? imageUrl,
}) =>
    Batch(
      id: id,
      productName: productName,
      bulkSizeKg: bulkSizeKg,
      currentQuantityKg: currentQuantityKg,
      locationName: 'Mokolo',
      hubName: 'Hub A',
      status: status,
      imageUrl: imageUrl,
    );

Widget buildCard(Batch batch, {VoidCallback? onTap}) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 300,
          child: BatchCard(
            batch: batch,
            joinLabel: 'Join',
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );

void main() {
  group('BatchCard renders core content', () {
    testWidgets('shows product name', (tester) async {
      await tester.pumpWidget(buildCard(makeBatch(productName: 'Palm Oil')));
      await tester.pump(); // let localization load
      expect(find.text('Palm Oil'), findsOneWidget);
    });

    testWidgets('shows location and hub text', (tester) async {
      await tester.pumpWidget(buildCard(makeBatch()));
      await tester.pump();
      expect(find.textContaining('Mokolo'), findsOneWidget);
      expect(find.textContaining('Hub A'), findsOneWidget);
    });

    testWidgets('shows add icon button', (tester) async {
      await tester.pumpWidget(buildCard(makeBatch()));
      await tester.pump();
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('renders without imageUrl (asset fallback)', (tester) async {
      // No imageUrl — uses Image.asset which will fail gracefully via errorBuilder
      await tester.pumpWidget(buildCard(makeBatch(imageUrl: null)));
      await tester.pump();
      // The card itself renders — error handled by errorBuilder
      expect(find.byType(BatchCard), findsOneWidget);
    });
  });

  group('BatchCard interactions', () {
    testWidgets('tapping card fires onTap', (tester) async {
      int taps = 0;
      await tester.pumpWidget(buildCard(makeBatch(), onTap: () => taps++));
      await tester.pump();
      await tester.tap(find.byType(InkWell).first);
      expect(taps, 1);
    });

    testWidgets('tapping add button fires onTap', (tester) async {
      int taps = 0;
      await tester.pumpWidget(buildCard(makeBatch(), onTap: () => taps++));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(taps, greaterThan(0));
    });
  });
}
