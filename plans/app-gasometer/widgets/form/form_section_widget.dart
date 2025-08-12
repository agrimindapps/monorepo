// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';
import 'section_header_widget.dart';

/// Widget reutilizável para criar seções de formulário com um cabeçalho e um card,
/// seguindo o padrão visual usado nos formulários de cadastro.
class FormSectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final EdgeInsetsGeometry contentPadding;

  const FormSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.contentPadding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(title: title, icon: icon),
        Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: ShadcnStyle.borderColor),
          ),
          child: Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
