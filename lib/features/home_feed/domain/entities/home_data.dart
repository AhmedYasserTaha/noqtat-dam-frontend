import 'package:equatable/equatable.dart';

import '../../../blood_request/domain/entities/blood_request.dart';

/// What the readiness card shows. All values are what the user entered about
/// themselves; the app does not judge medical eligibility.
class Readiness extends Equatable {
  const Readiness({
    required this.isAvailable,
    required this.donationsCount,
    this.lastDonationAt,
  });
  final bool isAvailable;
  final int donationsCount;
  final DateTime? lastDonationAt;
  @override
  List<Object?> get props => [isAvailable, donationsCount, lastDonationAt];
}

class CommunityPost extends Equatable {
  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });
  final int id;
  final String authorName, text;
  final DateTime createdAt;
  @override
  List<Object?> get props => [id, authorName, text, createdAt];
}

class HomeData extends Equatable {
  const HomeData({
    required this.readiness,
    required this.posts,
    this.closestUrgent,
  });
  final Readiness readiness;
  final BloodRequest? closestUrgent;
  final List<CommunityPost> posts;
  @override
  List<Object?> get props => [readiness, closestUrgent, posts];
}

class FeedQuery extends Equatable {
  const FeedQuery({
    this.filter = RequestFilter.all,
    this.governorateId,
    this.districtId,
  });
  final RequestFilter filter;
  final String? governorateId, districtId;
  @override
  List<Object?> get props => [filter, governorateId, districtId];
}
