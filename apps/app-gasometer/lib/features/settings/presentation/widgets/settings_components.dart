import 'package:flutter/material.dart';

/// 🏗️ REFACTORED COMPONENTS: Extracted from SettingsPage monolith
/// 
/// Reusable components for settings UI with consistent styling
/// and behavior across the application.

/// 🎯 Standard settings section with consistent styling
class SettingsSection extends StatelessWidget {

  const SettingsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.padding,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ],
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }
}

/// 🎯 Settings item with switch control
class SettingsSwitchItem extends StatelessWidget {

  const SettingsSwitchItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.enabled = true,
  });
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      hint: subtitle,
      onTap: enabled ? () => onChanged(!value) : null,
      child: ListTile(
        leading: icon != null 
          ? Icon(icon, color: Theme.of(context).colorScheme.primary)
          : null,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
        enabled: enabled,
        onTap: enabled ? () => onChanged(!value) : null,
      ),
    );
  }
}

/// 🎯 Settings item with navigation arrow
class SettingsNavigationItem extends StatelessWidget {

  const SettingsNavigationItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.icon,
    this.trailing,
    this.enabled = true,
  });
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      hint: subtitle,
      onTap: enabled ? onTap : null,
      child: ListTile(
        leading: icon != null 
          ? Icon(icon, color: Theme.of(context).colorScheme.primary)
          : null,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

/// 🎯 Settings item for actions (like buttons)
class SettingsActionItem extends StatelessWidget {

  const SettingsActionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.icon,
    this.actionColor,
    this.enabled = true,
    this.showWarning = false,
  });
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? actionColor;
  final bool enabled;
  final bool showWarning;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = actionColor ?? 
      (showWarning ? Colors.orange : Theme.of(context).colorScheme.primary);

    return Semantics(
      label: title,
      hint: subtitle,
      onTap: enabled ? onTap : null,
      child: ListTile(
        leading: icon != null 
          ? Icon(icon, color: effectiveColor)
          : null,
        title: Text(
          title,
          style: TextStyle(
            color: enabled ? effectiveColor : Theme.of(context).disabledColor,
          ),
        ),
        subtitle: subtitle != null 
          ? Text(
              subtitle!,
              style: TextStyle(
                color: enabled 
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : Theme.of(context).disabledColor,
              ),
            ) 
          : null,
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

/// 🎯 Settings card with custom content
class SettingsCard extends StatelessWidget {

  const SettingsCard({
    super.key,
    this.title,
    required this.child,
    this.margin,
    this.padding,
    this.backgroundColor,
  });
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// 🎯 Theme selection widget
class ThemeSelector extends StatelessWidget {

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'Tema do Aplicativo',
      child: Column(
        children: [
          _ThemeOption(
            title: 'Claro',
            subtitle: 'Interface sempre clara',
            icon: Icons.wb_sunny,
            value: ThemeMode.light,
            currentValue: currentTheme,
            onChanged: onThemeChanged,
          ),
          _ThemeOption(
            title: 'Escuro',
            subtitle: 'Interface sempre escura',
            icon: Icons.nights_stay,
            value: ThemeMode.dark,
            currentValue: currentTheme,
            onChanged: onThemeChanged,
          ),
          _ThemeOption(
            title: 'Sistema',
            subtitle: 'Segue as configurações do sistema',
            icon: Icons.phone_android,
            value: ThemeMode.system,
            currentValue: currentTheme,
            onChanged: onThemeChanged,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.currentValue,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode currentValue;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == currentValue;
    
    return Semantics(
      label: title,
      hint: subtitle,
      selected: isSelected,
      onTap: () => onChanged(value),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}