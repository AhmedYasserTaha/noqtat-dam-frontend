import '../../../../core/utils/localized_name.dart';
import '../../../hospitals/data/models/hospital_model.dart';
import '../../domain/entities/blood_request.dart';

class BloodRequestModel extends BloodRequest {
  const BloodRequestModel({
    required super.id,
    required super.authorName,
    required super.isMine,
    required super.bloodType,
    required super.bagsNeeded,
    required super.bagsCollected,
    required super.onTheWayCount,
    required super.hospitalName,
    required super.urgency,
    required super.status,
    required super.isVerified,
    required super.createdAt,
    super.governorate,
    super.district,
    super.deadline,
    super.notes,
    super.contactPhone,
    super.myPledge,
    super.hospitalId,
    super.hospitalLocation,
    super.selfReportedDonatedCount,
    super.governorateId,
    super.districtId,
  });

  factory BloodRequestModel.fromJson(Map<String, dynamic> j) =>
      BloodRequestModel(
        id: j['id'] as int,
        governorateId: j['governorateId'] as String?,
        districtId: j['districtId'] as String?,
        authorName: j['authorName'] as String? ?? '',
        isMine: j['isMine'] as bool? ?? false,
        bloodType: j['bloodType'] as String,
        bagsNeeded: j['bagsNeeded'] as int,
        bagsCollected: j['bagsCollected'] as int? ?? 0,
        onTheWayCount: j['onTheWayCount'] as int? ?? 0,
        hospitalName: j['hospitalName'] as String? ?? '',
        urgency: Urgency.fromApi(j['urgency'] as String?),
        status: RequestStatus.fromApi(j['status'] as String?),
        isVerified: j['isVerified'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
        governorate: LocalizedName.fromJson(j['governorate']),
        district: LocalizedName.fromJson(j['district']),
        deadline: j['deadline'] == null
            ? null
            : DateTime.parse(j['deadline'] as String),
        notes: j['notes'] as String?,
        contactPhone: j['contactPhone'] as String?,
        myPledge: PledgeStatus.fromApi(j['myPledgeStatus'] as String?),
        hospitalId: j['hospitalId'] as int?,
        hospitalLocation: HospitalModel.locationFromJson(j['hospitalLocation']),
        selfReportedDonatedCount: j['selfReportedDonatedCount'] as int? ?? 0,
      );
}
