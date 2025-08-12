// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/racas_detalhes_controller.dart';
import '../models/raca_detalhes_model.dart';
import 'widgets/raca_app_bar_widget.dart';
import 'widgets/raca_caracteristicas_widget.dart';
import 'widgets/raca_header_image_widget.dart';
import 'widgets/raca_image_gallery_widget.dart';
import 'widgets/raca_info_section_widget.dart';
import 'widgets/raca_related_breeds_widget.dart';
import 'widgets/raca_summary_card_widget.dart';
import 'widgets/veterinary_consult_modal.dart';

class RacasDetalhesPage extends StatefulWidget {
  const RacasDetalhesPage({super.key});

  @override
  State<RacasDetalhesPage> createState() => _RacasDetalhesPageState();
}

class _RacasDetalhesPageState extends State<RacasDetalhesPage> {
  late final RacasDetalhesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RacasDetalhesController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _controller.inicializarRaca(args);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.raca == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Raça não encontrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final raca = _controller.raca!;

        return Scaffold(
          appBar: RacaAppBarWidget(
            raca: raca,
            controller: _controller,
          ),
          body: CustomScrollView(
            slivers: [
              RacaHeaderImageWidget(raca: raca),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RacaSummaryCardWidget(raca: raca),
                    RacaCaracteristicasWidget(raca: raca),
                    RacaInfoSectionWidget(
                      title: 'Temperamento',
                      content: raca.temperamento,
                      sectionKey: 'temperamento',
                    ),
                    RacaInfoSectionWidget(
                      title: 'Saúde',
                      content: raca.saude,
                      sectionKey: 'saude',
                    ),
                    RacaInfoSectionWidget(
                      title: 'Cuidados',
                      content: raca.cuidados,
                      sectionKey: 'cuidados',
                    ),
                    RacaInfoSectionWidget(
                      title: 'Treinamento',
                      content: raca.treinamento,
                      sectionKey: 'treinamento',
                    ),
                    RacaImageGalleryWidget(
                      raca: raca,
                      controller: _controller,
                    ),
                    RacaRelatedBreedsWidget(
                      raca: raca,
                      controller: _controller,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showVeterinaryConsult(context, raca),
            icon: const Icon(Icons.medical_services),
            label: const Text('Consulta Veterinária'),
            backgroundColor: Colors.blue[800],
          ),
        );
      },
    );
  }

  void _showVeterinaryConsult(BuildContext context, RacaDetalhes raca) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VeterinaryConsultModal(
        raca: raca,
        controller: _controller,
      ),
    );
  }
}
