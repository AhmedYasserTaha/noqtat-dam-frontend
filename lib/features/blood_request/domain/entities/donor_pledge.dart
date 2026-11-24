import 'package:equatable/equatable.dart';

import 'blood_request.dart';

/// One donor's pledge on the author's request. No phone number: the author
/// already has the contact they entered, donors keep theirs private.
/// A pledge is only the donor's own statement. It never changes the count of
/// bags: the requester sets that number by hand.
class DonorPledge extends Equatable {
  const DonorPledge({
    required this.donorName,
    required this.bloodType,
    required this.status,
    required this.updatedAt,
  });
  final String donorName, bloodType;
  final PledgeStatus status;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [donorName, bloodType, status, updatedAt];
}
