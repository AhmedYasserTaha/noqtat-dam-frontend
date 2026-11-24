import 'package:equatable/equatable.dart';

import 'blood_request.dart';

/// One donor's pledge on the author's request. No phone number: the author
/// already has the contact they entered, donors keep theirs private.
class DonorPledge extends Equatable {
  const DonorPledge({
    required this.donorId,
    required this.donorName,
    required this.bloodType,
    required this.status,
    required this.updatedAt,
    this.confirmed = false,
  });
  final int donorId;
  final String donorName, bloodType;
  final PledgeStatus status;
  final DateTime updatedAt;

  /// The requester confirmed this donation. Without it, a `donated` status is
  /// only the donor's own statement.
  final bool confirmed;

  bool get canConfirm =>
      !confirmed &&
      (status == PledgeStatus.donated || status == PledgeStatus.onTheWay);

  @override
  List<Object?> get props => [
    donorId,
    donorName,
    bloodType,
    status,
    updatedAt,
    confirmed,
  ];
}

/// The requester's explicit answer when confirming a donor: is this donor
/// already part of the count they typed, or should confirming add one bag.
enum CountMode {
  add('add'),
  alreadyCounted('already_counted');

  const CountMode(this.api);
  final String api;
}
