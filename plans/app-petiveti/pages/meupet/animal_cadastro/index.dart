// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/widgets/dialog_cadastro_widget.dart';
import '../../../models/11_animal_model.dart';
import 'views/animal_form_view.dart';

Future<bool?> animalCadastro(BuildContext context, Animal? animal) {
  final formWidgetKey = GlobalKey<AnimalFormViewState>();

  return DialogCadastro.show(
    context: context,
    title: 'Animal',
    formKey: formWidgetKey,
    maxHeight: 700,
    onSubmit: () async {
      final success = await formWidgetKey.currentState?.submitForm();
      if (success == true && context.mounted) {
        Navigator.of(context).pop(true);
      }
    },
    formWidget: (key) => AnimalFormView(
      key: key,
      animal: animal,
    ),
  );
}
