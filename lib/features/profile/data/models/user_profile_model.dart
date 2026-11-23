import '../../../../core/utils/localized_name.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.bloodType,
    required super.isAvailable,
    required super.notificationsEnabled,
    required super.donationsCount,
    required super.createdAt,
    super.governorateId,
    super.districtId,
    super.governorate,
    super.district,
    super.lastDonationAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> j) => UserProfileModel(
    id: j['id'] as int,
    name: j['name'] as String,
    phone: j['phone'] as String,
    bloodType: j['bloodType'] as String,
    isAvailable: j['isAvailable'] as bool? ?? true,
    notificationsEnabled: j['notificationsEnabled'] as bool? ?? true,
    donationsCount: j['donationsCount'] as int? ?? 0,
    createdAt: DateTime.parse(j['createdAt'] as String),
    governorateId: j['governorateId'] as String?,
    districtId: j['districtId'] as String?,
    governorate: LocalizedName.fromJson(j['governorate']),
    district: LocalizedName.fromJson(j['district']),
    lastDonationAt: j['lastDonationAt'] == null
        ? null
        : DateTime.parse(j['lastDonationAt'] as String),
  );
}

DonationRecord donationFromJson(Map<String, dynamic> j) => DonationRecord(
  requestId: j['requestId'] as int,
  donatedAt: DateTime.parse(j['donatedAt'] as String),
  bloodType: j['bloodType'] as String? ?? '',
  hospitalName: j['hospitalName'] as String? ?? '',
);
