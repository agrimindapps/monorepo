// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../router.dart';

List<Map<String, dynamic>> itensMenuBottom = [
  {
    'label': 'Defensivos',
    'icon': FontAwesome.plate_wheat_solid,
    'page': AppRoutes.defensivosHome,
  },
  {
    'label': 'Pragas',
    'icon': FontAwesome.bugs_solid,
    'page': AppRoutes.pragasHome,
  },
  {
    'label': 'Favoritos',
    'icon': FontAwesome.heart_solid,
    'page': AppRoutes.favoritos,
  },
  {
    'label': 'Comentários',
    'icon': FontAwesome.comment_solid,
    'page': AppRoutes.comentarios,
  },
  {
    'label': 'Outros',
    'icon': FontAwesome.gears_solid,
    'page': AppRoutes.config,
  },
];
