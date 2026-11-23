import 'package:damy/core/network/api_client.dart';
import 'package:damy/core/network/locations_api.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_backend.dart';

void main() {
  test('loads API names and districts for the requested governorate', () async {
    final backend = FakeBackend();
    backend.on(
      'GET /locations/governorates',
      (_) => FakeReply([
        {'id': 'EG19', 'ar': 'الإسماعيلية', 'en': 'Ismailia'},
      ]),
    );
    backend.on(
      'GET /locations/governorates/EG19/districts',
      (_) => FakeReply([
        {
          'id': 'EG1905',
          'governorateId': 'EG19',
          'ar': 'التل الكبير',
          'en': 'Tal al-Kabir',
        },
      ]),
    );
    final locations = LocationsApi(backend.client(MemoryTokenStore()));
    final governorates = await locations.governorates();
    expect(governorates.single.id, 'EG19');
    expect(governorates.single.name('ar'), 'الإسماعيلية');
    expect(governorates.single.name('en'), 'Ismailia');
    final districts = await locations.districts(governorates.single.id);
    expect(districts.single.parentId, 'EG19');
    expect(districts.single.id, 'EG1905');
    expect(backend.calls.map((c) => c.path), [
      '/locations/governorates',
      '/locations/governorates/EG19/districts',
    ]);
  });

  test(
    'failed loads can be retried without retaining a failed future',
    () async {
      final backend = FakeBackend();
      var attempts = 0;
      backend.on(
        'GET /locations/governorates',
        (_) => ++attempts == 1
            ? FakeReply({'error': 'unavailable'}, 503)
            : FakeReply(<Object?>[]),
      );
      final locations = LocationsApi(backend.client(MemoryTokenStore()));
      await expectLater(locations.governorates(), throwsA(isA<ApiException>()));
      expect(await locations.governorates(), isEmpty);
      expect(attempts, 2);
    },
  );
}
