import 'package:damy/core/di/injection.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/theme/app_theme.dart';
import 'package:damy/core/utils/maps_launcher.dart';
import 'package:damy/features/blood_request/data/datasources/blood_request_remote_datasource.dart';
import 'package:damy/features/blood_request/data/models/blood_request_model.dart';
import 'package:damy/features/blood_request/domain/entities/blood_request.dart';
import 'package:damy/features/hospitals/domain/entities/hospital.dart';
import 'package:damy/features/hospitals/presentation/widgets/hospital_field.dart';
import 'package:damy/features/hospitals/presentation/widgets/hospital_map_button.dart';
import 'package:damy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_backend.dart';

class FakeMaps implements MapsLauncher {
  FakeMaps({this.ok = true});
  final bool ok;
  final List<String> opened = [];
  @override
  Future<bool> openCoordinates(double latitude, double longitude) async {
    opened.add('coords:$latitude,$longitude');
    return ok;
  }

  @override
  Future<bool> search(String query) async {
    opened.add('search:$query');
    return ok;
  }
}

final t = lookupAppLocalizations(const Locale('ar'));

Map<String, dynamic> hospitalJson(
  int id,
  String name, {
  bool verified = false,
}) => {
  'id': id,
  'name': name,
  'governorateId': 'EG01',
  'districtId': null,
  'latitude': 31.04,
  'longitude': 31.38,
  'isVerified': verified,
};

