// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/condicao_corporal_controller.dart';
import 'services/dialog_service.dart';
import 'services/notification_service.dart';
import 'widgets/escala_card.dart';
import 'widgets/input_card.dart';
import 'widgets/result_card.dart';

class CalcCondicaoCorporalPage extends StatefulWidget {
  const CalcCondicaoCorporalPage({super.key});

  @override
  State<CalcCondicaoCorporalPage> createState() => _CondicaoCorporalPageState();
}

class _CondicaoCorporalPageState extends State<CalcCondicaoCorporalPage> {
  final _controller = CondicaoCorporalController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
    DialogService.showInfoDialog(context);
  }

  void _showRemindersManager() {
    NotificationService.showRemindersListDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(ShadcnStyle.containerPadding, 0, ShadcnStyle.containerPadding, ShadcnStyle.containerPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, ShadcnStyle.containerPadding, 0, 0),
                    child: ValueListenableBuilder<String?>(
                      valueListenable: _controller.especieNotifier,
                      builder: (context, especie, child) {
                        return ValueListenableBuilder<int?>(
                          valueListenable: _controller.indiceNotifier,
                          builder: (context, indice, child) {
                            return InputCard(controller: _controller);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: ShadcnStyle.sectionSpacing),
                  ValueListenableBuilder<String?>(
                    valueListenable: _controller.resultadoNotifier,
                    builder: (context, resultado, child) {
                      return ResultCard(controller: _controller);
                    },
                  ),
                  const SizedBox(height: ShadcnStyle.sectionSpacing),
                  const EscalaCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(ShadcnStyle.appBarPadding, ShadcnStyle.appBarPadding, ShadcnStyle.appBarPadding, 0),
          child: PageHeaderWidget(
            title: 'Condição Corporal',
            subtitle: 'Avalie a condição corporal do seu animal',
            icon: Icons.pets_outlined,
            showBackButton: true,
            actions: [
              Semantics(
                label: 'Gerenciar lembretes de reavaliação',
                hint: 'Toque para ver e gerenciar lembretes ativos',
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: ShadcnStyle.textColor,
                  ),
                  onPressed: _showRemindersManager,
                  tooltip: 'Gerenciar lembretes',
                ),
              ),
              Semantics(
                label: 'Informações sobre a avaliação',
                hint: 'Toque para ver como funciona a avaliação de condição corporal',
                child: IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: ShadcnStyle.textColor,
                  ),
                  onPressed: _showInfoDialog,
                  tooltip: 'Informações sobre a avaliação',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
