import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entity.dart';
import 'section_header_widget.dart';
import 'info_tile_widget.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserProfileEntity profile;

  const ProfileInfoSection({
    super.key,
    required this.profile,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não informado';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeaderWidget(title: 'Informações'),
        InfoTileWidget(
          icon: Icons.person_outline,
          label: 'Nome',
          value: profile.displayName ?? 'Não informado',
        ),
        InfoTileWidget(
          icon: Icons.email_outlined,
          label: 'Email',
          value: profile.email ?? 'Não informado',
        ),
        InfoTileWidget(
          icon: Icons.phone_outlined,
          label: 'Telefone',
          value: profile.phoneNumber ?? 'Não informado',
        ),
        InfoTileWidget(
          icon: Icons.calendar_today_outlined,
          label: 'Membro desde',
          value: _formatDate(profile.createdAt),
        ),
      ],
    );
  }
}
