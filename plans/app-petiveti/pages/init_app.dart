// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'mobile_page.dart';

/// Widget simples que apenas renderiza MobilePageMain
/// Convertido de StatefulWidget para StatelessWidget pois não usa estado local
class VetHomePage extends StatelessWidget {
  const VetHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MobilePageMain(),
    );
  }
}
