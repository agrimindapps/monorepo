import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';

class AnimalSelectorEmpty extends StatelessWidget {
  const AnimalSelectorEmpty({
    super.key,
    this.hintText,
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  final String? hintText;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nenhum pet cadastrado',
      button: false,
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 64),
                    child: DropdownButtonFormField<String>(
                      initialValue: null,
                      isDense: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.medium,
                          vertical: AppSpacing.xxlarge,
                        ),
                        border: InputBorder.none,
                        hintText: hintText ?? 'Selecione um pet',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: AppOpacity.disabled),
                          fontSize: AppFontSizes.medium,
                          fontWeight: AppFontWeights.regular,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: AppSpacing.medium),
                          child: Icon(
                            Icons.pets,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: AppOpacity.disabled),
                            size: AppSizes.iconM,
                          ),
                        ),
                      ),
                      items: const [],
                      onChanged: null,
                      isExpanded: true,
                      icon: Icon(
                        Icons.expand_more,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: AppOpacity.disabled),
                        size: AppSizes.iconM,
                      ),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: AppOpacity.disabled),
                        fontSize: AppFontSizes.medium,
                      ),
                      disabledHint: Text(
                        hintText ?? 'Nenhum pet cadastrado',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: AppOpacity.disabled),
                          fontSize: AppFontSizes.medium,
                          fontWeight: AppFontWeights.regular,
                        ),
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
