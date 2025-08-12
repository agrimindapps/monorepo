// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../constants/abastecimento_strings.dart';
import '../controller/abastecimento_page_controller.dart';
import './abastecimento_item_widget.dart';
import './abastecimento_metrics_widget.dart';

class AbastecimentoCarouselWidget extends GetView<AbastecimentoPageController> {
  final List<DateTime> allMonths;

  const AbastecimentoCarouselWidget({super.key, required this.allMonths});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CarouselSlider(
            carouselController: controller.carouselController,
            options: CarouselOptions(
              height: constraints.maxHeight,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              autoPlay: false,
              onPageChanged: (index, reason) {
                controller.setCurrentCarouselIndex(index);
              },
            ),
            items: allMonths.map((date) {
              final hasData = controller.hasDataForDate(date);
              return Builder(
                builder: (BuildContext context) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Obx(() => controller.showHeader.value && hasData
                              ? AbastecimentoMetricsWidget(date: date)
                              : const SizedBox.shrink()),
                          if (!hasData)
                            _buildNoDataForMonth(month: date)
                          else
                            _buildAbastecimentosList(date),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildAbastecimentosList(DateTime date) {
    final abastecimentos = controller.getAbastecimentosForDate(date);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: abastecimentos.length,
      itemBuilder: (context, index) {
        final abastecimento = abastecimentos[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: AbastecimentoItemWidget(abastecimento: abastecimento),
        );
      },
    );
  }

  Widget _buildNoDataForMonth({DateTime? month}) {
    String monthLabel = month != null ? controller.formatMonthYear(month) : '';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            month != null
                ? '${AbastecimentoStrings.noRecordsForMonth} $monthLabel.'
                : AbastecimentoStrings.noRecordsForMonth,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
