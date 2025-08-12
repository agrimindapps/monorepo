// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';

/// Widget para exibir mensagem de "sem dados" para um mês
class NoDataForMonthWidget extends StatelessWidget {
  const NoDataForMonthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 220,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed_outlined,
              size: 48,
              color: ShadcnStyle.mutedTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro de odômetro neste mês',
              style: TextStyle(color: ShadcnStyle.mutedTextColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
