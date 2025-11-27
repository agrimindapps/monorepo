import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/notifiers/notifiers.dart';
import 'account/account_widgets.dart';

/// Account section widget that composes account-related cards.
class AccountSectionWidget extends ConsumerWidget {
  const AccountSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Column(
      children: [
        if (authState.isLoading)
          const AccountLoadingCard()
        else if (isAuthenticated)
          AccountAuthenticatedCard(
            user: user,
            isAnonymous: isAnonymous,
            isPremium: isPremium,
          )
        else
          AccountUnauthenticatedCard(authState: authState),
        const SizedBox(height: 16),
        AccountPremiumCard(isPremium: isPremium),
      ],
    );
  }
}
