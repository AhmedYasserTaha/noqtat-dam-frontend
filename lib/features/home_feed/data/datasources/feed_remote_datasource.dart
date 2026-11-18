import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/post_page.dart';

class FeedRemoteDataSource {
  FeedRemoteDataSource(this.store);
  final FirebaseFirestore store;
  Stream<QuerySnapshot<Map<String, dynamic>>> watch({
    PostCursor? after,
    int limit = 20,
  }) {
    var query = store
        .collection(FirestorePaths.posts)
        .orderBy('createdAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(limit);
    if (after != null) {
      query = query.startAfter([Timestamp.fromDate(after.createdAt), after.id]);
    }
    return query.snapshots();
  }
}
