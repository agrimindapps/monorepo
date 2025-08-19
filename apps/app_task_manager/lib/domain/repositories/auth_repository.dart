import '../../core/utils/typedef.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  ResultFuture<UserEntity> signInWithEmailPassword(String email, String password);
  
  ResultFuture<UserEntity> signUpWithEmailPassword(String email, String password, String name);
  
  ResultFuture<void> signOut();
  
  ResultFuture<UserEntity?> getCurrentUser();
  
  ResultFuture<void> resetPassword(String email);
  
  ResultFuture<void> updateProfile(UserEntity user);
  
  Stream<UserEntity?> watchAuthState();
  
  ResultFuture<bool> isSignedIn();
}