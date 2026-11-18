import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/core/utils/egypt_locations.dart';
import 'package:damy/core/widgets/egypt_location_fields.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('district picker follows governorate and resets on change', (
    tester,
  ) async {
    final selections = <String?>[];
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
    expect(tester.takeException(), isNull);
  });
}
