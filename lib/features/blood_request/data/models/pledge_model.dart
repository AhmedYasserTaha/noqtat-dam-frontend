import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/model_dates.dart';
import '../../domain/entities/pledge.dart';

class PledgeModel extends Pledge {
  const PledgeModel({
    required super.donorId,
    required super.donorName,
    required super.status,
    required super.createdAt,
  });
  factory PledgeModel.fromMap(Map<String, dynamic> map) => PledgeModel(
    donorId: map['donorId'] as String,
    donorName: map['donorName'] as String,
    status: map['status'] as String,
    createdAt: readDate(map['createdAt']),
  );
  Map<String, dynamic> toMap() => {
    'donorId': donorId,
    'donorName': donorName,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
