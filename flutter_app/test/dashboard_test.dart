import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ner_landslideguard/features/dashboard/data/models/risk_profile_model.dart';
import 'package:ner_landslideguard/features/dashboard/presentation/citizen_home_screen.dart';
import 'package:ner_landslideguard/features/authentication/presentation/providers/auth_provider.dart';
import 'package:ner_landslideguard/app.dart';
import 'package:ner_landslideguard/core/storage/local_storage_service.dart';

void main() {
  group('Dashboard Domain & UI Unit Tests', () {
    test('RiskProfileModel has 8 realistic NER profiles', () {
      final profiles = RiskProfileModel.nerDistrictProfiles;
      expect(profiles.length, 8);
      expect(profiles.containsKey('Tawang'), isTrue);
      expect(profiles.containsKey('Gangtok'), isTrue);
      expect(profiles.containsKey('Shillong'), isTrue);
      expect(profiles.containsKey('Aizawl'), isTrue);
      expect(profiles.containsKey('Kohima'), isTrue);
      expect(profiles.containsKey('Imphal'), isTrue);
      expect(profiles.containsKey('Guwahati'), isTrue);
      expect(profiles.containsKey('Agartala'), isTrue);

      final tawang = profiles['Tawang']!;
      expect(tawang.isCritical, isTrue);
      expect(tawang.riskScore, 87);
    });

    testWidgets('CitizenHomeScreen renders risk metrics and quick operations', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(sharedPrefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            localStorageServiceProvider.overrideWithValue(storageService),
          ],
          child: const MaterialApp(
            home: CitizenHomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('NER-LandslideGuard'), findsOneWidget);
      expect(find.text('CURRENT AREA RISK'), findsOneWidget);
      expect(find.text('GIS Risk Map'), findsOneWidget);
      expect(find.text('Report Incident'), findsOneWidget);
      expect(find.text('Rainfall Radar'), findsOneWidget);
      expect(find.text('Emergency SOS'), findsOneWidget);
    });
  });
}
