import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Content container for settings page with all sections
class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsAccountSection(),
        SizedBox(height: 24),
        SettingsAppearanceSection(),
        SizedBox(height: 24),
        SettingsNotificationSection(),
        SizedBox(height: 24),
        SettingsDevelopmentSection(),
        SizedBox(height: 24),
        SettingsSupportSection(),
        SizedBox(height: 24),
        SettingsInformationSection(),
      ],
    );
  }
}

/// Reusable settings section widget
class SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: GasometerDesignTokens.spacingMd),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 1,
          ),
          Padding(
            padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings item with title, subtitle, and optional trailing widget
class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final IconData? leadingIcon;

  const SettingsItem({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
      child: Padding(
        padding: GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingMd),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: GasometerDesignTokens.spacingMd),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// Placeholder sections - to be replaced with actual implementations
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsSection(
      title: 'Conta',
      icon: Icons.account_circle,
      children: [
        SettingsItem(
          title: 'Perfil',
          subtitle: 'Gerenciar informações da conta',
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class SettingsAppearanceSection extends StatelessWidget {
  const SettingsAppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsSection(
      title: 'Aparência',
      icon: Icons.palette,
      children: [
        SettingsItem(
          title: 'Tema',
          subtitle: 'Claro, escuro ou automático',
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class SettingsNotificationSection extends StatelessWidget {
  const SettingsNotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsSection(
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        SettingsItem(
          title: 'Push Notifications',
          subtitle: 'Receber alertas e lembretes',
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class SettingsDevelopmentSection extends StatelessWidget {
  const SettingsDevelopmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsSection(
      title: 'Desenvolvimento',
      icon: Icons.code,
      children: [
        SettingsItem(
          title: 'Modo Debug',
          subtitle: 'Ferramentas para desenvolvedores',
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class SettingsSupportSection extends StatelessWidget {
  const SettingsSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsSection(
      title: 'Suporte',
      icon: Icons.help,
      children: [
        SettingsItem(
          title: 'Ajuda',
          subtitle: 'FAQ e documentação',
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class SettingsInformationSection extends StatelessWidget {
  const SettingsInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsSection(
      title: 'Informações',
      icon: Icons.info,
      children: [
        SettingsItem(
          title: 'Versão do App',
          subtitle: '1.0.0',
        ),
      ],
    );
  }
}