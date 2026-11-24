import 'package:equatable/equatable.dart';

import '../../../blood_request/domain/entities/blood_request.dart';
import '../../../community/domain/entities/community_post.dart';

export '../../../community/domain/entities/community_post.dart';

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

class HomeData extends Equatable {
  const HomeData({
    required this.readiness,
    required this.posts,
    this.closestUrgent,
    this.unreadNotifications = 0,
  });
  final Readiness readiness;
  final BloodRequest? closestUrgent;
  final List<CommunityPost> posts;
  final int unreadNotifications;
  @override
  List<Object?> get props => [
    readiness,
    closestUrgent,
    posts,
    unreadNotifications,
  ];
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

/// One page of a list plus the cursor for the next page (null = no more).
class PagedList<T> extends Equatable {
  const PagedList(this.items, this.next);
  final List<T> items;
  final String? next;
  @override
  List<Object?> get props => [items, next];
}

class FeedPageParams extends Equatable {
  const FeedPageParams(this.query, {this.cursor});
  final FeedQuery query;
  final String? cursor;
  @override
  List<Object?> get props => [query, cursor];
}
