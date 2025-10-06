import 'package:flutter/material.dart';

/// Settings Tile Widget
/// 
/// Provides different types of settings tiles for configuration options
class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  /// Switch tile for boolean settings
  factory SettingsTile.switchTile({
    required String title,
    String? subtitle,
    Widget? leading,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool enabled = true,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      enabled: enabled,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled && onChanged != null ? () => onChanged(!value) : null,
    );
  }

  /// Dropdown tile for selection settings
  static SettingsTile dropdown<T>({
    required String title,
    String? subtitle,
    Widget? leading,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    bool enabled = true,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      enabled: enabled,
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        underline: const SizedBox(),
        isDense: true,
      ),
    );
  }

  /// Slider tile for numeric settings
  static SettingsTile slider({
    required String title,
    String? subtitle,
    Widget? leading,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double>? onChanged,
    bool enabled = true,
    String Function(double)? valueFormatter,
  }) {
    return _SliderSettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: enabled ? onChanged : null,
      enabled: enabled,
      valueFormatter: valueFormatter,
    );
  }

  /// Navigation tile for navigating to other screens
  static SettingsTile navigation({
    required String title,
    String? subtitle,
    Widget? leading,
    required VoidCallback? onTap,
    bool enabled = true,
    bool showArrow = true,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      enabled: enabled,
      trailing: showArrow ? const Icon(Icons.chevron_right) : null,
      onTap: enabled ? onTap : null,
    );
  }

  /// Info tile for displaying read-only information
  static SettingsTile info({
    required String title,
    required String subtitle,
    Widget? leading,
    bool enabled = true,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            )
          : null,
      leading: leading,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }
}

/// Slider Settings Tile Implementation
class _SliderSettingsTile extends SettingsTile {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String Function(double)? valueFormatter;

  const _SliderSettingsTile({
    required super.title,
    super.subtitle,
    super.leading,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    super.enabled,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: enabled ? null : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                )
              : null,
          leading: leading,
          trailing: Text(
            valueFormatter?.call(value) ?? value.toStringAsFixed(1),
            style: TextStyle(
              color: enabled ? Theme.of(context).primaryColor : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}
