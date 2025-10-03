// Data Export Feature - LGPD Compliance
// Barrel file for exporting all data export functionality

// Domain Layer
export 'domain/entities/export_request.dart';

// Presentation Layer
// export 'presentation/providers/data_export_provider.dart'; // Migrated to Riverpod
export 'presentation/providers/data_export_notifier.dart';
export 'presentation/widgets/export_availability_widget.dart';
export 'presentation/widgets/export_progress_dialog.dart';

// Data Layer (will be created later as needed)
// export 'data/repositories/export_repository_impl.dart';
// export 'data/datasources/export_local_datasource.dart';
// export 'data/datasources/export_remote_datasource.dart';