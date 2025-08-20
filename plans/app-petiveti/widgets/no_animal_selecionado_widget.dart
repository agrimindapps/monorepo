// Flutter imports:
import 'package:flutter/material.dart';

class NoAnimalSelecionadoWidget extends StatefulWidget {
  const NoAnimalSelecionadoWidget({super.key});

  @override
  State<NoAnimalSelecionadoWidget> createState() =>
      _NoAnimalSelecionadoWidgetState();
}

class _NoAnimalSelecionadoWidgetState extends State<NoAnimalSelecionadoWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface.withValues(alpha: 0.5)
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets_outlined,
                color: isDark 
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : Colors.black54,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Para começar, selecione um animal ou cadastre um novo no menu de animais.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w500,
                color: isDark 
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
