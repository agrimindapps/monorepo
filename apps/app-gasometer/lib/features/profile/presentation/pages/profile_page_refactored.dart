import 'package:core/core.dart'
    show ConsumerStatefulWidget, ConsumerState;
import 'package:flutter/material.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/services/account_service.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_sections_widget.dart';

/// Página de perfil refatorada seguindo princípios SOLID
class ProfilePageRefactored extends ConsumerStatefulWidget {
  const ProfilePageRefactored({super.key});

  @override
  ConsumerState<ProfilePageRefactored> createState() =>
      _ProfilePageRefactoredState();
}

class _ProfilePageRefactoredState extends ConsumerState<ProfilePageRefactored> {
  final _scrollController = ScrollController();
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    // Initialization moved to didChangeDependencies to access ref
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeController();
  }

  void _initializeController() {
    final accountService = AccountServiceImpl();
    final imageService = ref.read(gasometerProfileImageServiceProvider);
    _profileController = ProfileController(accountService, imageService);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(isAnonymous: isAnonymous),
            Expanded(
              child: Semantics(
                label: 'Página de perfil do usuário',
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Padding(
                        padding: EdgeInsets.all(
                          GasometerDesignTokens.responsiveSpacing(context),
                        ),
                        child: ProfileSections(
                          user: user,
                          isAnonymous: isAnonymous,
                          profileController: _profileController,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
