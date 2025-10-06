import 'user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailPassword(String email, String password);
  
  Future<UserModel> signUpWithEmailPassword(String email, String password, String name);
  
  Future<void> signOut();
  
  Future<UserModel?> getCurrentUser();
  
  Future<void> resetPassword(String email);
  
  Future<void> updateProfile(UserModel user);
  
  Future<void> deleteAccount();
  
  Stream<UserModel?> watchAuthState();
}
