import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:damy/core/network/api_client.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:dio/dio.dart';

class FakeReply {
  FakeReply(this.body, [this.status = 200]);
  final Object? body;
  final int status;
}

class RecordedCall {
  RecordedCall(this.method, this.path, this.body, this.headers, this.query);
  final String method, path;
  final Object? body;
  final Map<String, dynamic> headers, query;
}

/// In-process stand-in for the backend: the real ApiClient, repositories and
/// cubits run, only the network is replaced.
class FakeBackend implements HttpClientAdapter {
  final Map<String, FakeReply Function(RequestOptions)> routes = {};
  final List<RecordedCall> calls = [];

  void on(String route, FakeReply Function(RequestOptions) handler) =>
      routes[route] = handler;

  List<RecordedCall> callsTo(String route) =>
      calls.where((c) => '${c.method} ${c.path}' == route).toList();

  ApiClient client(TokenStore tokens) => ApiClient(
    baseUrl: 'http://fake.test',
    tokens: tokens,
    dio: Dio(BaseOptions(baseUrl: 'http://fake.test'))
      ..httpClientAdapter = this,
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(
      RecordedCall(
        options.method,
        options.path,
        options.data,
        Map.of(options.headers),
        Map.of(options.queryParameters),
      ),
    );
    final handler = routes['${options.method} ${options.path}'];
    final reply =
        handler?.call(options) ?? FakeReply({'error': 'not found'}, 404);
    return ResponseBody.fromString(
      jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> requestJson({
  int id = 9,
  String bloodType = 'B-',
  String hospital = 'مستشفى الاختبار',
  String urgency = 'critical',
  int needed = 3,
  int collected = 1,
  bool isMine = false,
  String? contactPhone,
  String? myPledgeStatus,
  String status = 'open',
}) => {
  'id': id,
  'authorId': 2,
  'authorName': 'سارة',
  'isMine': isMine,
  'bloodType': bloodType,
  'bagsNeeded': needed,
  'bagsCollected': collected,
  'onTheWayCount': 2,
  'hospitalName': hospital,
  'governorateId': 'EG01',
  'districtId': 'EG0101',
  'governorate': {'id': 'EG01', 'ar': 'الدقهلية', 'en': 'Dakahlia'},
  'district': {'id': 'EG0101', 'ar': 'المنصورة', 'en': 'Mansoura'},
  'urgency': urgency,
  'deadline': null,
  'notes': null,
  'status': status,
  'isVerified': false,
  'contactVisible': contactPhone != null,
  'contactPhone': contactPhone,
  'myPledgeStatus': myPledgeStatus,
  'createdAt': '2026-11-20T10:00:00.000Z',
};

Map<String, dynamic> meJson({bool isAvailable = true}) => {
  'id': 1,
  'name': 'أحمد',
  'phone': '01012345678',
  'bloodType': 'O-',
  'governorateId': 'EG01',
  'districtId': 'EG0101',
  'governorate': {'id': 'EG01', 'ar': 'الدقهلية', 'en': 'Dakahlia'},
  'district': {'id': 'EG0101', 'ar': 'المنصورة', 'en': 'Mansoura'},
  'isAvailable': isAvailable,
  'notificationsEnabled': true,
  'lastDonationAt': null,
  'donationsCount': 0,
  'createdAt': '2026-01-05T10:00:00.000Z',
};

/// Routes that make a signed-in home screen load.
void stubHome(FakeBackend b, {List<Map<String, dynamic>>? requests}) {
  final list = requests ?? [requestJson(id: 8, hospital: 'مستشفى المنصورة')];
  b.on('GET /me', (_) => FakeReply(meJson()));
  b.on('GET /me/donations', (_) => FakeReply(<Object?>[]));
  b.on(
    'GET /home',
    (_) => FakeReply({
      'readiness': {
        'isAvailable': true,
        'lastDonationAt': null,
        'donationsCount': 0,
        'selfReported': true,
      },
      'closestUrgentRequest': null,
      'requests': list,
      'posts': <Object?>[],
    }),
  );
  b.on('GET /requests', (_) => FakeReply({'items': list, 'nextBefore': null}));
}
