import 'package:equatable/equatable.dart';

import '../../../../core/utils/localized_name.dart';
import '../../../hospitals/domain/entities/hospital.dart';

enum Urgency {
  critical('critical'),
  within24h('within_24h'),
  scheduled('scheduled');

  const Urgency(this.api);
  final String api;
  static Urgency fromApi(String? v) =>
      values.firstWhere((u) => u.api == v, orElse: () => Urgency.scheduled);
}

enum RequestStatus {
  open,
  fulfilled,
  cancelled,
  expired;

  static RequestStatus fromApi(String? v) =>
      values.firstWhere((s) => s.name == v, orElse: () => RequestStatus.open);
}

enum PledgeStatus {
  onTheWay('on_the_way'),
  donated('donated'),
  cancelled('cancelled');

  const PledgeStatus(this.api);
  final String api;
  static PledgeStatus? fromApi(String? v) {
    for (final s in values) {
      if (s.api == v) return s;
    }
    return null;
  }
}

class BloodRequest extends Equatable {
  const BloodRequest({
    required this.id,
    required this.authorName,
    required this.isMine,
    required this.bloodType,
    required this.bagsNeeded,
    required this.bagsCollected,
    required this.onTheWayCount,
    required this.hospitalName,
    required this.urgency,
    required this.status,
    required this.isVerified,
    required this.createdAt,
    this.governorate,
    this.district,
    this.deadline,
    this.notes,
    this.contactPhone,
    this.myPledge,
    this.hospitalId,
    this.hospitalLocation,
    this.selfReportedDonatedCount = 0,
    this.governorateId,
    this.districtId,
    this.districtIds,
    this.districts = const [],
  });
  final int id, bagsNeeded, bagsCollected, onTheWayCount;
  final String authorName, bloodType, hospitalName;
  final bool isMine, isVerified;
  final Urgency urgency;
  final RequestStatus status;
  final LocalizedName? governorate, district;
  final String? governorateId, districtId;
  final List<String>? districtIds;
  final List<LocalizedName> districts;
  final DateTime? deadline;
  final DateTime createdAt;
  final String? notes;

  /// Only present for the author and for donors with an active pledge.
  final String? contactPhone;
  final PledgeStatus? myPledge;

  /// Set when the hospital was picked from the directory; null for old
  /// requests and hospitals typed by hand.
  final int? hospitalId;
  final HospitalLocation? hospitalLocation;

  /// Donors who said they donated. Their own statement, not verified, and
  /// never added to [bagsCollected] automatically.
  final int selfReportedDonatedCount;

  bool get hasContact => contactPhone != null;

  /// The requester's own count reached the number needed.
  bool get isCovered => bagsCollected >= bagsNeeded;

  @override
  List<Object?> get props => [
    id,
    authorName,
    isMine,
    bloodType,
    bagsNeeded,
    bagsCollected,
    onTheWayCount,
    hospitalName,
    urgency,
    status,
    isVerified,
    createdAt,
    governorate,
    district,
    deadline,
    notes,
    contactPhone,
    myPledge,
    hospitalId,
    hospitalLocation,
    selfReportedDonatedCount,
    governorateId,
    districtId,
    districtIds,
    districts,
  ];
}

class BloodRequestDraft extends Equatable {
  const BloodRequestDraft({
    required this.bloodType,
    required this.bagsNeeded,
    required this.hospitalName,
    required this.governorateId,
    this.districtId,
    this.districtIds,
    required this.urgency,
    required this.contactPhone,
    this.hospitalId,
    this.deadline,
    this.notes = '',
  });
  final String bloodType, hospitalName, governorateId, contactPhone;
  final String? districtId;
  final List<String>? districtIds;
  final String notes;
  final int? hospitalId;
  final int bagsNeeded;
  final Urgency urgency;
  final DateTime? deadline;
  @override
  List<Object?> get props => [
    bloodType,
    bagsNeeded,
    hospitalName,
    governorateId,
    districtId,
    districtIds,
    urgency,
    contactPhone,
    hospitalId,
    deadline,
    notes,
  ];
}

enum RequestFilter {
  all('all'),
  urgent('urgent'),
  myBlood('my_blood'),
  nearby('nearby');

  const RequestFilter(this.api);
  final String api;
}

enum RequestTab {
  all('all'),
  active('active'),
  completed('completed'),
  cancelled('cancelled');

  const RequestTab(this.api);
  final String api;
}
