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
    this.creditsOpenStreetMap = false,
  });
  final int id;
  final String name, governorateId;
  final String? districtId;
  final double latitude, longitude;
  final bool isVerified;

  /// True when the backend says the row comes from OpenStreetMap, so its credit must be shown.
  final bool creditsOpenStreetMap;

  @override
  List<Object?> get props => [
    id,
    name,
    governorateId,
    districtId,
    latitude,
    longitude,
    isVerified,
    creditsOpenStreetMap,
  ];
}

/// Map position attached to a blood request (null for old or free-text ones).
class HospitalLocation extends Equatable {
  const HospitalLocation({
    required this.latitude,
    required this.longitude,
    required this.isVerified,
    this.creditsOpenStreetMap = false,
  });
  final double latitude, longitude;
  final bool isVerified, creditsOpenStreetMap;

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    isVerified,
    creditsOpenStreetMap,
  ];
}
