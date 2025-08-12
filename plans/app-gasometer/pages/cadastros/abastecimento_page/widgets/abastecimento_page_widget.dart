// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../views/abastecimento_page_view.dart';

class AbastecimentoPage extends StatefulWidget {
  const AbastecimentoPage({super.key});

  @override
  AbastecimentoPageWidgetState createState() => AbastecimentoPageWidgetState();
}

class AbastecimentoPageWidgetState extends State<AbastecimentoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const AbastecimentoPageView();
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
