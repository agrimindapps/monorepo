// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/page_header_widget.dart';
import 'controllers/quebra_dormencia_controller.dart';
import 'widgets/quebra_dormencia/input_fields_widget.dart';
import 'widgets/quebra_dormencia/result_card_widget.dart';

class FruticulturaPage extends StatefulWidget {
  const FruticulturaPage({super.key});

  @override
  FruticulturaPageState createState() => FruticulturaPageState();
}

class FruticulturaPageState extends State<FruticulturaPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _quebradormenciaController = QuebraDormenciaController();

  final List<_TabItem> _tabs = [];

  @override
  void initState() {
    super.initState();
    _tabs.add(
      _TabItem(
        title: 'Quebra de Dormência',
        widget: _buildQuebraDormenciaTab(),
        icon: Icons.ac_unit_outlined,
        description:
            'Cálculo de tratamentos para quebra de dormência em frutíferas de clima temperado',
      ),
    );
  }

  @override
  void dispose() {
    _quebradormenciaController.dispose();
    super.dispose();
  }

  Widget _buildQuebraDormenciaTab() {
    return Column(
      children: [
        InputFieldsWidget(controller: _quebradormenciaController),
        const SizedBox(height: 16),
        ResultCardWidget(controller: _quebradormenciaController),
      ],
    );
  }

  Widget _buildTabContent(_TabItem tab) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tab.description != null) _buildDescriptionCard(tab),
          SizedBox(height: tab.description != null ? 16 : 0),
          tab.widget,
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(_TabItem tab) {
    return Card(
      elevation: 0,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.red.shade100,
        ),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              tab.icon,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                tab.description ?? '',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(72),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: PageHeaderWidget(
              title: 'Fruticultura',
              subtitle: 'Cálculos para manejo de frutíferas',
              icon: Icons.apple,
              showBackButton: true,
            ),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: _buildTabContent(_tabs[0]),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String title;
  final Widget widget;
  final IconData icon;
  final String? description;

  const _TabItem({
    required this.title,
    required this.widget,
    this.icon = Icons.calculate,
    this.description,
  });
}
