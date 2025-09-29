import 'package:flutter/material.dart';

/// Settings Section Widget
/// 
/// Groups related settings together with a title and icon
class SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isExpanded;

  const SettingsSection({
    super.key,
    required title,
    required icon,
    required children,
    isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return _buildExpandedSection(context);
    } else {
      return _buildCollapsibleSection(context);
    }
  }

  Widget _buildExpandedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 8),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: _buildChildrenWithDividers(),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleSection(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: _buildChildrenWithDividers(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      
      // Add divider between items (except after the last item)
      if (i < children.length - 1) {
        widgets.add(const Divider(height: 1));
      }
    }
    
    return widgets;
  }
}