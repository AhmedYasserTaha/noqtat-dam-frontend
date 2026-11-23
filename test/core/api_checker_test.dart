import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:damy/core/network/api_checker.dart';
import 'package:damy/core/network/api_client.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/widgets/api_checker_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('captures requests once and opens the standard inspector', (
    tester,
  ) async {
    ApiChecker.init(environment: AppEnvironment.dev);
    ApiChecker.init(environment: AppEnvironment.dev);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final api = ApiClient(
      baseUrl: 'https://example.test',
      tokens: MemoryTokenStore(),
      dio: dio,
    );
    ApiChecker.attachToDio(dio);
    expect(dio.interceptors.whereType<AliceDioAdapter>(), hasLength(1));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{'ok': true},
            ),
            true,
          );
        },
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: ApiChecker.navigatorKey(),
        builder: (context, child) => ApiCheckerWidget(
          isActive: ApiChecker.isActive,
          onPressed: ApiChecker.openInspector,
          child: child!,
        ),
        home: const Scaffold(body: Text('Application')),
      ),
    );
    final result = await tester.runAsync(() => api.get('/check'));
    expect(result?['ok'], true);
    await tester.drag(find.byIcon(Icons.bug_report), const Offset(300, 80));
    await tester.pump();
    expect(tester.getTopLeft(find.byType(IconButton)).dx, 0);
    await tester.drag(find.byIcon(Icons.bug_report), const Offset(700, 0));
    await tester.pump();
    expect(tester.getTopLeft(find.byType(IconButton)).dx, 744);
    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pumpAndSettle();
    final core = dio.interceptors.whereType<AliceDioAdapter>().single.aliceCore;
    expect(core.configuration.showInspectorOnShake, isFalse);
    final calls = core.configuration.aliceStorage.getCalls();
    expect(calls, hasLength(1));
    expect(calls.single.endpoint, '/check');
    expect(calls.single.response?.status, 200);
    expect(calls.single.response?.body, {'ok': true});
    expect(core.isInspectorOpened, isTrue);
    core.dispose();
    expect(tester.takeException(), isNull);
    dio.close(force: true);
  });
}
