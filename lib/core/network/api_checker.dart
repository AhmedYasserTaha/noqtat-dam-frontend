import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Standard network inspector, available during development only.
abstract final class ApiChecker {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static Talker? _talker;

  static bool get isActive => _talker != null;

  static void init() {
    if (!kDebugMode || _talker != null) return;
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(useConsoleLogs: false),
    );
  }

  static void attachToDio(Dio dio) {
    if (_talker == null || dio.interceptors.any((i) => i is TalkerDioLogger)) {
      return;
    }
    dio.interceptors.add(TalkerDioLogger(talker: _talker));
  }

  static void open() {
    final navigator = navigatorKey.currentState;
    final talker = _talker;
    if (navigator == null || talker == null) return;
    navigator.push<void>(
      MaterialPageRoute(
        builder: (_) =>
            TalkerScreen(talker: talker, appBarTitle: 'API Checker'),
      ),
    );
  }
}
