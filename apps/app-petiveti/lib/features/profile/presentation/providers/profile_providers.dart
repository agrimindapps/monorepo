import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/profile_actions_service.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileActionsService profileActionsService(ProfileActionsServiceRef ref) {
  return ProfileActionsService();
}
