// ============================================================================
// Tests for DistanceFilterBar widget
// ============================================================================
import 'package:batchit/widgets/distance_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildBar({
  double value = 20.0,
  bool hasLocation = true,
  ValueChanged<double>? onChanged,
  ValueChanged<double>? onChangeEnd,
  double min = 1.0,
  double max = 100.0,
}) =>
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          child: DistanceFilterBar(
            value: value,
            hasLocation: hasLocation,
            onChanged: onChanged ?? (_) {},
            onChangeEnd: onChangeEnd,
            min: min,
            max: max,
          ),
        ),
      ),
    );

void main() {
  group('DistanceFilterBar — label', () {
    testWidgets('shows rounded km value', (tester) async {
      await tester.pumpWidget(buildBar(value: 20));
      expect(find.text('Within 20 km'), findsOneWidget);
    });

    testWidgets('rounds fractional value up', (tester) async {
      await tester.pumpWidget(buildBar(value: 15.7));
      expect(find.text('Within 16 km'), findsOneWidget);
    });

    testWidgets('rounds fractional value down', (tester) async {
      await tester.pumpWidget(buildBar(value: 9.3));
      expect(find.text('Within 9 km'), findsOneWidget);
    });

    testWidgets('shows min value label', (tester) async {
      await tester.pumpWidget(buildBar(value: 1));
      expect(find.text('Within 1 km'), findsOneWidget);
    });

    testWidgets('shows max value label', (tester) async {
      await tester.pumpWidget(buildBar(value: 100));
      expect(find.text('Within 100 km'), findsOneWidget);
    });
  });

  group('DistanceFilterBar — location hint', () {
    testWidgets('shows hint when hasLocation is false', (tester) async {
      await tester.pumpWidget(buildBar(hasLocation: false));
      expect(find.text('Enable location for best results'), findsOneWidget);
    });

    testWidgets('hides hint when hasLocation is true', (tester) async {
      await tester.pumpWidget(buildBar(hasLocation: true));
      expect(find.text('Enable location for best results'), findsNothing);
    });
  });

  group('DistanceFilterBar — slider', () {
    testWidgets('renders a Slider widget', (tester) async {
      await tester.pumpWidget(buildBar());
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('slider value matches value prop', (tester) async {
      await tester.pumpWidget(buildBar(value: 35));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 35.0);
    });

    testWidgets('slider respects min and max', (tester) async {
      await tester.pumpWidget(buildBar(value: 5, min: 2, max: 50));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 2.0);
      expect(slider.max, 50.0);
    });

    testWidgets('value clamped to min when prop is below range', (tester) async {
      await tester.pumpWidget(buildBar(value: 0, min: 1, max: 100));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 1.0);
    });

    testWidgets('value clamped to max when prop exceeds range', (tester) async {
      await tester.pumpWidget(buildBar(value: 200, min: 1, max: 100));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 100.0);
    });
  });

  group('DistanceFilterBar — callbacks', () {
    testWidgets('onChanged fires when slider is dragged', (tester) async {
      double? received;
      await tester.pumpWidget(buildBar(
        value: 20,
        onChanged: (v) => received = v,
      ));

      await tester.drag(find.byType(Slider), const Offset(60, 0));
      await tester.pump();

      expect(received, isNotNull);
    });

    testWidgets('onChanged value is within slider range', (tester) async {
      double? received;
      await tester.pumpWidget(buildBar(
        value: 20,
        min: 1,
        max: 100,
        onChanged: (v) => received = v,
      ));

      await tester.drag(find.byType(Slider), const Offset(80, 0));
      await tester.pump();

      if (received != null) {
        expect(received, greaterThanOrEqualTo(1.0));
        expect(received, lessThanOrEqualTo(100.0));
      }
    });

    testWidgets('onChangeEnd fires when drag ends', (tester) async {
      double? endValue;
      await tester.pumpWidget(buildBar(
        value: 20,
        onChanged: (_) {},
        onChangeEnd: (v) => endValue = v,
      ));

      await tester.drag(find.byType(Slider), const Offset(60, 0));
      await tester.pump();

      expect(endValue, isNotNull);
    });

    testWidgets('null onChangeEnd does not throw', (tester) async {
      await tester.pumpWidget(buildBar(value: 20, onChangeEnd: null));
      // drag completes without throwing even though onChangeEnd is null
      await tester.drag(find.byType(Slider), const Offset(50, 0));
      await tester.pump();
    });
  });
}
