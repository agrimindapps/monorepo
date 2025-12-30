import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../shared/constants/animals_constants.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../widgets/animals_body.dart';
import '../widgets/animals_error_handler.dart';
import '../widgets/animals_list_controller.dart';
import '../widgets/animals_page_coordinator.dart';

/// Main Animals page following Clean Architecture principles
/// 
/// Responsibilities:
/// - Page structure and layout
/// - Coordinating between UI components
/// - Managing page-level state
class AnimalsPage extends ConsumerStatefulWidget {
  const AnimalsPage({super.key});
  
  @override
  ConsumerState<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends ConsumerState<AnimalsPage> 
    with AutomaticKeepAliveClientMixin {
  
  late final AnimalsPageCoordinator _coordinator;
  late final AnimalsListController _listController;

  @override
  void initState() {
    super.initState();
    _coordinator = AnimalsPageCoordinator(ref: ref);
    _listController = AnimalsListController(context: context, ref: ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _coordinator.initializePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: PetivetiPageHeader(
                icon: Icons.pets,
                title: AnimalsConstants.myPets,
                subtitle: 'Gerencie seus animais de estimação',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // TODO: Implementar busca
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      // TODO: Implementar filtros
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  AnimalsBody(
                    onAddAnimal: _listController.addAnimal,
                    onViewAnimalDetails: _listController.viewAnimalDetails,
                    onEditAnimal: _listController.editAnimal,
                    onDeleteAnimal: _listController.deleteAnimal,
                  ),
                  AnimalsErrorHandler(
                    coordinator: _coordinator,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Semantics(
        label: AnimalsConstants.addNewPetSemantic,
        hint: AnimalsConstants.addNewPetHint,
        button: true,
        child: FloatingActionButton(
          onPressed: _listController.addAnimal,
          tooltip: AnimalsConstants.addPetTooltip,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep page state alive for better performance

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }
}
