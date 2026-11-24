import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.governorateId,
    required super.latitude,
    required super.longitude,
    required super.isVerified,
    super.districtId,
    super.creditsOpenStreetMap,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> j) => HospitalModel(
    id: j['id'] as int,
    name: j['name'] as String? ?? '',
    governorateId: j['governorateId'] as String? ?? '',
    districtId: j['districtId'] as String?,
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    isVerified: j['isVerified'] as bool? ?? false,
    creditsOpenStreetMap: j['dataCredit'] == 'openstreetmap',
  );

  /// `hospitalLocation` on a blood request, or null when it has none.
  static HospitalLocation? locationFromJson(Object? j) {
    if (j is! Map<String, dynamic>) return null;
    final lat = j['latitude'], lng = j['longitude'];
    if (lat is! num || lng is! num) return null;
    return HospitalLocation(
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      isVerified: j['isVerified'] as bool? ?? false,
      creditsOpenStreetMap: j['dataCredit'] == 'openstreetmap',
    );
  }
}
