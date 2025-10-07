/// A centralized collection of constants for the Animals feature.
///
/// This includes UI strings, accessibility labels, and layout values to ensure
/// consistency and ease of maintenance.
class AnimalsConstants {
  AnimalsConstants._();

  /// Constants for user-facing UI strings.
  /// These should be moved to a proper localization (l10n) system.
  abstract class UI {
    UI._();
    static const String addPetTooltip = 'Add Pet';
    static const String myPets = 'My Pets';
    static const String searchPetsHint = 'Search pets...';
    static const String synchronize = 'Synchronize';
    static const String synchronizing = 'Synchronizing...';
    static const String clearFilters = 'Clear Filters';
    static const String settings = 'Settings';
    static const String filters = 'Filters';
    static const String clearAll = 'Clear All';
    static const String apply = 'Apply';
    static const String species = 'Species';
    static const String allSpecies = 'All species';
    static const String gender = 'Gender';
    static const String allGenders = 'All genders';
    static const String size = 'Size';
    static const String allSizes = 'All sizes';
    static const String optionsMenu = 'Options Menu';
  }

  /// Constants for accessibility labels and hints.
  /// These should also be localized.
  abstract class Accessibility {
    Accessibility._();
    static const String addNewPetSemantic = 'Add new pet';
    static const String addNewPetHint = 'Tap to open the pet registration form';
    static const String backToList = 'Back to pet list';
    static const String backToListHint = 'Tap to exit search mode';
    static const String searchPets = 'Search pets';
    static const String searchPetsHint = 'Tap to search pets by name';
    static const String searchActiveHint = 'Search is active. Tap to search pets by name';
    static const String filtersLabel = 'Filters - Configure filters';
    static const String filtersActiveLabel = 'Active filters - Configure filters';
    static const String filtersHint = 'Tap to filter pets by species, gender, and size';
    static const String filtersActiveHint = 'Filters are applied. Tap to modify species, gender, and size filters';
    static const String clearSearch = 'Clear search';
    static const String clearSearchHint = 'Tap to clear the search field';
    static const String optionsMenuHint = 'Tap to open menu with sync, settings, and other options';
    static const String syncPets = 'Synchronize pets';
    static const String syncPetsHint = 'Tap to synchronize the pet list with the server';
    static const String clearAllFilters = 'Clear all filters';
    static const String clearAllFiltersHint = 'Tap to remove all applied filters and show all pets';
    static const String settingsHint = 'Tap to open application settings';
    static const String searchFieldLabel = 'Pet search field';
    static const String searchFieldHint = 'Enter the name of the pet you are looking for';
    static const String applyFilters = 'Apply filters';
    static const String applyFiltersHint = 'Tap to apply the selected filters and close the menu';
    static const String speciesFilterLabel = 'Species filter';
    static const String speciesFilterHint = 'Select a species to filter your pets';
    static const String genderFilterLabel = 'Gender filter';
    static const String genderFilterHint = 'Select a gender to filter your pets';
    static const String sizeFilterLabel = 'Size filter';
    static const String sizeFilterHint = 'Select a size to filter your pets';
  }

  /// Layout and dimension constants.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Dimensions {
    Dimensions._();
    static const double filterContainerPadding = 16.0;
    static const double filterSectionSpacing = 16.0;
    static const double filterSectionSpacingSmall = 8.0;
    static const double badgeHorizontalPadding = 8.0;
    static const double badgeVerticalPadding = 2.0;
    static const double badgeBorderRadius = 12.0;
    static const double badgeFontSize = 12.0;
    static const double filterTitleFontSize = 16.0;
    static const double filterHeaderFontSize = 20.0;
  }

  /// Duration and timing constants.
  abstract class Durations {
    Durations._();
    static const int syncDurationSeconds = 2;
  }
}