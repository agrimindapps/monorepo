// Flutter imports:
import 'package:flutter/material.dart';

/// Wrapper widget que adiciona animação aos widgets de favoritos
class AnimatedFavoritoWrapper extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedFavoritoWrapper({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
