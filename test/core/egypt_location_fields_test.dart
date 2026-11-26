import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/core/utils/egypt_locations.dart';
import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';

import '../helpers/fake_backend.dart';

import 'package:damy/core/widgets/egypt_location_fields.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'multiple districts persist and all districts stays above results',
    (tester) async {
      final backend = FakeBackend();
      final tokens = MemoryTokenStore();
      configureDependencies(tokens: tokens, api: backend.client(tokens));
      addTearDown(getIt.reset);
      await tester.runAsync(() => EgyptLocations.load());
      List<EgyptLocation> selection = [];
      final t = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: EgyptLocationFields(
              allowAllDistricts: true,
              initialGovernorate: const EgyptLocation(
                id: 'EG12',
                arabicName: 'الدقهلية',
                englishName: 'Dakahlia',
              ),
              onDistrictsChanged: (items) => selection = items,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.allGovernorateDistricts));
      await tester.pumpAndSettle();
      final options = find.byType(CheckboxListTile);
      final first = tester.widget<CheckboxListTile>(options.at(1)).key!;
      final second = tester.widget<CheckboxListTile>(options.at(2)).key!;
      expect(
        tester.getTopLeft(find.byKey(const Key('select-all-districts'))).dy,
        lessThan(tester.getTopLeft(find.byKey(first)).dy),
      );
      await tester.tap(find.byKey(first));
      await tester.pump();
      await tester.tap(find.byKey(second));
      await tester.pump();
      await tester.tap(find.text(t.saveChanges));
      await tester.pumpAndSettle();
      expect(selection, hasLength(2));
      await tester.tap(
        find.text(selection.map((d) => d.name('en')).join('، ')),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxListTile>(find.byKey(first)).value, isTrue);
      await tester.tap(find.byKey(const Key('select-all-districts')));
      await tester.pump();
      await tester.tap(find.text(t.saveChanges));
      await tester.pumpAndSettle();
      expect(selection, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('district picker follows governorate and resets on change', (
    tester,
  ) async {
    final selections = <String?>[];
    final backend = FakeBackend();
    final tokens = MemoryTokenStore();
    configureDependencies(tokens: tokens, api: backend.client(tokens));
    addTearDown(getIt.reset);
    await tester.runAsync(() => EgyptLocations.load());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            child: EgyptLocationFields(
              onChanged: (g, d) => selections.add(d?.id),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await EgyptLocations.load();
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('اختار المحافظة الأول'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    expect(
      find.text('اختار المحافظة'),
      findsOneWidget,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .join(' | '),
    );
    await tester.tap(find.text('اختار المحافظة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'الدقهلية');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'الدقهلية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اختار المركز أو القسم'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'المنصورة');
    await tester.pumpAndSettle();
    expect(find.text('مركز المنصورة'), findsOneWidget);
    expect(find.text('مركز طلخا'), findsNothing);
    await tester.tap(find.text('مركز المنصورة'));
    await tester.pumpAndSettle();
    expect(selections.last, isNotNull);

    await tester.tap(find.text('الدقهلية'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cairo');
    await tester.pumpAndSettle();
    await tester.tap(find.text('القاهرة'));
    await tester.pumpAndSettle();
    expect(find.text('مركز المنصورة'), findsNothing);
    expect(find.text('اختار المركز أو القسم'), findsOneWidget);
    expect(selections.last, isNull);
    expect(backend.callsTo('GET /locations/governorates'), hasLength(1));
    expect(
      backend.callsTo('GET /locations/governorates/EG12/districts'),
      hasLength(1),
    );
    expect(
      backend.callsTo('GET /locations/governorates/EG01/districts'),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });
}
