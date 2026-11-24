import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_store.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this.api, this.tokens);
  final ApiClient api;
  final TokenStore tokens;

  Future<UserProfileModel> get() async =>
      UserProfileModel.fromJson(await api.get(ApiConstants.profile));

  Future<UserProfileModel> update(ProfileUpdate u) async =>
      UserProfileModel.fromJson(
        await api.patch(
          ApiConstants.profile,
          body: {
            if (u.name != null) 'name': u.name,
            if (u.phone != null) 'phone': u.phone,
            if (u.bloodType != null) 'bloodType': u.bloodType,
            if (u.clearLastDonationAt || u.lastDonationAt != null)
              'lastDonationAt': u.clearLastDonationAt
                  ? null
                  : u.lastDonationAt!.toUtc().toIso8601String(),
            if (u.donationsCount != null) 'donationsCount': u.donationsCount,
            if (u.isAvailable != null) 'isAvailable': u.isAvailable,
            if (u.governorateId != null) 'governorateId': u.governorateId,
            if (u.districtId != null) 'districtId': u.districtId,
            if (u.notificationsEnabled != null)
              'notificationsEnabled': u.notificationsEnabled,
          },
        ),
      );

  Future<List<DonationRecord>> donations() async {
    // The endpoint returns a bare JSON array.
    final list = await api.getList(ApiConstants.donations);
    return [for (final j in list) donationFromJson(j as Json)];
  }

  Future<void> deleteAccount() async {
    await api.delete(ApiConstants.profile);
    await tokens.clear();
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await api.post(
      ApiConstants.changePassword,
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
    // A successful password change revokes all existing sessions.
    await tokens.clear();
  }
}
