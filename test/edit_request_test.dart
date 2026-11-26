import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/features/blood_request/presentation/cubit/my_requests_cubit.dart';
import 'package:damy/features/blood_request/presentation/pages/my_requests_page.dart';
import 'package:damy/features/blood_request/presentation/pages/blood_request_page.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

void main() {
  testWidgets(
    'owner edits prefilled request and PATCH updates details without POST',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final backend = FakeBackend();
      var record = {
        ...requestJson(
          id: 7,
          isMine: true,
          hospital: 'Original hospital',
          contactPhone: '01012345678',
        ),
        'notes': 'Old notes',
      };
      backend.on(
        'GET /requests/mine',
        (_) => FakeReply({
          'items': [record],
        }),
      );
      backend.on('GET /requests/7/pledges', (_) => FakeReply(<Object?>[]));
      backend.on('GET /hospitals', (_) => FakeReply(<Object?>[]));
      backend.on('PATCH /requests/7', (options) {
        record = {...record, ...Map<String, dynamic>.from(options.data as Map)};
        return FakeReply(record);
      });
      final tokens = MemoryTokenStore('saved');
      configureDependencies(tokens: tokens, api: backend.client(tokens));
      addTearDown(getIt.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: BlocProvider.value(
            value: getIt<MyRequestsCubit>(),
            child: const Scaffold(body: MyRequestsPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.requestDetails));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.editBloodRequest));
      await tester.pumpAndSettle();
      final hospital = find.byKey(const ValueKey('request-hospital'));
      final formScroll = find
          .descendant(
            of: find.byType(BloodRequestPage),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(hospital, 250, scrollable: formScroll);
      final clearDistrict = find.byKey(const Key('clear-request-district'));
      await tester.ensureVisible(clearDistrict);
      await tester.tap(clearDistrict);
      await tester.pumpAndSettle();
      expect(find.text(t.requestAreaNotice), findsOneWidget);
      expect(
        tester.widget<TextField>(hospital).controller!.text,
        'Original hospital',
      );
      await tester.enterText(hospital, 'Updated hospital');
      final notes = find.byKey(const ValueKey('request-notes'));
      await tester.scrollUntilVisible(notes, 250, scrollable: formScroll);
      await tester.enterText(notes, '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, t.reviewRequestTitle),
      );
      await tester.pumpAndSettle();
      final save = find.widgetWithText(ElevatedButton, t.saveChanges);
      await tester.scrollUntilVisible(
        save,
        250,
        scrollable: find
            .descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      final body = backend.callsTo('PATCH /requests/7').single.body as Map;
      expect(body, {
        'hospitalName': 'Updated hospital',
        'notes': '',
        'districtIds': null,
      });
      expect(backend.callsTo('POST /requests'), isEmpty);
      expect(find.textContaining('Updated hospital'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
