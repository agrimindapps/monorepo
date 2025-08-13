// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../models/sobre_model.dart';

class ContatoListWidget extends StatelessWidget {
  final List<ContatoModel> contatos;
  final bool isDark;
  final Function(ContatoModel) onContatoTap;

  const ContatoListWidget({
    super.key,
    required this.contatos,
    required this.isDark,
    required this.onContatoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: contatos.map((contato) => _buildContatoTile(contato)).toList(),
      ),
    );
  }

  Widget _buildContatoTile(ContatoModel contato) {
    return ListTile(
      leading: _getIconForContato(contato.iconType),
      title: Text(
        contato.titulo,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      onTap: () => onContatoTap(contato),
    );
  }

  Icon _getIconForContato(String iconType) {
    Color iconColor = isDark ? Colors.white70 : Colors.black54;
    
    switch (iconType) {
      case 'email':
        return Icon(FontAwesome.envelope, color: iconColor);
      case 'facebook':
        return Icon(FontAwesome.facebook_brand, color: iconColor);
      case 'instagram':
        return Icon(FontAwesome.instagram_brand, color: iconColor);
      default:
        return Icon(Icons.contact_mail, color: iconColor);
    }
  }
}
