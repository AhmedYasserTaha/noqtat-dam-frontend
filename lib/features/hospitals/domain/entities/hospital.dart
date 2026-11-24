import 'package:equatable/equatable.dart';

/// A hospital from the backend directory. [isVerified] is true only when
/// someone reviewed the location; imported places start unverified.
class Hospital extends Equatable {
  const Hospital({
    required this.id,
    required this.name,
    required this.governorateId,
    required this.latitude,
    required this.longitude,
    required this.isVerified,
    this.districtId,
  });
  final int id;
  final String name, governorateId;
  final String? districtId;
  final double latitude, longitude;
  final bool isVerified;

  @override
  List<Object?> get props => [
    id,
    name,
    governorateId,
    districtId,
    latitude,
    longitude,
    isVerified,
  ];
}

/// Map position attached to a blood request (null for old or free-text ones).
class HospitalLocation extends Equatable {
  const HospitalLocation({
    required this.latitude,
    required this.longitude,
    required this.isVerified,
  });
  final double latitude, longitude;
  final bool isVerified;

  @override
  List<Object?> get props => [latitude, longitude, isVerified];
}
