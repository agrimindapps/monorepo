import 'package:flutter/material.dart';

import '../style/shadcn_style.dart';

class DialogCadastro {
  static Future<bool?> show<T>({
    required BuildContext context,
    required String title,
    required Widget Function(GlobalKey formKey) formWidget,
    required GlobalKey formKey,
    required Function() onSubmit,
    double? maxHeight = 570.0,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 12,
            vertical: isSmallScreen ? 16 : 18,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? 420.0 : 500.0,
              maxHeight: maxHeight ?? 570.0,
            ),
            child: AlertDialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              insetPadding: const EdgeInsets.all(0),
              titlePadding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                isSmallScreen ? 12 : 16,
                isSmallScreen ? 12 : 16,
                0,
              ),
              contentPadding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                0,
                isSmallScreen ? 12 : 16,
                0,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? 12 : 20,
                      0,
                      isSmallScreen ? 12 : 20,
                      5,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider()
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: formWidget(formKey),
                ),
              ),
              actionsPadding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 18,
                isSmallScreen ? 8 : 12,
                isSmallScreen ? 12 : 18,
                isSmallScreen ? 8 : 12,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: onSubmit,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
