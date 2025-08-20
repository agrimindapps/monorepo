// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../constants/design_tokens.dart';
import '../models/11_animal_model.dart';
import '../utils/animation_utils.dart';

/// A reusable card widget for displaying animal information
class AnimalCardWidget extends StatelessWidget {
  final Animal animal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLoading;
  final int? animationIndex;

  const AnimalCardWidget({
    super.key,
    required this.animal,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
    this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onEdit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildCardContent(theme),
          ),
        ),
      ),
    );

    // Add staggered animation if index is provided
    if (animationIndex != null) {
      cardContent = AnimationUtils.staggeredListItem(
        index: animationIndex!,
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildCardContent(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            _buildAvatar(theme),
            Spacing.h16,
            Expanded(child: _buildAnimalInfo(theme)),
            if (!isLoading) _buildActions(theme),
            if (isLoading) _buildLoadingIndicator(),
          ],
        ),
        const SizedBox(height: 6),
        _buildAnimalDetails(theme),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: animal.foto != null
          ? ClipOval(
              child: Image.network(
                animal.foto!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(theme),
              ),
            )
          : _buildAvatarFallback(theme),
    );
  }

  Widget _buildAvatarFallback(ThemeData theme) {
    return const Icon(
      Icons.pets,
      color: Colors.white,
      size: 28,
    );
  }

  Widget _buildAnimalInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animal name
        Text(
          animal.nome,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Animal breed with icon
        Row(
          children: [
            Icon(
              Icons.pets_outlined,
              size: 16,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                animal.raca,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimalDetails(ThemeData theme) {
    final age = _calculateAge();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDetailItem(
              icon: Icons.cake_outlined,
              label: 'Idade',
              value: age,
              theme: theme,
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildDetailItem(
              icon: Icons.calendar_today_outlined,
              label: 'Nascimento',
              value: _formatBirthDate(),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          onPressed: onEdit,
          tooltip: 'Editar animal',
          theme: theme,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: Icons.delete_outline,
          onPressed: onDelete,
          tooltip: 'Excluir animal',
          theme: theme,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDestructive 
              ? Colors.red.shade50
              : theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDestructive 
                ? Colors.red.shade200
                : theme.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDestructive 
              ? Colors.red.shade600
              : theme.primaryColor,
          ),
        ),
      ),
    );
  }

  String _calculateAge() {
    try {
      final birthDate = DateTime.fromMillisecondsSinceEpoch(animal.dataNascimento);
      final now = DateTime.now();
      final difference = now.difference(birthDate);
      
      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();
      
      if (years > 0) {
        return years == 1 ? '1 ano' : '$years anos';
      } else if (months > 0) {
        return months == 1 ? '1 mês' : '$months meses';
      } else {
        final days = difference.inDays;
        return days == 1 ? '1 dia' : '$days dias';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 80,
      child: Center(
        child: AnimatedLoadingIndicator(
          size: DesignTokens.iconM,
        ),
      ),
    );
  }

  String _formatBirthDate() {
    try {
      final birthDate = DateTime.fromMillisecondsSinceEpoch(animal.dataNascimento);
      return DateFormat('dd/MM/yy').format(birthDate);
    } catch (e) {
      return 'N/A';
    }
  }
}

/// Animated version of AnimalCardWidget with entrance animation
class AnimatedAnimalCard extends StatefulWidget {
  final Animal animal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLoading;
  final Duration delay;

  const AnimatedAnimalCard({
    super.key,
    required this.animal,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedAnimalCard> createState() => _AnimatedAnimalCardState();
}

class _AnimatedAnimalCardState extends State<AnimatedAnimalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationNormal,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveDecelerate,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveStandard,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: AnimalCardWidget(
              animal: widget.animal,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
              isLoading: widget.isLoading,
            ),
          ),
        );
      },
    );
  }
}
