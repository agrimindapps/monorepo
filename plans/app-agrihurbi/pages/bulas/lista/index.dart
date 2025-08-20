// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controller/bulas_lista_controller.dart';
import 'widgets/bula_list_item.dart';
import 'widgets/empty_state.dart';

class BulasListaPage extends StatefulWidget {
  const BulasListaPage({super.key});

  @override
  State<BulasListaPage> createState() => _BulasListaPageState();
}

class _BulasListaPageState extends State<BulasListaPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.put(BulasListaController());

  @override
  void initState() {
    super.initState();
    _controller.carregarDados();
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildBulasList() {
    return Obx(() {
      final bulas = _controller.bulas;

      if (bulas.isEmpty) {
        return const EmptyStateWidget();
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade300,
            ),
            itemCount: bulas.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => BulaListItem(
              bula: bulas[index],
              onTap: _controller.navigateToDetails,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildContent() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return _buildLoadingIndicator();
      }
      return _buildBulasList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() {
                return PageHeaderWidget(
                  title: 'Bulas',
                  subtitle: '${_controller.bulas.length} registros',
                  icon: Icons.medical_information,
                  showBackButton: true,
                  actions: [
                    IconButton(
                      onPressed: _controller.carregarDados,
                      icon: const Icon(Icons.refresh,
                          size: 25, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: _controller.navigateToRegister,
                      icon:
                          const Icon(Icons.add, size: 25, color: Colors.white),
                    ),
                  ],
                );
              }),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
