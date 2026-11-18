import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this.store);
  final FirebaseFirestore store;
  Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String uid) =>
      store.doc(FirestorePaths.user(uid)).snapshots();
  Future<void> save(String uid, Map<String, dynamic> data) =>
      store.doc(FirestorePaths.user(uid)).set(data, SetOptions(merge: true));
}
