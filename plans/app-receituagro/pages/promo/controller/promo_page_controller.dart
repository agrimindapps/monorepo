// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../login_page.dart';
import '../models/promo_page_model.dart';
import '../models/promo_page_state.dart';

class PromoPageController extends GetxController {
  final ScrollController scrollController = ScrollController();

  final Rx<PromoPageState> _state = const PromoPageState().obs;
  PromoPageState get state => _state.value;

  bool get hasPromoData => state.promoData.title.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
    _configureStatusBar();
    _setupScrollListener();
    _loadPromoData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _initializeTheme() {
    _updateState(state.copyWith(isDark: ThemeManager().isDark.value));
    ThemeManager().isDark.listen((value) {
      _updateState(state.copyWith(isDark: value));
    });
  }

  void _updateState(PromoPageState newState) {
    _state.value = newState;
  }

  void _configureStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      final isScrolling = scrollController.position.isScrollingNotifier.value;
      if (state.isScrolling != isScrolling) {
        _updateState(state.copyWith(isScrolling: isScrolling));
      }
    });
  }

  void _loadPromoData() {
    _updateState(state.copyWith(isLoading: true));

    const promoData = PromoPageModel(
      title: 'ReceituAgro',
      subtitle: 'Sua solução completa para agricultura',
      description: 'Sistema completo para gestão agrícola com receituário, pragas e defensivos',
      isLoading: false,
    );

    _updateState(state.copyWith(
      promoData: promoData,
      isLoading: false,
    ));
  }

  void navigateToLogin() {
    Get.to(() => const LoginPage());
  }

  void scrollToSection(double offset) {
    scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
