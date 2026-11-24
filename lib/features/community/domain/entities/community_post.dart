import 'package:equatable/equatable.dart';

enum PostReaction {
  like('like'),
  dislike('dislike');

  const PostReaction(this.api);
  final String api;
  static PostReaction? fromApi(String? v) {
    for (final r in values) {
      if (r.api == v) return r;
    }
    return null;
  }
}

/// Why a user reports a blood request or a post. Sent as-is to the backend.
enum ReportReason {
  spam('spam'),
  fake('fake'),
  abusive('abusive'),
  sensitiveInfo('sensitive_info'),
  other('other');

  const ReportReason(this.api);
  final String api;
}

enum ReportTarget { request, post }

/// A normal community post (not a blood request).
class CommunityPost extends Equatable {
  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.text,
    required this.createdAt,
    this.isMine = false,
    this.likes = 0,
    this.dislikes = 0,
    this.myReaction,
  });
  final int id, likes, dislikes;
  final String authorName, text;
  final bool isMine;
  final DateTime createdAt;
  final PostReaction? myReaction;

  /// What the counts look like after the user picks [next] (null clears it).
  /// Used for the optimistic update; the server answer replaces it.
  CommunityPost withReaction(PostReaction? next) {
    var l = likes, d = dislikes;
    if (myReaction == PostReaction.like) l--;
    if (myReaction == PostReaction.dislike) d--;
    if (next == PostReaction.like) l++;
    if (next == PostReaction.dislike) d++;
    return CommunityPost(
      id: id,
      authorName: authorName,
      text: text,
      createdAt: createdAt,
      isMine: isMine,
      likes: l,
      dislikes: d,
      myReaction: next,
    );
  }

  @override
  List<Object?> get props => [
    id,
    authorName,
    text,
    createdAt,
    isMine,
    likes,
    dislikes,
    myReaction,
  ];
}
