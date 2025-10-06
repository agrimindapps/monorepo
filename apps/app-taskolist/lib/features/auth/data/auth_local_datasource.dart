import 'user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  
  Future<UserModel?> getCachedUser();
  
  Future<void> clearCache();
  
  Future<bool> isUserSignedIn();
  
  Future<void> setSignedInStatus(bool isSignedIn);
}
