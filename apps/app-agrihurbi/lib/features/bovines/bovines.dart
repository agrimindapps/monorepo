/// Bovines Module - Barrel Export
/// 
/// Módulo dedicado ao cadastro de raças de bovinos
/// Re-exports de livestock shared + específicos de bovinos

// Entities (re-export from livestock)
export '../livestock/domain/entities/bovine_entity.dart';
export '../livestock/domain/entities/animal_base_entity.dart';

// Pages (re-export from livestock)
export '../livestock/presentation/pages/bovines_list_page.dart';
export '../livestock/presentation/pages/bovine_form_page.dart';
export '../livestock/presentation/pages/bovine_detail_page.dart';

// Providers (re-export from livestock)
export '../livestock/presentation/providers/bovines_provider.dart';
export '../livestock/presentation/providers/bovines_management_provider.dart';
export '../livestock/presentation/providers/bovines_filter_provider.dart';

// Widgets (re-export from livestock)
export '../livestock/presentation/widgets/bovine_card_widget.dart';
export '../livestock/presentation/widgets/bovine_form_action_buttons.dart';
export '../livestock/presentation/widgets/bovine_basic_info_section.dart';
export '../livestock/presentation/widgets/bovine_characteristics_section.dart';
export '../livestock/presentation/widgets/bovine_additional_info_section.dart';
export '../livestock/presentation/widgets/bovine_status_section.dart';
