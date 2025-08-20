// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

// Project imports:
import '../../widgets/page_header_widget.dart';
import 'controllers/calculadoras_controller.dart';

class CalculadorasPage extends StatelessWidget {
  const CalculadorasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalculadorasController>(
      init: CalculadorasController(),
      builder: (controller) => _CalculadorasPageView(controller: controller),
    );
  }
}

class _CalculadorasPageView extends StatelessWidget {
  final CalculadorasController controller;
  
  const _CalculadorasPageView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columnCount = controller.getColumnCount(screenWidth);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 40,
                    child: Obx(() => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categorias.length,
                      itemBuilder: (context, index) {
                        final categoria = controller.categorias[index];
                        final isSelected = controller.currentCategory == categoria;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(categoria),
                            selected: isSelected,
                            onSelected: (selected) {
                              controller.setCategory(categoria);
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor:
                                Theme.of(context).primaryColor.withValues(alpha: 0.2),
                            checkmarkColor: Theme.of(context).primaryColor,
                            avatar: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                    size: 16,
                                  )
                                : null,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            elevation: isSelected ? 2 : 0,
                            shadowColor: isSelected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.3)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        );
                      },
                    )),
                  ),
                ),

                const SizedBox(height: 8),

                // Resultados da pesquisa
                Expanded(
                  child: Obx(() => controller.hasFilteredItems
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AlignedGridView.count(
                            crossAxisCount: columnCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            itemCount: controller.filteredItems.length,
                            itemBuilder: (context, index) {
                              final calculo = controller.filteredItems[index];
                              return CalculoCard(
                                calculo: calculo,
                                onTap: () => controller.navigateToCalculadora(calculo),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma calculadora encontrada',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tente outros termos ou categorias',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return const PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + 16),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: PageHeaderWidget(
            title: 'Calculadoras Veterinárias',
            subtitle: 'Ferramentas para auxiliar na medicina veterinária',
            icon: Icons.calculate,
            showBackButton: true,
          ),
        ),
      ),
    );
  }
}

class CalculoCard extends StatelessWidget {
  final CalculoInfo calculo;
  final VoidCallback? onTap;

  const CalculoCard({super.key, required this.calculo, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                calculo.color,
                calculo.color.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: calculo.color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decoração de fundo com ícone grande
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  calculo.icon,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        calculo.icon,
                        size: 48,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        calculo.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        calculo.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (calculo.isInDevelopment)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Em breve',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
