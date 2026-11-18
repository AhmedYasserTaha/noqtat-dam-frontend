import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/model_dates.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.name,
    required super.phone,
    required super.bloodType,
    required super.governorate,
    required super.city,
    required super.isAvailable,
    super.lastDonationAt,
    required super.donationsCount,
    super.fcmToken,
    required super.createdAt,
  });
  factory UserProfileModel.fromMap(Map<String, dynamic> map) =>
      UserProfileModel(
        uid: map['uid'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String,
        bloodType: map['bloodType'] as String,
        governorate: map['governorate'] as String,
        city: map['city'] as String,
        isAvailable: map['isAvailable'] as bool,
        lastDonationAt: readOptionalDate(map['lastDonationAt']),
        donationsCount: map['donationsCount'] as int,
        fcmToken: map['fcmToken'] as String?,
        createdAt: readDate(map['createdAt']),
      );
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'phone': phone,
    'bloodType': bloodType,
    'governorate': governorate,
    'city': city,
    'isAvailable': isAvailable,
    'lastDonationAt': lastDonationAt == null
        ? null
        : Timestamp.fromDate(lastDonationAt!),
    'donationsCount': donationsCount,
    'fcmToken': fcmToken,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
