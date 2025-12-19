import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfileEntity profile;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: profile.photoUrl != null
              ? NetworkImage(profile.photoUrl!)
              : null,
          child: profile.photoUrl == null
              ? Text(
                  profile.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 40),
                )
              : null,
        ),
        const SizedBox(height: 24),
        Text(
          profile.displayName ?? 'Usuário',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          profile.email ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
