import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ner_landslideguard/app.dart';
import 'package:ner_landslideguard/core/storage/local_storage_service.dart';
import 'package:ner_landslideguard/features/authentication/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('NER-LandslideGuard app renders splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(sharedPrefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          localStorageServiceProvider.overrideWithValue(storageService),
        ],
        child: const NerLandslideGuardApp(),
      ),
    );

    expect(find.text('LandslideGuard'), findsOneWidget);
    expect(find.text('NER'), findsOneWidget);

    // Fast-forward animation and timer
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
  });
}
