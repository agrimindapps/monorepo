// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../models/praga_item.dart';
import 'carousel_widget.dart';
import 'section_title.dart';

class SuggestedSection extends StatelessWidget {
  final List<PragaItem> items;
  final bool isLoading;
  final CarouselSliderController carouselController;
  final Function(int) onPageChanged;
  final Function(int) onDotTap;
  final Function(String) onItemTap;
  final int currentIndex;

  const SuggestedSection({
    super.key,
    required this.items,
    required this.isLoading,
    required this.carouselController,
    required this.onPageChanged,
    required this.onDotTap,
    required this.onItemTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Sugestões',
          icon: FontAwesome.lightbulb_solid,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: _buildSuggestedCard(),
        ),
      ],
    );
  }

  Widget _buildSuggestedCard() {
    return Card(
      elevation: 0, // Removida elevação do card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Mantém o raio, mas sem borda
        side: BorderSide.none, // Remove a borda
      ),
      child: _buildCardContent(),
    );
  }

  static const Widget _loadingWidget = SizedBox(
    height: 200,
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _buildCardContent() {
    if (isLoading) {
      return _loadingWidget;
    }

    return CarouselWidget(
      items: items,
      carouselController: carouselController,
      onPageChanged: onPageChanged,
      onDotTap: onDotTap,
      onItemTap: onItemTap,
      currentIndex: currentIndex,
    );
  }
}
