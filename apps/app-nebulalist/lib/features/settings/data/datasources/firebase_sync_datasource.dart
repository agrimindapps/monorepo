import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/settings_model.dart';
import '../models/user_profile_model.dart';

abstract class FirebaseSyncDataSource {
  Future<void> syncSettings(SettingsModel settings);
  Future<void> syncUserProfile(UserProfileModel profile);
  Stream<SettingsModel?> watchSettings();
  Stream<UserProfileModel?> watchUserProfile();
  Future<SettingsModel?> getSettings();
  Future<UserProfileModel?> getUserProfile();
  Future<void> deleteUserData();
}

class FirebaseSyncDataSourceImpl implements FirebaseSyncDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseSyncDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final userId = _userId;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId);
  }

  @override
  Future<void> syncSettings(SettingsModel settings) async {
    final doc = _userDoc;
    if (doc == null) {
      throw Exception('User not authenticated');
    }

    await doc.set({
      'settings': settings.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> syncUserProfile(UserProfileModel profile) async {
    final doc = _userDoc;
    if (doc == null) {
      throw Exception('User not authenticated');
    }

    await doc.set({
      'profile': profile.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<SettingsModel?> watchSettings() {
    final doc = _userDoc;
    if (doc == null) {
      return Stream.value(null);
    }

    return doc.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null || !data.containsKey('settings')) return null;
      
      return SettingsModel.fromJson(
        data['settings'] as Map<String, dynamic>,
      );
    });
  }

  @override
  Stream<UserProfileModel?> watchUserProfile() {
    final doc = _userDoc;
    if (doc == null) {
      return Stream.value(null);
    }

    return doc.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null || !data.containsKey('profile')) return null;
      
      return UserProfileModel.fromJson(
        data['profile'] as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<SettingsModel?> getSettings() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.get();
    if (!snapshot.exists) return null;
    
    final data = snapshot.data();
    if (data == null || !data.containsKey('settings')) return null;
    
    return SettingsModel.fromJson(
      data['settings'] as Map<String, dynamic>,
    );
  }

  @override
  Future<UserProfileModel?> getUserProfile() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.get();
    if (!snapshot.exists) return null;
    
    final data = snapshot.data();
    if (data == null || !data.containsKey('profile')) return null;
    
    return UserProfileModel.fromJson(
      data['profile'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteUserData() async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.delete();
  }
}
