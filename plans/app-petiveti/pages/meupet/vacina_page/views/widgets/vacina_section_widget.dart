// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../models/16_vacina_model.dart';
import '../../controllers/vacina_page_controller.dart';
import '../styles/vacina_constants.dart';
import 'vacina_card_widget.dart';

/// A reusable widget for displaying a section of vaccines with a title.
/// 
/// This widget groups vaccines under a common title and provides consistent
/// styling for vaccine sections. It supports custom background colors for
/// different vaccine categories (overdue, upcoming, etc.).
/// 
/// Features:
/// - Customizable title and background color
/// - Optimized list rendering
/// - Support for empty states
/// - Consistent spacing and styling
/// - Action delegation to parent widgets
class VacinaSectionWidget extends StatelessWidget {
  final String title;
  final List<VacinaVet> vacinas;
  final Color? backgroundColor;
  final VacinaPageController controller;
  final Function(VacinaVet)? onVacinaEdit;
  final Function(VacinaVet)? onVacinaDelete;
  final bool showActions;
  final Widget? emptyWidget;

  const VacinaSectionWidget({
    super.key,
    required this.title,
    required this.vacinas,
    required this.controller,
    this.backgroundColor,
    this.onVacinaEdit,
    this.onVacinaDelete,
    this.showActions = true,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Don't render if empty and no empty widget provided
    if (vacinas.isEmpty && emptyWidget == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(VacinaConstants.espacamentoPadrao),
      child: Card(
        color: backgroundColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VacinaConstants.bordaCircularPadrao),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  /// Builds the section header with title and count.
  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(VacinaConstants.espacamentoPadrao),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (vacinas.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(VacinaConstants.bordaCircularContador),
              ),
              child: Text(
                '${vacinas.length}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the main content area.
  Widget _buildContent(BuildContext context) {
    if (vacinas.isEmpty) {
      return emptyWidget ?? const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: VacinaConstants.espacamentoPadrao,
        right: VacinaConstants.espacamentoPadrao,
        bottom: VacinaConstants.espacamentoPadrao,
      ),
      itemCount: vacinas.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: VacinaConstants.espacamentoPadrao / 2,
      ),
      itemBuilder: (context, index) {
        final vacina = vacinas[index];
        return VacinaCardWidget(
          key: ValueKey('section_vacina_${vacina.id}'),
          vacina: vacina,
          controller: controller,
          showActions: showActions,
          onEdit: onVacinaEdit != null ? () => onVacinaEdit!(vacina) : null,
          onDelete: onVacinaDelete != null ? () => onVacinaDelete!(vacina) : null,
        );
      },
    );
  }
}

/// A specialized section widget for overdue vaccines.
class VacinasAtrasadasSection extends StatelessWidget {
  final List<VacinaVet> vacinasAtrasadas;
  final VacinaPageController controller;
  final Function(VacinaVet)? onVacinaEdit;
  final Function(VacinaVet)? onVacinaDelete;

  const VacinasAtrasadasSection({
    super.key,
    required this.vacinasAtrasadas,
    required this.controller,
    this.onVacinaEdit,
    this.onVacinaDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (vacinasAtrasadas.isEmpty) {
      return const SizedBox.shrink();
    }

    return VacinaSectionWidget(
      title: 'Vacinas Atrasadas',
      vacinas: vacinasAtrasadas,
      controller: controller,
      backgroundColor: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
      onVacinaEdit: onVacinaEdit,
      onVacinaDelete: onVacinaDelete,
    );
  }
}

/// A specialized section widget for upcoming vaccines.
class ProximasVacinasSection extends StatelessWidget {
  final List<VacinaVet> vacinasProximas;
  final VacinaPageController controller;
  final Function(VacinaVet)? onVacinaEdit;
  final Function(VacinaVet)? onVacinaDelete;

  const ProximasVacinasSection({
    super.key,
    required this.vacinasProximas,
    required this.controller,
    this.onVacinaEdit,
    this.onVacinaDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (vacinasProximas.isEmpty) {
      return const SizedBox.shrink();
    }

    return VacinaSectionWidget(
      title: 'Próximas Vacinas',
      vacinas: vacinasProximas,
      controller: controller,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      onVacinaEdit: onVacinaEdit,
      onVacinaDelete: onVacinaDelete,
    );
  }
}
