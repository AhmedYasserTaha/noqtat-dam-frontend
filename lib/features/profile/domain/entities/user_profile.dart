import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.bloodType,
    required this.governorate,
    required this.city,
    required this.isAvailable,
    this.lastDonationAt,
    required this.donationsCount,
    this.fcmToken,
    required this.createdAt,
  });
  final String uid;
  final String name;
  final String phone;
  final String bloodType;
  final String governorate;
  final String city;
  final bool isAvailable;
  final DateTime? lastDonationAt;
  final int donationsCount;
  final String? fcmToken;
  final DateTime createdAt;
  @override
  List<Object?> get props => [
    uid,
    name,
    phone,
    bloodType,
    governorate,
    city,
    isAvailable,
    lastDonationAt,
    donationsCount,
    fcmToken,
    createdAt,
  ];
}
