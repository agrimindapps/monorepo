import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../auth/presentation/notifiers/notifiers.dart';
import '../widgets/account_deletion/deletion_confirmation_section.dart';
import '../widgets/account_deletion/deletion_consequences_section.dart';
import '../widgets/account_deletion/deletion_contact_section.dart';
import '../widgets/account_deletion/deletion_footer_section.dart';
import '../widgets/account_deletion/deletion_header_section.dart';
import '../widgets/account_deletion/deletion_intro_section.dart';
import '../widgets/account_deletion/deletion_navigation_menu.dart';
import '../widgets/account_deletion/deletion_password_dialog.dart';
import '../widgets/account_deletion/deletion_process_section.dart';
import '../widgets/account_deletion/deletion_third_party_section.dart';
import '../widgets/account_deletion/deletion_what_deleted_section.dart';

class AccountDeletionPage extends ConsumerStatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  ConsumerState<AccountDeletionPage> createState() =>
      _AccountDeletionPageState();
}

class _AccountDeletionPageState extends ConsumerState<AccountDeletionPage> {
  final scrollController = ScrollController();
  bool _isDeleting = false;
  bool _confirmationChecked = false;

  final GlobalKey _introSection = GlobalKey();
  final GlobalKey _whatDeletedSection = GlobalKey();
  final GlobalKey _consequencesSection = GlobalKey();
  final GlobalKey _thirdPartySection = GlobalKey();
  final GlobalKey _processSection = GlobalKey();
  final GlobalKey _confirmationSection = GlobalKey();
  final GlobalKey _contactSection = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSectionSelected(String section) {
    switch (section) {
      case 'intro':
        _scrollToSection(_introSection);
      case 'what_deleted':
        _scrollToSection(_whatDeletedSection);
      case 'consequences':
        _scrollToSection(_consequencesSection);
      case 'third_party':
        _scrollToSection(_thirdPartySection);
      case 'process':
        _scrollToSection(_processSection);
      case 'confirmation':
        _scrollToSection(_confirmationSection);
      case 'contact':
        _scrollToSection(_contactSection);
    }
  }

  Future<void> _handleAccountDeletion() async {
    if (!_confirmationChecked || _isDeleting) return;

    final authState = ref.read(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    String? currentPassword;
    if (authState.isAuthenticated && !authState.isAnonymous) {
      currentPassword = await _showPasswordDialog();
      if (currentPassword == null || currentPassword.isEmpty) {
        return;
      }
    }
    final confirmed = await showDialog<bool>(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmação Final'),
          ],
        ),
        content: const Text(
          'Esta ação não pode ser desfeita. Todos os seus dados serão permanentemente deletados em até 30 dias.\n\nDeseja realmente prosseguir com a exclusão da conta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar Exclusão'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await authNotifier.deleteAccount(currentPassword: currentPassword);
      final errorMessage = ref.read(authProvider).errorMessage;
      if (errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Conta deletada com sucesso. Você será redirecionado para a tela inicial.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar conta: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          DeletionPasswordDialog(controller: passwordController),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DeletionHeaderSection(),
                DeletionIntroSection(key: _introSection),
                DeletionWhatDeletedSection(key: _whatDeletedSection),
                DeletionConsequencesSection(key: _consequencesSection),
                DeletionThirdPartySection(key: _thirdPartySection),
                DeletionProcessSection(key: _processSection),
                DeletionConfirmationSection(
                  key: _confirmationSection,
                  confirmationChecked: _confirmationChecked,
                  isDeleting: _isDeleting,
                  onConfirmationChanged: (value) {
                    setState(() {
                      _confirmationChecked = value ?? false;
                    });
                  },
                  onDeletePressed: _handleAccountDeletion,
                ),
                DeletionContactSection(key: _contactSection),
                const DeletionFooterSection(),
              ],
            ),
          ),
          DeletionNavigationMenu(onSectionSelected: _handleSectionSelected),
        ],
      ),
    );
  }
}
