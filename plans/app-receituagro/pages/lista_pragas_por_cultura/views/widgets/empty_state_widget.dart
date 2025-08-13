// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../utils/praga_cultura_constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final bool isDark;

  const EmptyStateWidget({
    super.key,
    this.message = 'Nenhum resultado encontrado',
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(PragaCulturaConstants.largePadding),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesome.box_open_solid,
                size: 48,
                color: isDark ? Colors.grey.shade600 : const Color(0xFFAAAAAA),
              ),
              const SizedBox(height: PragaCulturaConstants.largeSpacing),
              Text(
                message,
                style: TextStyle(
                  fontSize: PragaCulturaConstants.largeTextSize,
                  color: isDark ? Colors.grey.shade400 : const Color(0xFF777777),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
