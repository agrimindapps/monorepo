import 'package:core/core.dart' show GetIt;
import '../di_module.dart';

/// Authentication module following SOLID principles
///
/// Follows SRP: Single responsibility of auth services registration
/// Follows DIP: Depends on abstractions via DIModule interface
class AuthModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
  }
}
