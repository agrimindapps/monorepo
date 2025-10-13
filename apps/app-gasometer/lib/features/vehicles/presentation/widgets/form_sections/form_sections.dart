/// Vehicle form sections - organized, reusable form components
///
/// This file exports all vehicle form section widgets for easy importing.
/// Each section is a self-contained, testable widget that handles a specific
/// part of the vehicle form.
///
/// Example usage:
/// ```dart
/// import 'package:app_gasometer/features/vehicles/presentation/widgets/form_sections/form_sections.dart';
///
/// // All sections are now available:
/// VehicleBasicInfoSection(...)
/// VehicleTechnicalSection()
/// VehicleDocumentationSection(...)
/// VehiclePhotoSection()
/// VehicleAdditionalInfoSection(...)
/// ```

export 'vehicle_additional_info_section.dart';
export 'vehicle_basic_info_section.dart';
export 'vehicle_documentation_section.dart';
export 'vehicle_photo_section.dart';
export 'vehicle_technical_section.dart';
