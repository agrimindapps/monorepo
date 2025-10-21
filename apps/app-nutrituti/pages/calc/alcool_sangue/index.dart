// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'controller/alcool_sangue_controller.dart';
import 'widgets/alcool_sangue_form.dart';
import 'widgets/alcool_sangue_info.dart';
import 'widgets/alcool_sangue_result.dart';

class AlcoolSangueCalcPage extends StatefulWidget {
  const AlcoolSangueCalcPage({super.key});

  @override
  State<AlcoolSangueCalcPage> createState() => _AlcoolSangueCalcPageState();
}

class _AlcoolSangueCalcPageState extends State<AlcoolSangueCalcPage> {
  late final AlcoolSangueController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AlcoolSangueController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.local_bar_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            const Text('Álcool no Sangue (TAS)'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informações sobre o cálculo',
            onPressed: () => AlcoolSangueInfoDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                AlcoolSangueForm(controller: _controller),
                const SizedBox(height: 16),
                AlcoolSangueResult(controller: _controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
