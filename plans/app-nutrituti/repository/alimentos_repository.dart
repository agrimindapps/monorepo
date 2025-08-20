// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../core/services/localstorage_service.dart';
import 'database.dart';

class AlimentosRepository {
  static final AlimentosRepository _singleton = AlimentosRepository._internal();
  factory AlimentosRepository() {
    return _singleton;
  }

  AlimentosRepository._internal();

  /** Classe começa Aqui */
  RxList<dynamic> listaAlimentos = <Map<String, dynamic>>[].obs;
  RxList<dynamic> listaAlimentosFiltrados = [].obs;
  RxBool isLoading = false.obs;

  List<Map<String, dynamic>> getCategorias() {
    return [
      {
        'title': 'Todos os alimentos',
        'icon': FontAwesome.cheese_solid,
      },
      {
        'title': 'Alimentos preparados',
        'icon': FontAwesome.utensils_solid,
      },
      {
        'title': 'Bebidas (alcoólicas e não alcoólicas)',
        'icon': FontAwesome.bottle_water_solid
      },
      {
        'title': 'Carnes e derivados',
        'icon': Icons.egg_outlined,
      },
      {
        'title': 'Cereais e derivados',
        'icon': Icons.crop_rounded,
      },
      {
        'title': 'Frutas e derivados',
        'icon': FontAwesome.apple_brand,
      },
      {
        'title': 'Gorduras e óleos',
        'icon': FontAwesome.oil_can_solid,
      },
      {
        'title': 'Leguminosas e derivados',
        'icon': FontAwesome.seedling_solid,
      },
      {
        'title': 'Leite e derivados',
        'icon': FontAwesome.cow_solid,
      },
      {
        'title': 'Miscelâneas',
        'icon': FontAwesome.candy_cane_solid,
      },
      {
        'title': 'Nozes e sementes',
        'icon': FontAwesome.seedling_solid,
      },
      {
        'title': 'Outros alimentos industrializados',
        'icon': FontAwesome.candy_cane_solid,
      },
      {
        'title': 'Ovos e derivados',
        'icon': Icons.egg_outlined,
      },
      {
        'title': 'Pescados e frutos do mar',
        'icon': FontAwesome.fish_solid,
      },
      {
        'title': 'Produtos açucarados',
        'icon': FontAwesome.candy_cane_solid,
      },
      {
        'title': 'Verduras, hortaliças e derivados',
        'icon': FontAwesome.carrot_solid
      },
    ];
  }

  List<dynamic> getAlimentosProperties() {
    return [
      {'value': 'energia_kcal', 'text': 'Energia', 'med': 'Kcal'},
      {'value': 'proteina_g', 'text': 'Proteina', 'med': 'g'},
      {'value': 'lipideos_g', 'text': 'Lipideos', 'med': 'g'},
      {'value': 'colesterol_mg', 'text': 'Colesterol', 'med': 'mg'},
      {'value': 'carboidrato_g', 'text': 'Carboidrato', 'med': 'g'},
      {'value': 'fibra_alimentar_g', 'text': 'Fibra', 'med': 'g'},
      {'value': 'cinzas_g', 'text': 'Cinzas', 'med': 'g'},
      {'value': 'calcio_mg', 'text': 'Calcio', 'med': 'mg'},
      {'value': 'magnesio_mg', 'text': 'Magnesio', 'med': 'mg'},
      {'value': 'manganes_mg', 'text': 'Manganes', 'med': 'mg'},
      {'value': 'fosforo_mg', 'text': 'Fosforo', 'med': 'mg'},
      {'value': 'ferro_mg', 'text': 'Ferro', 'med': 'mg'},
      {'value': 'sodio_mg', 'text': 'Sodio', 'med': 'mg'},
      {'value': 'potassio_mg', 'text': 'Potassio', 'med': 'mg'},
      {'value': 'cobre_mg', 'text': 'Cobre', 'med': 'mg'},
      {'value': 'zinco_mg', 'text': 'Zinco', 'med': 'mg'},
      {'value': 'retinol_ug', 'text': 'Retinol', 'med': 'ug'},
      {'value': 're_ug', 'text': 'RE', 'med': 'ug'},
      {'value': 'rae_ug', 'text': 'RAE', 'med': 'ug'},
      {'value': 'tiamina_mg', 'text': 'Tiamina', 'med': 'mg'},
      {'value': 'riboflavina_mg', 'text': 'Riboflavina', 'med': 'mg'},
      {'value': 'piridoxina_mg', 'text': 'Piridoxina', 'med': 'mg'},
      {'value': 'niacina_mg', 'text': 'Niacina', 'med': 'mg'},
      {'value': 'c_mg', 'text': 'Vitamina C', 'med': 'mg'},
      {'value': 'energia_kj', 'text': 'Energia', 'med': 'Kj'},
      {'value': 'umidade', 'text': 'Umidade', 'med': '%'},
    ];
  }

  Future<List<dynamic>> loadAlimentos(String categoria) async {
    try {
      Supabase ins = Supabase.instance;
      final response = await ins.client
          .from('app1_alimentos')
          .select()
          .eq('categoria', categoria);

      List<String> favoritos = await localStorage.getFavorites('favoritos');
      List<dynamic> alimentos = response as List<dynamic>;

      for (var row in alimentos) {
        // Verificar todas as chaves do array
        row.forEach((key, value) {
          if (value == '-1') {
            row[key] = 'N/A';
          }
        });

        row['visible'] = false;
        row['favorito'] = favoritos.contains(row['IdReg'].toString());
      }

      List<dynamic> orderAlimentos =
          DatabaseRepository().orderList(alimentos, 'descricao', '', false);

      return orderAlimentos;
    } catch (e) {
      return [];
    }
  }

  Future<bool> setFavorito(String id) async {
    return await localStorage.setFavorite('favoritos', id);
  }

  Future<bool> validFavorito(String id) async {
    return await localStorage.isFavorite('favoritos', id);
  }

  List<Map<String, dynamic>> getFavoritos() {
    return [];
  }

  void compartilhar(Map<String, dynamic> selectItem, double sliderValue) {
    List<dynamic> propriedades = getAlimentosProperties();

    String text = '${selectItem['descricao']} $sliderValue Gr\n\n';
    for (var x = 0; x < propriedades.length; x++) {
      Map<String, dynamic> item = propriedades[x];
      text += '${item['text']}: ${selectItem[item['value']]} ${item['med']}\n';
    }

    Share.share(text);
  }
}
