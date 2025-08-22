import 'dart:async';
import 'package:hive/hive.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userBoxName = 'auth_user';
  static const String _userKey = 'current_user';
  static const String _signedInKey = 'is_signed_in';
  
  Box<UserModel>? _userBox;
  Box<bool>? _authBox;

  Future<Box<UserModel>> get _getUserBox async {
    _userBox ??= await Hive.openBox<UserModel>(_userBoxName);
    return _userBox!;
  }

  Future<Box<bool>> get _getAuthBox async {
    _authBox ??= await Hive.openBox<bool>('auth_status');
    return _authBox!;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final box = await _getUserBox;
    await box.put(_userKey, user);
    await setSignedInStatus(true);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final box = await _getUserBox;
    return box.get(_userKey);
  }

  @override
  Future<void> clearCache() async {
    final userBox = await _getUserBox;
    final authBox = await _getAuthBox;
    
    await userBox.clear();
    await authBox.clear();
  }

  @override
  Future<bool> isUserSignedIn() async {
    final box = await _getAuthBox;
    return box.get(_signedInKey, defaultValue: false) ?? false;
  }

  @override
  Future<void> setSignedInStatus(bool isSignedIn) async {
    final box = await _getAuthBox;
    await box.put(_signedInKey, isSignedIn);
  }

  Future<void> dispose() async {
    await _userBox?.close();
    await _authBox?.close();
  }
}