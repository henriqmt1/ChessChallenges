import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/player_progress.dart';

final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  if (Firebase.apps.isEmpty) {
    return null;
  }

  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore?>((ref) {
  if (Firebase.apps.isEmpty) {
    return null;
  }

  return FirebaseFirestore.instance;
});

final remotePlayerProgressRepositoryProvider =
    Provider<RemotePlayerProgressRepository>((ref) {
      return RemotePlayerProgressRepository(
        auth: ref.watch(firebaseAuthProvider),
        firestore: ref.watch(firebaseFirestoreProvider),
      );
    });

class RemotePlayerProgressRepository {
  const RemotePlayerProgressRepository({
    required FirebaseAuth? auth,
    required FirebaseFirestore? firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  Future<PlayerProgress?> load() async {
    try {
      final user = await _ensureUser();
      final firestore = _firestore;
      if (user == null || firestore == null) {
        return null;
      }

      final snapshot = await _progressDocument(
        firestore: firestore,
        userId: user.uid,
      ).get();
      final data = snapshot.data();
      if (data == null) {
        return null;
      }

      return PlayerProgress.fromJson(data);
    } on Object {
      return null;
    }
  }

  Future<bool> save(PlayerProgress progress) async {
    try {
      final user = await _ensureUser();
      final firestore = _firestore;
      if (user == null || firestore == null) {
        return false;
      }

      final now = DateTime.now();
      final data = progress.markSynced(now).toJson()
        ..['serverUpdatedAt'] = FieldValue.serverTimestamp();

      await _progressDocument(
        firestore: firestore,
        userId: user.uid,
      ).set(data, SetOptions(merge: true));

      return true;
    } on Object {
      return false;
    }
  }

  Future<User?> _ensureUser() async {
    final auth = _auth;
    if (auth == null) {
      return null;
    }

    final currentUser = auth.currentUser;
    if (currentUser != null) {
      return currentUser;
    }

    final credential = await auth.signInAnonymously();
    return credential.user;
  }

  DocumentReference<Map<String, dynamic>> _progressDocument({
    required FirebaseFirestore firestore,
    required String userId,
  }) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('main');
  }
}
