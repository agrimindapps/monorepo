// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import '../../repository/alimentos_repository.dart';
import '../alimentos_page.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  CategoriesSectionState createState() => CategoriesSectionState();
}

class CategoriesSectionState extends State<CategoriesSection> {
  List<Map<String, dynamic>> categorias = [];
  int? hoveredIndex;

  @override
  void initState() {
    super.initState();
    getCategorias();
  }

  void getCategorias() {
    categorias = AlimentosRepository().getCategorias();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Categorias',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),
        categorias.isEmpty ? semRegistros() : gridViewCategoria(categorias),
      ],
    );
  }

  Widget gridViewCategoria(List<Map<String, dynamic>> categorias) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 2;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return StaggeredGrid.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: List.generate(
        categorias.length,
        (index) => StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredIndex = index),
            onExit: (_) => setState(() => hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(
                  hoveredIndex == index ? 1.05 : 1.0,
                ),
              child: Card(
                elevation: hoveredIndex == index ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  splashColor: Colors.green.withValues(alpha: 0.3),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AlimentosPage(
                          categoria: categorias[index]['title'],
                          onlyFavorites: false,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          categorias[index]['icon'],
                          color: Colors.green,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          categorias[index]['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (categorias[index]['description'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            categorias[index]['description'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget semRegistros() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma categoria encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
