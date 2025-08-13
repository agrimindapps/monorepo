// Flutter imports:
import 'package:flutter/material.dart';

class CustomTabBarScrollPhysics extends ScrollPhysics {
  const CustomTabBarScrollPhysics({super.parent});

  @override
  CustomTabBarScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomTabBarScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1.0,
      );
}
