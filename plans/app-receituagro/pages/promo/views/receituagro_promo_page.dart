// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../promo_page/faq_section.dart';
import '../../promo_page/features_section.dart';
import '../../promo_page/footer_section.dart';
import '../../promo_page/hero_section.dart';
import '../../promo_page/stats_section.dart';
import '../../promo_page/testimonials_section.dart';
import '../controller/promo_page_controller.dart';

class ReceituagroPromoPage extends StatelessWidget {
  const ReceituagroPromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<PromoPageController>(
      builder: (controller) {
        return Scaffold(
          appBar: _buildAppBar(controller),
          extendBodyBehindAppBar: true,
          body: _buildBody(controller),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(PromoPageController controller) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton(
            onPressed: controller.navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Entrar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(PromoPageController controller) {
    if (controller.state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      controller: controller.scrollController,
      child: const Column(
        children: [
          HeroSection(),
          FeaturesSection(),
          StatsSection(),
          TestimonialsSection(),
          FaqSection(),
          FooterSection(),
        ],
      ),
    );
  }
}
