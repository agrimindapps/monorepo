// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';

/// Widget reutilizável para checkboxes e switches nos formulários.
class SwitchFieldWidget extends StatefulWidget {
  final String label;
  final bool initialValue;
  final void Function(bool)? onChanged;
  final bool useSwitchInsteadOfCheckbox;

  const SwitchFieldWidget({
    super.key,
    required this.label,
    this.initialValue = false,
    this.onChanged,
    this.useSwitchInsteadOfCheckbox = true,
  });

  @override
  State<SwitchFieldWidget> createState() => _SwitchFieldWidgetState();
}

class _SwitchFieldWidgetState extends State<SwitchFieldWidget> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          widget.useSwitchInsteadOfCheckbox
              ? Switch(
                  value: _value,
                  onChanged: (value) {
                    setState(() => _value = value);
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  },
                  activeColor: ShadcnStyle.focusColor,
                )
              : Checkbox(
                  value: _value,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _value = value);
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                    }
                  },
                ),
        ],
      ),
    );
  }
}
