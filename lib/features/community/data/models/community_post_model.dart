import '../../domain/entities/community_post.dart';

CommunityPost communityPostFromJson(Map<String, dynamic> j) => CommunityPost(
  id: j['id'] as int,
  authorName: j['authorName'] as String? ?? '',
  text: j['text'] as String? ?? '',
  createdAt: DateTime.parse(j['createdAt'] as String),
  isMine: j['isMine'] as bool? ?? false,
  likes: j['likes'] as int? ?? 0,
  dislikes: j['dislikes'] as int? ?? 0,
  myReaction: PostReaction.fromApi(j['myReaction'] as String?),
);
