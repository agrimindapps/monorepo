/// Equines Module - Barrel Export
/// 
/// Módulo dedicado ao cadastro de raças de equinos
/// Re-exports de livestock shared + específicos de equinos

// Entities (re-export from livestock)
export '../livestock/domain/entities/equine_entity.dart';
export '../livestock/domain/entities/animal_base_entity.dart';

// Pages (re-export from livestock)
export '../livestock/presentation/pages/equines_list_page.dart';
export '../livestock/presentation/pages/equine_form_page.dart';
export '../livestock/presentation/pages/equine_detail_page.dart';

// Providers (re-export from livestock)
export '../livestock/presentation/providers/equines_provider.dart';
export '../livestock/presentation/providers/equines_management_provider.dart';

// Widgets (re-export from livestock)
export '../livestock/presentation/widgets/equine_card_widget.dart';
