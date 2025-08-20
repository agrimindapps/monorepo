// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/services/info_device_service.dart';

class ImplementoListItem extends StatelessWidget {
  final dynamic implemento;
  final Function(String) onTap;

  const ImplementoListItem({
    super.key,
    required this.implemento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
      leading: implemento.miniatura.isEmpty
          ? CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.fire_truck_sharp, color: Colors.white),
            )
          : CircleAvatar(
              backgroundImage: NetworkImage(implemento.miniatura),
            ),
      title: Text(implemento.descricao),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(implemento.marca ?? ''),
          if (!InfoDeviceService().isProduction.value)
            Text(implemento.status ? 'Ativo' : 'Inativo'),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
      onTap: () => onTap(implemento.idReg),
    );
  }
}
