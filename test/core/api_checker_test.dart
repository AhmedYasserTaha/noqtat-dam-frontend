import 'package:damy/core/network/api_checker.dart';
import 'package:damy/core/network/api_client.dart';
import 'package:damy/core/storage/token_store.dart';
import 'package:damy/core/widgets/api_checker_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_dio_logger/dio_logs.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  testWidgets('captures requests once and opens the standard inspector', (
    tester,
  ) async {
    ApiChecker.init();
    ApiChecker.init();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final api = ApiClient(
      baseUrl: 'https://example.test',
      tokens: MemoryTokenStore(),
      dio: dio,
    );
    ApiChecker.attachToDio(dio);
    expect(dio.interceptors.whereType<TalkerDioLogger>(), hasLength(1));
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
        navigatorKey: ApiChecker.navigatorKey,
        builder: (context, child) => ApiCheckerWidget(child: child!),
        home: const Scaffold(body: Text('Application')),
      ),
    );
    final result = await tester.runAsync(() => api.get('/check'));
    expect(result?['ok'], true);
    await tester.tap(find.byIcon(Icons.bug_report_outlined));
    await tester.pumpAndSettle();
    final screen = tester.widget<TalkerScreen>(find.byType(TalkerScreen));
    expect(screen.talker.history.whereType<DioRequestLog>(), hasLength(1));
    expect(screen.talker.history.whereType<DioResponseLog>(), hasLength(1));
    expect(tester.takeException(), isNull);
    dio.close(force: true);
  });
}
