// Domain entities
export 'domain/entities/water_achievement_entity.dart';
export 'domain/entities/water_custom_cup_entity.dart';
export 'domain/entities/water_daily_progress_entity.dart';
export 'domain/entities/water_goal_entity.dart';
export 'domain/entities/water_record_entity.dart';
export 'domain/entities/water_reminder_entity.dart';
export 'domain/entities/water_statistics_entity.dart';
export 'domain/entities/water_streak_entity.dart';

// Domain repository interface
export 'domain/repositories/i_water_tracker_repository.dart';

// Data layer
export 'data/datasources/water_tracker_local_datasource.dart';
export 'data/repositories/water_tracker_repository_impl.dart';
export 'data/services/water_notification_service.dart';

// Presentation providers
export 'presentation/providers/water_tracker_providers.dart';

// Presentation pages
export 'presentation/pages/water_tracker_home_page.dart';
export 'presentation/pages/water_statistics_page.dart';

// Presentation widgets
export 'presentation/widgets/achievements_grid.dart';
export 'presentation/widgets/animated_water_bottle.dart';
export 'presentation/widgets/quick_add_buttons.dart';
export 'presentation/widgets/streak_display.dart';
export 'presentation/widgets/water_calendar.dart';
export 'presentation/widgets/weekly_chart.dart';
