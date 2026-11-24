import 'package:damy/core/network/api_client.dart';
import 'package:damy/core/errors/failures.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_backend.dart';

void main() {
  test(
    'language header follows current app language on every request',
    () async {
      final backend = FakeBackend();
      backend.on('GET /probe', (_) => FakeReply({'ok': true}));
      backend.on('POST /probe', (_) => FakeReply({'ok': true}));
      final api = backend.client(MemoryTokenStore('saved'));
      await api.get('/probe');
      expect(backend.calls.last.headers['accept-language'], 'ar');
      api.languageCode = 'en';
      await api.post('/probe');
      expect(backend.calls.last.headers['accept-language'], 'en');
    },
  );

  test('already pledged has a specific conflict code', () async {
    final backend = FakeBackend();
    backend.on(
      'POST /requests/4/pledge',
      (_) => FakeReply({'error': 'already pledged'}, 409),
    );
    final api = backend.client(MemoryTokenStore('saved'));
    await expectLater(
      api.post('/requests/4/pledge'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.failure,
          'failure',
          isA<ConflictFailure>().having(
            (f) => f.code,
            'code',
            ApiErrorCodes.alreadyPledged,
          ),
        ),
      ),
    );
  });
}
