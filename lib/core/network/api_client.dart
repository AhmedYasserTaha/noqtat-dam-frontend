import 'dart:async';

import 'package:dio/dio.dart';

import 'api_checker.dart';
import '../errors/failures.dart';
import '../storage/token_store.dart';

typedef Json = Map<String, dynamic>;

/// Thrown by [ApiClient]; repositories convert it to a [Failure].
class ApiException implements Exception {
  const ApiException(this.failure);
  final Failure failure;
  @override
  String toString() => 'ApiException(${failure.code})';
}

/// Maps the backend's English `error` strings to stable codes.
abstract final class ApiErrorCodes {
  static const invalidPhone = 'invalid_phone';
  static const weakPassword = 'weak_password';
  static const phoneTaken = 'phone_taken';
  static const wrongCredentials = 'wrong_credentials';
  static const invalidCode = 'invalid_code';
  static const needGovernorate = 'need_governorate';
  static const tooManyAttempts = 'too_many_attempts';
  static const invalid = 'invalid';
  static const alreadyPledged = 'already_pledged';

  static String fromMessage(String? message) {
    final m = (message ?? '').toLowerCase();
    if (m.contains('already pledged')) return alreadyPledged;
    if (m.contains('invalid phone') || m.contains('invalid contactphone')) {
      return invalidPhone;
    }
    if (m.contains('at least 8')) return weakPassword;
    if (m.contains('phone already registered')) return phoneTaken;
    if (m.contains('wrong phone or password') ||
        m.contains('wrong current password')) {
      return wrongCredentials;
    }
    if (m.contains('invalid or expired code')) return invalidCode;
    if (m.contains('set your governorate')) return needGovernorate;
    if (m.contains('too many attempts')) return tooManyAttempts;
    return invalid;
  }
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.tokens,
    Dio? dio,
    this.languageCode = 'ar',
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
               headers: {'accept': 'application/json'},
             ),
           ) {
    ApiChecker.attachToDio(_dio);
  }

  final Dio _dio;
  final TokenStore tokens;

  /// Sent as `Accept-Language` so the backend localizes errors and content.
  String languageCode;
  final _unauthorized = StreamController<void>.broadcast();

  /// Fires when the server rejects a request that carried a session token
  /// (expired or revoked), so the app can sign the user out.
  Stream<void> get onUnauthorized => _unauthorized.stream;

  Future<Json> get(String path, {Map<String, Object?>? query}) =>
      _send('GET', path, query: query);
  Future<Json> post(String path, {Object? body}) =>
      _send('POST', path, body: body ?? const {});
  Future<Json> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body ?? const {});
  Future<Json> put(String path, {Object? body}) =>
      _send('PUT', path, body: body ?? const {});
  Future<Json> delete(String path) => _send('DELETE', path);

  /// For endpoints that return a JSON array (locations).
  Future<List<dynamic>> getList(
    String path, {
    Map<String, Object?>? query,
  }) async {
    final data = await _request('GET', path, query: query);
    return data is List ? data : throw const ApiException(UnexpectedFailure());
  }

  /// Loads every item of a list endpoint. Follows `nextCursor` (page size
  /// [pageSize]) and also accepts the legacy bare-array reply, so it works
  /// against both old and new backends. Stops after [maxPages] as a guard.
  Future<List<dynamic>> getAll(
    String path, {
    Map<String, Object?>? query,
    int pageSize = 50,
    int maxPages = 100,
  }) async {
    final items = <dynamic>[];
    String? cursor;
    for (var page = 0; page < maxPages; page++) {
      final data = await _request(
        'GET',
        path,
        query: {...?query, 'limit': pageSize, 'cursor': cursor},
      );
      if (data is List) return data; // legacy backend: complete array
      if (data is! Map<String, dynamic> || data['items'] is! List) {
        throw const ApiException(UnexpectedFailure());
      }
      items.addAll(data['items'] as List);
      cursor = data['nextCursor'] as String?;
      if (data['hasMore'] != true || cursor == null) return items;
    }
    return items;
  }

  Future<Json> _send(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
  }) async {
    final data = await _request(method, path, body: body, query: query);
    return data is Map<String, dynamic>
        ? data
        : throw const ApiException(UnexpectedFailure());
  }

  Future<Object?> _request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
  }) async {
    final token = await tokens.read();
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query == null
            ? null
            : {
                for (final e in query.entries)
                  if (e.value != null) e.key: e.value,
              },
        options: Options(
          method: method,
          headers: {
            'accept-language': languageCode,
            if (token != null) 'authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && token != null) {
        _unauthorized.add(null);
      }
      throw ApiException(_mapDio(e));
    }
  }

  Failure _mapDio(DioException e) {
    final status = e.response?.statusCode;
    if (status == null) {
      return switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => const NetworkFailure(),
        _ => const UnexpectedFailure(),
      };
    }
    final data = e.response?.data;
    final error = data is Map ? data['error']?.toString() : null;
    final message = data is Map ? data['message'] as String? : null;
    final serverCode = data is Map ? data['code'] as String? : null;
    final code = serverCode?.isNotEmpty == true
        ? serverCode!
        : ApiErrorCodes.fromMessage(error);
    return switch (status) {
      400 => ValidationFailure(code, message: message),
      401 => AuthFailure(
        code == ApiErrorCodes.invalid ? 'unauthorized' : code,
        message: message,
      ),
      403 => PermissionFailure(code, message: message),
      404 => NotFoundFailure.response(serverCode ?? 'not_found', message),
      409 => ConflictFailure(code, message: message),
      429 => ValidationFailure(
        serverCode ?? ApiErrorCodes.tooManyAttempts,
        message: message,
      ),
      _ => ServerFailure.response(serverCode ?? 'server', message),
    };
  }
}
