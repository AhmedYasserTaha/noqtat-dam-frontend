import 'package:damy/core/storage/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_backend.dart';

void main() {
  test('getAll follows nextCursor, keeps order, sends language', () async {
    final b = FakeBackend();
    b.on('GET /hospitals', (o) {
      final c = o.queryParameters['cursor'];
      return c == null
          ? FakeReply({
              'items': [1, 2],
              'nextCursor': 'o:2',
              'hasMore': true,
            })
          : FakeReply({
              'items': [3],
              'nextCursor': null,
              'hasMore': false,
            });
    });
    final api = b.client(MemoryTokenStore());
    expect(await api.getAll('/hospitals'), [1, 2, 3]);
    expect(b.calls.length, 2);
    expect(b.calls.first.query['limit'], 50);
    expect(b.calls.first.headers['accept-language'], 'ar');
  });

  test('getAll accepts the legacy bare array', () async {
    final b = FakeBackend();
    b.on('GET /x', (_) => FakeReply([1, 2]));
    expect(await b.client(MemoryTokenStore()).getAll('/x'), [1, 2]);
    expect(b.calls.length, 1);
  });
}
