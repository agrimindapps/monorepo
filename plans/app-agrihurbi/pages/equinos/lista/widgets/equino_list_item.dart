// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/services/info_device_service.dart';

class EquinoListItemWidget extends StatelessWidget {
  final dynamic equino;
  final Function(String) onTap;

  const EquinoListItemWidget({
    super.key,
    required this.equino,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
      leading: equino.miniatura.isEmpty
          ? CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.pets, color: Colors.white),
            )
          : CircleAvatar(
              backgroundImage: NetworkImage(equino.miniatura),
            ),
      title: Text(equino.nomeComum),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(equino.paisOrigem),
          if (!InfoDeviceService().isProduction.value)
            Text(equino.status ? 'Ativo' : 'Inativo'),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
      onTap: () => onTap(equino.idReg),
    );
  }
}
