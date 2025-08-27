import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/animals_app_bar.dart';
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
    
    // Initialize data loading after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _coordinator.initializePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      appBar: const AnimalsAppBar(),
      body: Stack(
        children: [
          AnimalsBody(
            onAddAnimal: _listController.addAnimal,
            onViewAnimalDetails: _listController.viewAnimalDetails,
            onEditAnimal: _listController.editAnimal,
            onDeleteAnimal: _listController.deleteAnimal,
          ),
          // Error handling overlay
          AnimalsErrorHandler(
            coordinator: _coordinator,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listController.addAnimal,
        tooltip: 'Adicionar Pet',
        child: const Icon(Icons.pets),
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