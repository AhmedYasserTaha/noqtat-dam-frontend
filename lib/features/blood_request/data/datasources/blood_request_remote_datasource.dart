import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_paths.dart';

class BloodRequestRemoteDataSource {
  BloodRequestRemoteDataSource(this.store, this.auth);
  final FirebaseFirestore store;
  final FirebaseAuth auth;
  Future<String> create(Map<String, dynamic> data, String phone) async {
    final user = auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'unauthenticated');
    final profile = await store.doc(FirestorePaths.user(user.uid)).get();
    final ref = store.collection(FirestorePaths.posts).doc();
    final batch = store.batch();
    batch.set(ref, {
      ...data,
      'authorId': user.uid,
      'authorName': profile.data()?['name'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(store.doc(FirestorePaths.contact(ref.id)), {
      'contactPhone': phone,
    });
    await batch.commit();
    return ref.id;
  }

  Future<void> pledge(String id) async {
    final user = auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'unauthenticated');
    final profile = await store.doc(FirestorePaths.user(user.uid)).get();
    await store.doc(FirestorePaths.pledge(id, user.uid)).set({
      'donorId': user.uid,
      'donorName': profile.data()?['name'] ?? '',
      'status': 'on_the_way',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
