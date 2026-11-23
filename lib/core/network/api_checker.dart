import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';

enum AppEnvironment { dev, staging, prod }

class ApiChecker {
  static bool isEnabled = kDebugMode;

  static final _fallbackNavigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState>? _appNavigatorKey;
  static Alice? _alice;
  static AliceDioAdapter? _adapter;

  static void init({
    required AppEnvironment environment,
    GlobalKey<NavigatorState>? navigatorKey,
    bool? enableInspector,
  }) {
    _appNavigatorKey = navigatorKey ?? _appNavigatorKey;
    if (!kDebugMode || !(enableInspector ?? isEnabled) || _alice != null) {
      return;
    }

    _alice = Alice(
      configuration: AliceConfiguration(
        showNotification: false,
        // The floating button opens Alice without requiring device sensors.
        showInspectorOnShake: false,
        directionality: TextDirection.ltr,
      ),
    );
    if (navigatorKey != null) {
      _alice!.setNavigatorKey(navigatorKey);
    }
    _adapter = AliceDioAdapter();
    _alice!.addAdapter(_adapter!);
  }

  static void attachToDio(Dio dio) {
    if (!kDebugMode) return;
    if (_adapter != null && !dio.interceptors.contains(_adapter)) {
      dio.interceptors.add(_adapter!);
    }
  }

  static GlobalKey<NavigatorState>? navigatorKey() =>
      _appNavigatorKey ?? _alice?.getNavigatorKey() ?? _fallbackNavigatorKey;

  static void openInspector() {
    if (!kDebugMode) return;
    _alice?.showInspector();
  }

  static void openAlice() => openInspector();

  static bool get isActive => kDebugMode && _alice != null;
}
