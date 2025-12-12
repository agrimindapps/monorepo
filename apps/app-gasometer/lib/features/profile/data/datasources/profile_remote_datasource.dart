import 'dart:io';

import 'package:core/core.dart';
import '../models/user_profile_model.dart';

abstract class IProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String userId);
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<String> uploadProfileImage(String userId, String imagePath);
  Future<void> deleteProfile(String userId);
}

class ProfileRemoteDataSource implements IProfileRemoteDataSource {

  ProfileRemoteDataSource({
    required this.firestore,
    required this.storageService,
  });
  final FirebaseFirestore firestore;
  final FirebaseStorageService storageService;

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

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    final result = await storageService.uploadFile(
      file: File(imagePath),
      path: 'users/$userId/profile_image.jpg',
    );
    
    return result.fold(
      (failure) => throw ServerException(),
      (url) => url,
    );
  }
}

class ServerException implements Exception {}
