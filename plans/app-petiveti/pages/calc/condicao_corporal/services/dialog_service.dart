// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../widgets/info_dialog.dart';

class DialogService {
  static void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InfoDialog.condicaoCorporal(context);
      },
    );
  }
}
