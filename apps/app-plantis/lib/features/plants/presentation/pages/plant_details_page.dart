import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/plant_details/plant_details_view.dart';

/// Plant details page - fully migrated to Riverpod
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
/// - MIGRATED: All providers now accessed via Riverpod (ref.watch/ref.read)
class PlantDetailsPage extends ConsumerWidget {
  final String plantId;

  const PlantDetailsPage({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlantDetailsView(plantId: plantId);
  }
}
