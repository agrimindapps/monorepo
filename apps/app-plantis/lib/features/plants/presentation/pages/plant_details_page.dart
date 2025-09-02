import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../providers/plant_details_provider.dart';
import '../providers/plant_task_provider.dart';
import '../providers/plant_comments_provider.dart';
import '../widgets/plant_details/plant_details_view.dart';

/// Plant details page with proper dependency injection
/// Uses clean architecture with modular components for better maintainability
///
/// ARCHITECTURAL IMPROVEMENTS:
/// - Modular component breakdown from 1,371-line God Class into 6 specialized components
/// - PlantDetailsController: Business logic and navigation
/// - PlantImageSection: Image management
/// - PlantInfoSection: Basic plant information  
/// - PlantCareSection: Care configuration
/// - PlantTasksSection: Task management
/// - PlantNotesSection: Observations and comments
/// - PlantDetailsView: Main visual structure
/// - FIXED: Proper DI injection using ChangeNotifierProvider.value instead of antipattern
class PlantDetailsPage extends StatelessWidget {
  final String plantId;

  const PlantDetailsPage({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlantDetailsProvider>.value(
          value: di.sl<PlantDetailsProvider>(),
        ),
        ChangeNotifierProvider<PlantTaskProvider>.value(
          value: di.sl<PlantTaskProvider>(),
        ),
        ChangeNotifierProvider<PlantCommentsProvider>.value(
          value: di.sl<PlantCommentsProvider>(),
        ),
      ],
      child: PlantDetailsView(plantId: plantId),
    );
  }
}
