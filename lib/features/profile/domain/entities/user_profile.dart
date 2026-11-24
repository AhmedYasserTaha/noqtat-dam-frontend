import 'package:equatable/equatable.dart';

import '../../../../core/utils/localized_name.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.bloodType,
    required this.isAvailable,
    required this.notificationsEnabled,
    required this.donationsCount,
    required this.createdAt,
    this.governorateId,
    this.districtId,
    this.governorate,
    this.district,
    this.lastDonationAt,
  });
  final int id, donationsCount;
  final String name, phone, bloodType;
  final bool isAvailable, notificationsEnabled;
  final String? governorateId, districtId;
  final LocalizedName? governorate, district;

  /// Self-reported by the user. Nothing here verifies a donation.
  final DateTime? lastDonationAt;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    bloodType,
    isAvailable,
    notificationsEnabled,
    donationsCount,
    createdAt,
    governorateId,
    districtId,
    governorate,
    district,
    lastDonationAt,
  ];
}

/// A donation the donor reported themselves ("self reported", unverified).
class DonationRecord extends Equatable {
  const DonationRecord({
    required this.requestId,
    required this.donatedAt,
    required this.bloodType,
    required this.hospitalName,
  });
  final int requestId;
  final DateTime donatedAt;
  final String bloodType, hospitalName;
  @override
  List<Object?> get props => [requestId, donatedAt, bloodType, hospitalName];
}

class ProfileUpdate extends Equatable {
  const ProfileUpdate({
    this.name,
    this.phone,
    this.isAvailable,
    this.notificationsEnabled,
    this.governorateId,
    this.districtId,
    this.bloodType,
    this.lastDonationAt,
    this.clearLastDonationAt = false,
    this.donationsCount,
  });
  final String? name, phone, governorateId, districtId;
  final bool? isAvailable, notificationsEnabled;
  final String? bloodType;
  final DateTime? lastDonationAt;
  final bool clearLastDonationAt;
  final int? donationsCount;
  @override
  List<Object?> get props => [
    name,
    phone,
    isAvailable,
    notificationsEnabled,
    governorateId,
    districtId,
    bloodType,
    lastDonationAt,
    clearLastDonationAt,
    donationsCount,
  ];
}
