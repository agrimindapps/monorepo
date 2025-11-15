import 'dart:async';
import 'package:core/core.dart';

import '../../../database/daos/user_dao.dart';
import '../../../database/taskolist_database.dart';
import 'auth_local_datasource.dart';
import 'user_model.dart';

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TaskolistDatabase _database;
  late final UserDao _userDao;
  
  bool _isSignedIn = false;

  AuthLocalDataSourceImpl(this._database) {
    _userDao = _database.userDao;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await _userDao.cacheUser(user);
    await setSignedInStatus(true);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return await _userDao.getCachedUser();
  }

  @override
  Future<void> clearCache() async {
    await _userDao.clearCache();
    await setSignedInStatus(false);
  }

  @override
  Future<bool> isUserSignedIn() async {
    return _isSignedIn;
  }

  @override
  Future<void> setSignedInStatus(bool isSignedIn) async {
    _isSignedIn = isSignedIn;
  }

  Future<void> dispose() async {
    // No resources to dispose in Drift
  }
}
