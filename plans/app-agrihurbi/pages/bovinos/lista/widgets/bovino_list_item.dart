// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/services/info_device_service.dart';
import '../../../../models/bovino_class.dart';

class BovinoListItem extends StatelessWidget {
  final BovinoClass bovino;
  final Function(String) onTap;

  const BovinoListItem({
    super.key,
    required this.bovino,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
      leading: _buildLeadingAvatar(context),
      title: Text(bovino.nomeComum),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(bovino.tipoAnimal),
          if (!InfoDeviceService().isProduction.value)
            Text(bovino.status ? 'Ativo' : 'Inativo'),
        ],
      ),
      onTap: () => onTap(bovino.id),
    );
  }

  Widget _buildLeadingAvatar(BuildContext context) {
    if (bovino.miniatura == null || bovino.miniatura!.isEmpty) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.pets, color: Colors.white),
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(bovino.miniatura!),
    );
  }
}
