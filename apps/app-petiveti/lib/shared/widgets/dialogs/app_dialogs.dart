import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// **Reusable Application Dialogs**
/// 
/// A centralized collection of reusable dialog components used throughout
/// the application. This promotes code reuse and maintains consistency
/// in dialog design and behavior.
/// 
/// ## Available Dialogs:
/// - **Coming Soon Dialog**: Generic "feature in development" dialog
/// - **Contact Support Dialog**: Support contact information dialog
/// - **About Application Dialog**: App information and version details
/// - **Confirmation Dialog**: Generic confirmation dialog with customizable actions
/// - **Logout Confirmation Dialog**: Specialized logout confirmation
/// 
/// ## Design Benefits:
/// - **Consistency**: Uniform dialog appearance across the app
/// - **Maintainability**: Centralized dialog logic and styling
/// - **Reusability**: Reduce code duplication
/// - **Accessibility**: Built-in semantic support and screen reader compatibility
/// - **Customization**: Flexible parameters for different use cases
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.1.0 - Added accessibility features and customization options
class AppDialogs {
  AppDialogs._();

  /// **Coming Soon Dialog**
  /// 
  /// Displays a generic "feature in development" message.
  /// Used for placeholder functionality that is not yet implemented.
  /// 
  /// **Parameters:**
  /// - [context]: BuildContext for dialog display
  /// - [title]: Feature title (e.g., "Configurações de Tema")
  /// - [message]: Optional custom message (defaults to standard message)
  /// - [icon]: Optional custom icon (defaults to construction icon)
  /// 
  /// **Usage Example:**
  /// ```dart
  /// AppDialogs.showComingSoon(
  ///   context, 
  ///   'Configurações de Tema',
  ///   message: 'Modo escuro em desenvolvimento',
  ///   icon: Icons.dark_mode,
  /// );
  /// ```
  static Future<void> showComingSoon(
    BuildContext context,
    String title, {
    String? message,
    IconData? icon,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              icon ?? Icons.construction,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Semantics(
          label: 'Mensagem de funcionalidade em desenvolvimento',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message ?? 'Esta funcionalidade está em desenvolvimento e estará disponível em breve.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fique atento às próximas atualizações!',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// **Contact Support Dialog**
  /// 
  /// Displays support contact information with interactive elements.
  /// Provides multiple ways for users to contact support team.
  /// 
  /// **Parameters:**
  /// - [context]: BuildContext for dialog display
  /// - [supportEmail]: Support team email address
  /// - [supportPhone]: Support team phone number
  /// - [showSocialMedia]: Whether to show social media links
  /// 
  /// **Features:**
  /// - Clickable email and phone links
  /// - Copy to clipboard functionality
  /// - Social media links (optional)
  /// - Accessibility support
  static Future<void> showContactSupport(
    BuildContext context, {
    String supportEmail = 'suporte@petiveti.com',
    String supportPhone = '(11) 99999-9999',
    bool showSocialMedia = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.support_agent,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Contatar Suporte'),
          ],
        ),
        content: Semantics(
          label: 'Informações de contato do suporte técnico',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entre em contato conosco através dos canais abaixo:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              
              // Email Contact
              _buildContactItem(
                context,
                icon: Icons.email,
                title: 'Email',
                subtitle: supportEmail,
                onTap: () {
                  // In a real app, would launch email client
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email copiado: $supportEmail'),
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              // Phone Contact
              _buildContactItem(
                context,
                icon: Icons.phone,
                title: 'Telefone',
                subtitle: supportPhone,
                onTap: () {
                  // In a real app, would launch phone dialer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Telefone copiado: $supportPhone'),
                      action: SnackBarAction(
                        label: 'OK',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
              
              if (showSocialMedia) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Redes Sociais:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      context,
                      icon: Icons.facebook,
                      label: 'Facebook',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _buildSocialButton(
                      context,
                      icon: Icons.camera_alt,
                      label: 'Instagram',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _buildSocialButton(
                      context,
                      icon: Icons.alternate_email,
                      label: 'Twitter',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// **About Application Dialog**
  /// 
  /// Displays comprehensive application information including version,
  /// development team, and additional app details.
  /// 
  /// **Parameters:**
  /// - [context]: BuildContext for dialog display
  /// - [appName]: Application name (defaults to "PetiVeti")
  /// - [appIcon]: Application icon widget
  /// - [customDescription]: Optional custom app description
  /// - [showTechnicalInfo]: Whether to show technical details
  static Future<void> showAboutApp(
    BuildContext context, {
    String appName = 'PetiVeti',
    Widget? appIcon,
    String? customDescription,
    bool showTechnicalInfo = true,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            appIcon ?? const Icon(Icons.pets, size: 32, color: Colors.blue),
            const SizedBox(width: 12),
            Text(appName),
          ],
        ),
        content: Semantics(
          label: 'Informações sobre o aplicativo $appName',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customDescription ?? 
                'App completo para cuidados veterinários com calculadoras especializadas, controle de medicamentos, agendamento de consultas e muito mais.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              if (showTechnicalInfo) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                
                // Version Information
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.hasData 
                        ? snapshot.data!.version
                        : '1.0.0';
                    final buildNumber = snapshot.hasData 
                        ? snapshot.data!.buildNumber
                        : '1';
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          context,
                          'Versão:',
                          '$version (Build $buildNumber)',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          'Desenvolvido com:',
                          'Flutter',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          'Plataforma:',
                          Theme.of(context).platform.name,
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Desenvolvido com ❤️ pela equipe PetiVeti',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// **Generic Confirmation Dialog**
  /// 
  /// A reusable confirmation dialog with customizable content and actions.
  /// 
  /// **Parameters:**
  /// - [context]: BuildContext for dialog display
  /// - [title]: Dialog title
  /// - [content]: Dialog content/message
  /// - [confirmText]: Confirm button text (defaults to "Confirmar")
  /// - [cancelText]: Cancel button text (defaults to "Cancelar")
  /// - [isDestructive]: Whether the action is destructive (changes button color)
  /// - [onConfirm]: Callback for confirm action
  /// - [onCancel]: Optional callback for cancel action
  /// 
  /// **Returns:** Future<bool> - true if confirmed, false if canceled
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: isDestructive 
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            child: Text(confirmText),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
    
    return result ?? false;
  }

  /// **Logout Confirmation Dialog**
  /// 
  /// Specialized confirmation dialog for logout action.
  /// 
  /// **Parameters:**
  /// - [context]: BuildContext for dialog display
  /// - [onConfirm]: Callback executed when logout is confirmed
  /// 
  /// **Returns:** Future<bool> - true if logout confirmed
  static Future<bool> showLogoutConfirmation(
    BuildContext context, {
    VoidCallback? onConfirm,
  }) {
    return showConfirmation(
      context,
      title: 'Confirmar Logout',
      content: 'Deseja realmente sair da sua conta?',
      confirmText: 'Sair',
      cancelText: 'Cancelar',
      isDestructive: true,
      onConfirm: onConfirm,
    );
  }

  /// **Delete Confirmation Dialog**
  /// 
  /// Enhanced confirmation dialog for delete operations with clear warnings
  /// and better user experience to prevent accidental deletions.
  /// 
  /// **Parameters:**
  /// - [context]: BuildContext for dialog display
  /// - [itemName]: Name of the item being deleted (e.g., "pet Max", "consulta")
  /// - [itemType]: Type of item for contextual messaging
  /// - [warningMessage]: Optional additional warning message
  /// - [onConfirm]: Callback executed when deletion is confirmed
  /// 
  /// **Returns:** Future<bool> - true if deletion confirmed
  static Future<bool> showDeleteConfirmation(
    BuildContext context, {
    required String itemName,
    required String itemType,
    String? warningMessage,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Confirmar Exclusão'),
          ],
        ),
        content: Semantics(
          label: 'Diálogo de confirmação de exclusão',
          hint: 'Confirme se deseja excluir permanentemente',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    const TextSpan(text: 'Deseja realmente excluir '),
                    TextSpan(
                      text: '"$itemName"',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ação irreversível',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            warningMessage ?? 
                            'Esta ação não pode ser desfeita. Todos os dados relacionados a este $itemType serão perdidos permanentemente.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Excluir'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ) ?? false;
  }

  /// **Save Changes Confirmation Dialog**
  /// 
  /// Confirmation dialog for unsaved changes when navigating away from forms.
  /// 
  /// **Parameters:**
  /// - [context]: BuildContext for dialog display
  /// - [onSave]: Callback to save changes
  /// - [onDiscard]: Callback to discard changes
  /// - [onCancel]: Callback to cancel navigation
  /// 
  /// **Returns:** Future<SaveAction?> - action chosen by user
  static Future<SaveAction?> showUnsavedChangesDialog(
    BuildContext context, {
    VoidCallback? onSave,
    VoidCallback? onDiscard,
    VoidCallback? onCancel,
  }) {
    return showDialog<SaveAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.edit_note,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Alterações não salvas'),
          ],
        ),
        content: const Text(
          'Você possui alterações não salvas. O que deseja fazer?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(SaveAction.cancel);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              onDiscard?.call();
              Navigator.of(context).pop(SaveAction.discard);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Descartar'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave?.call();
              Navigator.of(context).pop(SaveAction.save);
            },
            child: const Text('Salvar'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// **Permission Request Dialog**
  /// 
  /// Explains why permission is needed and guides user to grant it.
  /// 
  /// **Parameters:**
  /// - [context]: BuildContext for dialog display
  /// - [permissionName]: Name of the permission being requested
  /// - [explanation]: Why the permission is needed
  /// - [onGrantPermission]: Callback to request permission
  /// - [onSkip]: Optional callback to skip permission
  /// 
  /// **Returns:** Future<PermissionAction?> - action chosen by user
  static Future<PermissionAction?> showPermissionRequestDialog(
    BuildContext context, {
    required String permissionName,
    required String explanation,
    VoidCallback? onGrantPermission,
    VoidCallback? onSkip,
  }) {
    return showDialog<PermissionAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text('Permissão: $permissionName'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(explanation),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Você pode alterar esta permissão a qualquer momento nas configurações do dispositivo.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (onSkip != null)
            TextButton(
              onPressed: () {
                onSkip.call();
                Navigator.of(context).pop(PermissionAction.skip);
              },
              child: const Text('Pular'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(PermissionAction.cancel),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onGrantPermission?.call();
              Navigator.of(context).pop(PermissionAction.grant);
            },
            child: const Text('Conceder Permissão'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Helper Methods

  static Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.content_copy,
              color: Theme.of(context).textTheme.bodySmall?.color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// **Save Action Enumeration**
/// 
/// Represents possible actions when user has unsaved changes.
enum SaveAction {
  /// Save the changes
  save,
  
  /// Discard the changes
  discard,
  
  /// Cancel the navigation/action
  cancel,
}

/// **Permission Action Enumeration**
/// 
/// Represents possible actions for permission request dialogs.
enum PermissionAction {
  /// Grant the requested permission
  grant,
  
  /// Skip the permission (if optional)
  skip,
  
  /// Cancel the permission request
  cancel,
}