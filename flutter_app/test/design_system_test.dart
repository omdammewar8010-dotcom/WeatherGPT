import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/core/widgets/risk_badge.dart';
import 'package:ner_landslideguard/core/widgets/risk_score_dial.dart';
import 'package:ner_landslideguard/core/widgets/prediction_factor_bar.dart';

void main() {
  testWidgets('RiskBadge renders critical and low badges accurately', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              RiskBadge(score: 87),
              RiskBadge(score: 15),
            ],
          ),
        ),
      ),
    );

    expect(find.text('CRITICAL (87)'), findsOneWidget);
    expect(find.text('LOW (15)'), findsOneWidget);
  });

  testWidgets('RiskScoreDial paints score numbers properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RiskScoreDial(score: 87, showAnimation: false),
          ),
        ),
      ),
    );

    expect(find.text('87'), findsOneWidget);
    expect(find.text('CRITICAL'), findsOneWidget);
  });

  testWidgets('PredictionFactorBar shows title and percentage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PredictionFactorBar(
            title: 'Soil Moisture',
            percentage: 91,
          ),
        ),
      ),
    );

    expect(find.text('Soil Moisture'), findsOneWidget);
    expect(find.text('91%'), findsOneWidget);
  });
}
