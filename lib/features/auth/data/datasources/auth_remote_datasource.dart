import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_store.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this.api, this.tokens);
  final ApiClient api;
  final TokenStore tokens;

  Stream<void> get sessionExpired => api.onUnauthorized;

  Future<AuthUserModel> _session(Json body) async {
    await tokens.write(body['token'] as String);
    return AuthUserModel.fromJson(body['user'] as Json);
  }

  Future<AuthUserModel> register(RegisterData d) async => _session(
    await api.post(
      ApiConstants.register,
      body: {
        'name': d.name,
        'phone': d.phone,
        'password': d.password,
        'bloodType': d.bloodType,
        if (d.governorateId != null) 'governorateId': d.governorateId,
        if (d.districtId != null) 'districtId': d.districtId,
      },
    ),
  );

  Future<AuthUserModel> login(String phone, String password) async => _session(
    await api.post(
      ApiConstants.login,
      body: {'phone': phone, 'password': password},
    ),
  );

  /// `null` when there is no token. A rejected token is cleared.
  Future<AuthUserModel?> restore() async {
    if (await tokens.read() == null) return null;
    try {
      return AuthUserModel.fromJson(await api.get(ApiConstants.me));
    } on ApiException catch (e) {
      if (e.failure.code == 'unauthorized') {
        await tokens.clear();
        return null;
      }
      rethrow;
    }
  }

  Future<void> logout() => tokens.clear();

  Future<void> requestPasswordReset(String phone) =>
      api.post(ApiConstants.forgotPassword, body: {'phone': phone});

  Future<void> resetPassword(String phone, String code, String password) =>
      api.post(
        ApiConstants.resetPassword,
        body: {'phone': phone, 'code': code, 'newPassword': password},
      );
}
