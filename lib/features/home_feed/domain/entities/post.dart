import 'package:equatable/equatable.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.type,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    this.bloodType,
    this.bagsNeeded,
    this.bagsCollected,
    this.hospitalName,
    this.governorate,
    this.city,
    this.urgency,
    this.deadline,
    this.notes,
    this.status,
    this.isVerified,
  });
  final String id;
  final String type;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final String? bloodType;
  final int? bagsNeeded;
  final int? bagsCollected;
  final String? hospitalName;
  final String? governorate;
  final String? city;
  final String? urgency;
  final DateTime? deadline;
  final String? notes;
  final String? status;
  final bool? isVerified;
  @override
  List<Object?> get props => [
    id,
    type,
    authorId,
    authorName,
    text,
    createdAt,
    likesCount,
    commentsCount,
    bloodType,
    bagsNeeded,
    bagsCollected,
    hospitalName,
    governorate,
    city,
    urgency,
    deadline,
    notes,
    status,
    isVerified,
  ];
}