Future<FakeMaps> _boot(
  WidgetTester tester,
  FakeBackend backend,
  Widget body, {
  FakeMaps? maps,
}) async {
  final tokens = MemoryTokenStore('saved');
  final fake = maps ?? FakeMaps();
  configureDependencies(
    tokens: tokens,
    api: backend.client(tokens),
    maps: fake,
  );
  addTearDown(getIt.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: body),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  test('Maps URLs use the official format and need no API key', () {
    expect(
      mapsCoordinatesUri(31.04, 31.38).toString(),
      'https://www.google.com/maps/search/?api=1&query=31.04%2C31.38',
    );
    final search = mapsSearchUri('مستشفى الجامعة المنصورة');
    expect(search.queryParameters['api'], '1');
    expect(search.queryParameters['query'], 'مستشفى الجامعة المنصورة');
    expect(search.queryParameters.containsKey('key'), isFalse);
  });

  test('requests parse the hospital location, old requests have none', () {
    final old = BloodRequestModel.fromJson(requestJson());
    expect(old.hospitalId, isNull);
    expect(old.hospitalLocation, isNull);
    final linked = BloodRequestModel.fromJson({
      ...requestJson(),
      'hospitalId': 4,
      'hospitalLocation': {
        'latitude': 31.04,
        'longitude': 31.38,
        'isVerified': false,
      },
    });
    expect(linked.hospitalId, 4);
    expect(linked.hospitalLocation?.latitude, 31.04);
    expect(linked.hospitalLocation?.isVerified, isFalse);
  });

  test(
    'create sends hospitalId only when a directory hospital was picked',
    () async {
      final backend = FakeBackend();
      backend.on('POST /requests', (_) => FakeReply(requestJson(id: 20), 201));
      final tokens = MemoryTokenStore('saved');
      final remote = BloodRequestRemoteDataSource(backend.client(tokens));
      BloodRequestDraft draft(int? hospitalId) => BloodRequestDraft(
        bloodType: 'O-',
        bagsNeeded: 2,
        hospitalName: 'مستشفى',
        governorateId: 'EG01',
        districtId: 'EG0101',
        urgency: Urgency.critical,
        contactPhone: '01012345678',
        hospitalId: hospitalId,
      );
      await remote.create(draft(7));
      await remote.create(draft(null));
      final calls = backend.callsTo('POST /requests');
      expect((calls[0].body as Map)['hospitalId'], 7);
      expect((calls[1].body as Map).containsKey('hospitalId'), isFalse);
      expect((calls[1].body as Map)['hospitalName'], 'مستشفى');
    },
  );

  testWidgets('map button opens exact coordinates and flags unreviewed ones', (
    tester,
  ) async {
    final maps = await _boot(
      tester,
      FakeBackend(),
      const HospitalMapButton(
        location: HospitalLocation(
          latitude: 31.04,
          longitude: 31.38,
          isVerified: false,
        ),
        searchQuery: 'x',
      ),
    );
    expect(find.text(t.hospitalLocationUnreviewed), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hospital-map-button')));
    await tester.pumpAndSettle();
    expect(maps.opened, ['coords:31.04,31.38']);
  });

  testWidgets('map button for a typed hospital only searches and warns', (
    tester,
  ) async {
    final maps = await _boot(
      tester,
      FakeBackend(),
      const HospitalMapButton(location: null, searchQuery: 'مستشفى س المنصورة'),
      maps: FakeMaps(ok: false),
    );
    expect(find.text(t.hospitalTypedByHand), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hospital-map-button')));
    await tester.pumpAndSettle();
    expect(maps.opened, ['search:مستشفى س المنصورة']);
    expect(find.text(t.mapsOpenFailed), findsOneWidget);
  });

  testWidgets('field: picks from the directory and reports the hospital id', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.on(
      'GET /hospitals',
      (_) => FakeReply([
        hospitalJson(4, 'مستشفى المنصورة الدولي'),
        hospitalJson(5, 'مستشفى الأطفال'),
      ]),
    );
    final controller = TextEditingController();
    final picked = <int?>[];
    await _boot(
      tester,
      backend,
      HospitalField(
        governorateId: 'EG01',
        controller: controller,
        onSelected: (h) => picked.add(h?.id),
      ),
    );
    expect(backend.callsTo('GET /hospitals').single.query, {
      'governorateId': 'EG01',
    });
    await tester.tap(find.byKey(const ValueKey('request-hospital-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'مستشفى الأطفال'));
    await tester.pumpAndSettle();
    expect(controller.text, 'مستشفى الأطفال');
    expect(picked, [5]);
  });

  testWidgets('field: "not listed" switches to typing and clears the id', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.on(
      'GET /hospitals',
      (_) => FakeReply([hospitalJson(4, 'مستشفى المنصورة الدولي')]),
    );
    final controller = TextEditingController();
    final picked = <int?>[];
    await _boot(
      tester,
      backend,
      HospitalField(
        governorateId: 'EG01',
        controller: controller,
        onSelected: (h) => picked.add(h?.id),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('request-hospital-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hospital-not-listed')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('request-hospital')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('request-hospital')),
      'مستشفى جديد',
    );
    expect(controller.text, 'مستشفى جديد');
    expect(picked, [null]);
  });

  testWidgets('field: empty or failing directory falls back to typing', (
    tester,
  ) async {
    final empty = FakeBackend();
    empty.on('GET /hospitals', (_) => FakeReply(<Object?>[]));
    await _boot(
      tester,
      empty,
      HospitalField(
        governorateId: 'EG01',
        controller: TextEditingController(),
        onSelected: (_) {},
      ),
    );
    expect(find.byKey(const ValueKey('request-hospital')), findsOneWidget);
    expect(find.byKey(const ValueKey('request-hospital-picker')), findsNothing);
    await getIt.reset();

    final failing = FakeBackend();
    failing.on('GET /hospitals', (_) => FakeReply({'error': 'x'}, 500));
    await _boot(
      tester,
      failing,
      HospitalField(
        governorateId: 'EG01',
        controller: TextEditingController(),
        onSelected: (_) {},
      ),
    );
    expect(find.byKey(const ValueKey('request-hospital')), findsOneWidget);
    await getIt.reset();

    // No governorate yet: typing is available and nothing is requested.
    final none = FakeBackend();
    await _boot(
      tester,
      none,
      HospitalField(
        governorateId: null,
        controller: TextEditingController(),
        onSelected: (_) {},
      ),
    );
    expect(find.byKey(const ValueKey('request-hospital')), findsOneWidget);
    expect(none.callsTo('GET /hospitals'), isEmpty);
  });
}
