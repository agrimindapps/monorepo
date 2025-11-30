import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

abstract class IProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String userId);
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<void> deleteProfile(String userId);
}

class ProfileRemoteDataSource implements IProfileRemoteDataSource {

  ProfileRemoteDataSource({required this.firestore});
  final FirebaseFirestore firestore;

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw ServerException();
    }

    return UserProfileModel.fromJson(doc.data()!);
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    await firestore.collection('users').doc(profile.id).set(
          profile.toJson(),
          SetOptions(merge: true),
        );

    return profile;
  }

  @override
  Future<void> deleteProfile(String userId) async {
    await firestore.collection('users').doc(userId).delete();
  }
}

class ServerException implements Exception {}
