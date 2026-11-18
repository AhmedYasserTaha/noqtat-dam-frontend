import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/model_dates.dart';

class CommentModel extends Equatable {
  const CommentModel({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });
  final String id, authorId, text;
  final DateTime createdAt;
  factory CommentModel.fromMap(Map<String, dynamic> m) => CommentModel(
    id: m['id'] as String,
    authorId: m['authorId'] as String,
    text: m['text'] as String,
    createdAt: readDate(m['createdAt']),
  );
  Map<String, dynamic> toMap() => {
    'authorId': authorId,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };
  @override
  List<Object?> get props => [id, authorId, text, createdAt];
}

class LikeModel extends Equatable {
  const LikeModel({required this.userId, required this.createdAt});
  final String userId;
  final DateTime createdAt;
  factory LikeModel.fromMap(Map<String, dynamic> m) => LikeModel(
    userId: m['userId'] as String,
    createdAt: readDate(m['createdAt']),
  );
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'createdAt': Timestamp.fromDate(createdAt),
  };
  @override
  List<Object?> get props => [userId, createdAt];
}
