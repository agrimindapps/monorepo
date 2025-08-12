// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/widgets/dialog_cadastro_widget.dart';
import '../../../models/12_consulta_model.dart';
import 'views/consulta_form_view.dart';

/// Main entry point for consulta cadastro
/// Supports both dialog and full-screen modes
Future<bool?> consultaCadastro(BuildContext context, Consulta? consulta,
    {bool fullScreen = false}) async {
  if (fullScreen) {
    // Full-screen navigation
    final result = await Get.to(() => ConsultaFormView(
          consulta: consulta,
          mode: ConsultaFormMode.fullScreen,
        ));
    return result == true;
  } else {
    // Dialog mode
    return DialogCadastro.show(
      context: context,
      title: consulta == null ? 'Nova Consulta' : 'Editar Consulta',
      formKey: GlobalKey(),
      maxHeight: 600,
      onSubmit: () async {
        // The dialog will handle submission through the embedded form
        return true;
      },
      formWidget: (key) => ConsultaFormView(
        consulta: consulta,
        mode: ConsultaFormMode.dialog,
        dialogKey: key,
      ),
    );
  }
}

/// Legacy support - redirect to new implementation
@Deprecated('Use consultaCadastro instead')
Future<bool?> consultaCadastroDialog(BuildContext context, Consulta? consulta) {
  return consultaCadastro(context, consulta, fullScreen: false);
}
