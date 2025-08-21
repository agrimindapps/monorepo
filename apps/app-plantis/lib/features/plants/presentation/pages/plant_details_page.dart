import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_details_provider.dart';
import '../providers/plant_task_provider.dart';
import '../widgets/plant_details/plant_details_view.dart';

/// Página de detalhes da planta refatorada
/// Agora usa componentes modulares para melhor manutenibilidade
///
/// REFATORAÇÃO COMPLETA:
/// - Quebrou God Class de 1.371 linhas em 6 componentes especializados
/// - PlantDetailsController: Lógica de negócio e navegação
/// - PlantImageSection: Gerenciamento de imagens
/// - PlantInfoSection: Informações básicas da planta
/// - PlantCareSection: Configurações de cuidados
/// - PlantTasksSection: Gerenciamento de tarefas
/// - PlantNotesSection: Observações e comentários
/// - PlantDetailsView: Estrutura visual principal
class PlantDetailsPage extends StatelessWidget {
  final String plantId;

  const PlantDetailsPage({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlantDetailsProvider>(
          create: (context) => context.read<PlantDetailsProvider>(),
        ),
        ChangeNotifierProvider<PlantTaskProvider>(
          create: (context) => context.read<PlantTaskProvider>(),
        ),
      ],
      child: PlantDetailsView(plantId: plantId),
    );
  }
}
