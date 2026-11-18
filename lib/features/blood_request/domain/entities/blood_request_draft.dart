import 'package:equatable/equatable.dart';

class BloodRequestDraft extends Equatable {
  const BloodRequestDraft({
    required this.bloodType,
    required this.bagsNeeded,
    required this.hospitalName,
    required this.governorate,
    required this.city,
    required this.urgency,
    required this.deadline,
    required this.contactPhone,
    this.notes = '',
  });
  final String bloodType,
      hospitalName,
      governorate,
      city,
      urgency,
      contactPhone,
      notes;
  final int bagsNeeded;
  final DateTime deadline;
  @override
  List<Object?> get props => [
    bloodType,
    bagsNeeded,
    hospitalName,
    governorate,
    city,
    urgency,
    deadline,
    contactPhone,
    notes,
  ];
}
