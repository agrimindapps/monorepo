import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/receituagro_section.dart';
import '../widgets/plantis_section.dart';
import '../widgets/gasometer_section.dart';
import '../widgets/apps_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/footer_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _appsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          NavBar(
            onHomeTap: () => _scrollToSection(_homeKey),
            onAboutTap: () => _scrollToSection(_aboutKey),
            onAppsTap: () => _scrollToSection(_appsKey),
            onContactTap: () => _scrollToSection(_contactKey),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  HeroSection(
                    key: _homeKey,
                    onCtaTap: () => _scrollToSection(_appsKey),
                  ),
                  AboutSection(key: _aboutKey),
                  const ReceituAgroSection(),
                  const PlantisSection(),
                  const GasometerSection(),
                  AppsSection(key: _appsKey),
                  const TestimonialsSection(),
                  FooterSection(key: _contactKey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
