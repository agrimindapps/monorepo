import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

List<Map<String, dynamic>> itensMenuBottom = [
  {
    'label': 'Categorias',
    'icon': Icons.category,
    'page': '/categorias',
  },
  {
    'label': 'Termos',
    'icon': FontAwesome.tag_solid,
    'page': '/termos',
  },
  {
    'label': 'Favoritos',
    'icon': Icons.favorite_border,
    'page': '/favoritos',
  },
  // {
  //   'label': 'Quiz',
  //   'icon': Icons.question_answer,
  //   'page': '/games/home',
  // },
  // {
  //   'label': 'Ferramentas',
  //   'icon': Icons.build,
  //   'page': '/ferramentas',
  // },
  {
    'label': 'Comentários',
    'icon': Icons.comment,
    'page': '/comentarios',
  },
  {
    'label': 'Outros',
    'icon': Icons.settings,
    'page': '/config',
  },
];
