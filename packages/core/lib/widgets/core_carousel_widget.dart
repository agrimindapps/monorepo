import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

/// Core Carousel Widget - wrapper customizado para carousel_slider
///
/// Fornece configurações padrão e facilita uso nos apps
class CoreCarouselWidget extends StatelessWidget {
  final List<Widget> items;
  final double height;
  final double viewportFraction;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enlargeCenterPage;
  final void Function(int, CarouselPageChangedReason)? onPageChanged;
  final CarouselSliderController? controller;
  final bool enableInfiniteScroll;
  final ScrollPhysics? scrollPhysics;

  const CoreCarouselWidget({
    super.key,
    required this.items,
    this.height = 200.0,
    this.viewportFraction = 0.8,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enlargeCenterPage = true,
    this.onPageChanged,
    this.controller,
    this.enableInfiniteScroll = true,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: items,
      carouselController: controller,
      options: CarouselOptions(
        height: height,
        viewportFraction: viewportFraction,
        autoPlay: autoPlay,
        autoPlayInterval: autoPlayInterval,
        enlargeCenterPage: enlargeCenterPage,
        onPageChanged: onPageChanged,
        enableInfiniteScroll: enableInfiniteScroll,
        scrollPhysics: scrollPhysics,
      ),
    );
  }
}

/// Builder variant for dynamic items
class CoreCarouselBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index, int realIndex) itemBuilder;
  final double height;
  final double viewportFraction;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enlargeCenterPage;
  final void Function(int, CarouselPageChangedReason)? onPageChanged;
  final CarouselSliderController? controller;
  final bool enableInfiniteScroll;

  const CoreCarouselBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height = 200.0,
    this.viewportFraction = 0.8,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enlargeCenterPage = true,
    this.onPageChanged,
    this.controller,
    this.enableInfiniteScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      carouselController: controller,
      options: CarouselOptions(
        height: height,
        viewportFraction: viewportFraction,
        autoPlay: autoPlay,
        autoPlayInterval: autoPlayInterval,
        enlargeCenterPage: enlargeCenterPage,
        onPageChanged: onPageChanged,
        enableInfiniteScroll: enableInfiniteScroll,
      ),
    );
  }
}
