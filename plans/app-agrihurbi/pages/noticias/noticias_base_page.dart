// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../services/rss_service.dart';
import '../../widgets/page_header_widget.dart';
import 'widgets/news_list_tile.dart';
import 'widgets/news_skeleton_loader.dart';

enum NoticiasType { agricultura, pecuaria }

class NoticiasBasePage extends StatefulWidget {
  final NoticiasType type;
  final String title;
  final String subtitle;
  final IconData icon;

  const NoticiasBasePage({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<NoticiasBasePage> createState() => _NoticiasBasePageState();
}

class _NoticiasBasePageState extends State<NoticiasBasePage> {
  final RSSService _rssService = RSSService();

  @override
  void initState() {
    super.initState();
    _carregarNoticias();
  }

  Future<void> _carregarNoticias() async {
    if (widget.type == NoticiasType.agricultura) {
      await _rssService.carregaAgroRSS();
    } else {
      await _rssService.carregaPecuariaRSS();
    }
  }

  RxList get _items {
    return widget.type == NoticiasType.agricultura
        ? _rssService.itemsAgricultura
        : _rssService.itemsPecuaria;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final isDesktop = constraints.maxWidth > 1200;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isDesktop ? 16.0 : 8.0),
                child: Obx(() {
                  return PageHeaderWidget(
                    title: widget.title,
                    subtitle: _rssService.isLoading.value
                        ? 'Carregando...'
                        : '${_items.length} notícias',
                    icon: widget.icon,
                    showBackButton: true,
                    actions: [
                      IconButton(
                        onPressed: _rssService.isLoading.value
                            ? null
                            : _carregarNoticias,
                        icon: _rssService.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.refresh,
                                size: 25, color: Colors.white),
                      ),
                    ],
                  );
                }),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _carregarNoticias,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32.0 : (isTablet ? 16.0 : 8.0),
                        vertical: 8.0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 1200 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                elevation: isTablet ? 4 : 2,
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(isDesktop ? 16.0 : 8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Obx(() {
                                        if (_rssService.isLoading.value) {
                                          return NewsSkeletonLoader(
                                            itemCount: isDesktop
                                                ? 8
                                                : (isTablet ? 6 : 4),
                                          );
                                        }

                                        if (_rssService
                                            .error.value.isNotEmpty) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  isDesktop ? 48.0 : 32.0),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.error_outline,
                                                    size: isDesktop ? 64 : 48,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          isDesktop ? 24 : 16),
                                                  Text(
                                                    _rssService.error.value,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          isDesktop ? 16 : 14,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          isDesktop ? 24 : 16),
                                                  ElevatedButton.icon(
                                                    onPressed:
                                                        _carregarNoticias,
                                                    icon: const Icon(
                                                        Icons.refresh),
                                                    label: const Text(
                                                        'Tentar Novamente'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            isDesktop ? 24 : 16,
                                                        vertical:
                                                            isDesktop ? 16 : 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        if (_items.isEmpty) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  isDesktop ? 48.0 : 32.0),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.newspaper,
                                                    size: isDesktop ? 64 : 48,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          isDesktop ? 24 : 16),
                                                  Text(
                                                    'Nenhuma notícia encontrada',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize:
                                                          isDesktop ? 16 : 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        return isDesktop
                                            ? _buildDesktopGrid()
                                            : _buildMobileList();
                                      })
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return NewsListTile(
          item: _items[index],
        );
      },
    );
  }

  Widget _buildDesktopGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          child: NewsListTile(
            item: _items[index],
          ),
        );
      },
    );
  }
}
