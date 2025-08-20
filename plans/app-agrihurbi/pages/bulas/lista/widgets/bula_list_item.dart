// Flutter imports:
import 'package:flutter/material.dart';

class BulaListItem extends StatelessWidget {
  final dynamic bula;
  final Function(String) onTap;

  const BulaListItem({
    super.key,
    required this.bula,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.medical_information, color: Colors.white),
      ),
      title: Text(bula.descricao),
      subtitle: Text(bula.fabricante ?? ''),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
      onTap: () => onTap(bula.idReg),
    );
  }
}
