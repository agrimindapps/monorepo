// Dart imports:
import 'dart:async';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../../../../core/models/database.dart';
import '../../../injections.dart';
import '../../../repository/pragas_repository.dart';
import '../../../router.dart';
import '../constants/home_pragas_constants.dart';
import '../models/navigation_args.dart';
import '../models/praga_counts.dart';
import '../models/praga_item.dart';
import '../models/pragas_home_data.dart';
import '../utils/device_performance_helper.dart';

// INITIALIZATION STATE ENUM
enum InitializationState {
  initial,
  initializingDependencies,
  dependenciesReady,
  loadingData,
  ready,
  error,
}

// LOADING STATE ENUM FOR OPERATIONS
enum LoadingState {
  initial,
  loading,
  success,
  error,
  initialized,
}

class HomePragasController extends GetxController {
  // CONTROLLERS & KEYS
  final CarouselSliderController carouselController =
      CarouselSliderController();

  // REPOSITORIES
  late final PragasRepository repository;

  // PERFORMANCE OPTIMIZATION - Debounce timers
  Timer? _loadDataDebounceTimer;
  Timer? _preloadSuggestedTimer;
  Timer? _preloadRecentTimer;
  Timer? _cacheCleanupTimer;

  // LAZY LOADING VARIABLES (optimized based on device performance)
  late final LoadingThresholds _thresholds;
  late final int _itemsPerPage;
  late final int _maxSuggestedItems;
  late final int _loadThreshold;

  // STATE VARIABLES - OBSERVABLE (Performance optimized with targeted use of reactive variables)
  final _initializationState = InitializationState.initial.obs;
  final _loadingState = LoadingState.initial.obs;
  final _initializationError = Rxn<String>();
  final _stateTransitionLog = <String>[].obs;
  final _homeData = PragasHomeData().obs;
  final _isLoadingMoreSuggested = false.obs;
  final _isLoadingMoreRecent = false.obs;
  final _hasMoreSuggested = true.obs;
  final _hasMoreRecent = true.obs;

  // LAZY LOADING OPTIMIZATIONS
  final _suggestedCurrentPage = PageConstants.initialPage.obs;
  final _recentCurrentPage = PageConstants.initialPage.obs;
  final _isNearLoadThreshold = false.obs;

  // PERFORMANCE OPTIMIZED CACHE - Use RxList with optimizations
  final _cachedSuggestedItems = <PragaItem>[].obs;
  final _cachedRecentItems = <PragaItem>[].obs;

  // DEBOUNCE CONTROL FLAGS - Non-reactive for better performance
  final bool _isDebouncing = false;
  bool _hasPendingUpdates = false;

  // GETTERS
  bool get isLoading => _loadingState.value == LoadingState.loading;
  bool get isControllerInitialized =>
      _initializationState.value == InitializationState.ready &&
      _loadingState.value == LoadingState.initialized;
  InitializationState get initializationState => _initializationState.value;
  LoadingState get loadingState => _loadingState.value;
  String? get initializationError => _initializationError.value;
  bool get isDependenciesReady =>
      _initializationState.value.index >=
      InitializationState.dependenciesReady.index;
  bool get hasInitializationError =>
      _initializationState.value == InitializationState.error;
  bool get hasLoadingError => _loadingState.value == LoadingState.error;

  // LAZY LOADING GETTERS
  int get suggestedCurrentPage => _suggestedCurrentPage.value;
  int get recentCurrentPage => _recentCurrentPage.value;
  bool get isNearLoadThreshold => _isNearLoadThreshold.value;
  List<PragaItem> get cachedSuggestedItems => _cachedSuggestedItems.toList();
  List<PragaItem> get cachedRecentItems => _cachedRecentItems.toList();
  PragasHomeData get homeData => _homeData.value;
  int get carouselCurrentIndex => _homeData.value.carouselCurrentIndex;
  bool get isLoadingMoreSuggested => _isLoadingMoreSuggested.value;
  bool get isLoadingMoreRecent => _isLoadingMoreRecent.value;
  bool get hasMoreSuggested => _hasMoreSuggested.value;
  bool get hasMoreRecent => _hasMoreRecent.value;

  // PERFORMANCE GETTERS
  bool get isDebouncing => _isDebouncing;
  bool get hasPendingUpdates => _hasPendingUpdates;
  List<String> get stateTransitionLog => _stateTransitionLog.toList();

  @override
  void onInit() {
    super.onInit();

    // Initialize performance-optimized thresholds
    _thresholds = DevicePerformanceHelper.getOptimizedThresholds();
    _itemsPerPage = _thresholds.itemsPerPage;
    _maxSuggestedItems =
        _itemsPerPage * PerformanceConstants.suggestedItemsMultiplier;
    _loadThreshold =
        (_itemsPerPage * PerformanceConstants.loadThresholdMultiplier).round();

    repository = Get.find<PragasRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoadData();
    });

    // PERFORMANCE OPTIMIZATION: Start cache management
    _optimizeCacheStrategy();
  }

  // INITIALIZATION METHODS
  Future<void> _initializeAndLoadData() async {
    try {
      _setLoadingState(LoadingState.loading);
      _initializationError.value = null;

      // Step 1: Initialize dependencies
      await _initializeDependencies();

      // Step 2: Validate pre-conditions
      if (!_validatePreConditions()) {
        throw Exception('Pre-conditions validation failed');
      }

      // Step 3: Initialize repository info
      _initializeRepositoryInfo();

      // Step 4: Load data
      await _loadDataWithStateManagement();

      // Step 5: Mark as ready
      _setInitializationState(InitializationState.ready);
      _setLoadingState(LoadingState.initialized);
    } catch (e) {
      await _handleInitializationError(e);
    }
  }

  Future<void> _initializeDependencies() async {
    _setInitializationState(InitializationState.initializingDependencies);

    try {
      // Initialize dependencies with timeout
      await ReceituagroBindings.initDependencies().timeout(
        TimeoutConstants.initializationTimeout,
      );

      _setInitializationState(InitializationState.dependenciesReady);
    } catch (e) {
      throw Exception('Failed to initialize dependencies: $e');
    }
  }

  bool _validatePreConditions() {
    try {
      // Validate repository is available
      try {
        Get.find<PragasRepository>();
      } catch (e) {
        return false;
      }

      // Validate database connection can be created
      try {
        Database();
      } catch (e) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _initializeRepositoryInfo() {
    try {
      repository.initInfo();
    } catch (e) {
      throw Exception('Failed to initialize repository info: $e');
    }
  }

  Future<void> _loadDataWithStateManagement() async {
    _setInitializationState(InitializationState.loadingData);

    try {
      await _loadData().timeout(
        TimeoutConstants.dataLoadingTimeout,
      );
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _setLoadingState(LoadingState.error);
      throw Exception('Failed to load initial data: $e');
    }
  }

  Future<void> _handleInitializationError(dynamic error) async {
    final errorMessage = error.toString();
    _initializationError.value = errorMessage;
    _setInitializationState(InitializationState.error);
    _setLoadingState(LoadingState.error);

    // Attempt recovery if possible
    await _attemptRecovery(error);
  }

  Future<void> _attemptRecovery(dynamic error) async {
    try {
      // Wait a bit before retry
      await Future.delayed(TimeoutConstants.repositoryInitDelay);

      // Reset states for retry
      _setInitializationState(InitializationState.initial);
      _setLoadingState(LoadingState.initial);

      // Simple retry once
      if (_initializationState.value == InitializationState.initial) {
        await _initializeAndLoadData();
      }
    } catch (recoveryError) {
      _setLoadingState(LoadingState.error);
    }
  }

  // STATE MANAGEMENT METHODS
  void _setInitializationState(InitializationState newState) {
    final oldState = _initializationState.value;
    if (oldState != newState) {
      _initializationState.value = newState;
      _logStateTransition(
          'InitializationState', oldState.toString(), newState.toString());
    }
  }

  void _setLoadingState(LoadingState newState) {
    final oldState = _loadingState.value;
    if (oldState != newState) {
      _loadingState.value = newState;
      _logStateTransition(
          'LoadingState', oldState.toString(), newState.toString());
    }
  }

  void _logStateTransition(String stateType, String from, String to) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $stateType: $from → $to';
    _stateTransitionLog.add(logEntry);

    // PERFORMANCE OPTIMIZATION: Keep only last entries to prevent memory issues
    if (_stateTransitionLog.length >
        PerformanceConstants.maxStateTransitionLogEntries) {
      _stateTransitionLog.removeAt(PerformanceConstants.stateLogRemovalIndex);
    }
  }

  // Manual recovery method for external use
  Future<void> retryInitialization() async {
    if (_initializationState.value != InitializationState.error &&
        _loadingState.value != LoadingState.error) {
      return;
    }

    _setInitializationState(InitializationState.initial);
    _setLoadingState(LoadingState.initial);
    await _initializeAndLoadData();
  }

  // Method to clear state logs
  void clearStateLog() {
    _stateTransitionLog.clear();
  }

  // DATA LOADING METHODS
  Future<void> _loadData() async {
    try {
      await Future.wait([
        loadPestCounts(),
        loadSuggestedPests(),
        loadRecentlyAccessedPests(),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadPestCounts() async {
    try {
      final database = Database();
      final pragas = await database.getAll('tbpragas');

      int insetos = 0;
      int doencas = 0;
      int plantas = 0;

      for (final praga in pragas) {
        final tipoPraga = praga['tipoPraga'];
        switch (tipoPraga) {
          case '1':
            insetos++;
            break;
          case '2':
            doencas++;
            break;
          case '3':
            plantas++;
            break;
        }
      }

      final culturas = await database.getAll('tbculturas');

      final counts = PragaCounts(
        insetos: insetos,
        doencas: doencas,
        plantas: plantas,
        culturas: culturas.length,
      );

      _homeData.value = _homeData.value.copyWith(counts: counts);
    } catch (e) {
      // Navigation error handled silently
    }
  }

  Future<void> loadRecentlyAccessedPests({bool loadMore = false}) async {
    // PERFORMANCE OPTIMIZATION: Debounce rapid calls
    if (_isDebouncing) {
      _hasPendingUpdates = true;
      return;
    }

    try {
      if (loadMore) {
        _isLoadingMoreRecent.value = true;
      }

      // PERFORMANCE OPTIMIZATION: Use cached data if available and not loading more
      if (!loadMore && _cachedRecentItems.isNotEmpty) {
        final endIndex = _itemsPerPage.clamp(0, _cachedRecentItems.length);
        final itemsToShow = _cachedRecentItems.sublist(0, endIndex);
        _homeData.value =
            _homeData.value.copyWith(ultimasPragasAcessadas: itemsToShow);
        _hasMoreRecent.value = _cachedRecentItems.length > _itemsPerPage;
        return;
      }

      final pragasAcessadas = await repository.getPragasAcessados();
      final allItems =
          pragasAcessadas.map((item) => PragaItem.fromMap(item)).toList();

      // PERFORMANCE OPTIMIZATION: Efficient cache management - batch operation
      if (_cachedRecentItems.isEmpty) {
        _cachedRecentItems.assignAll(allItems);
      } else {
        // Update cache efficiently without full replacement
        final existingIds =
            _cachedRecentItems.map((item) => item.idReg).toSet();
        final newItems = allItems
            .where((item) => !existingIds.contains(item.idReg))
            .toList();
        if (newItems.isNotEmpty) {
          _cachedRecentItems.addAll(newItems);
        }
      }

      List<PragaItem> itemsToShow;
      if (loadMore) {
        final currentItems = _homeData.value.ultimasPragasAcessadas;
        final nextPage = _recentCurrentPage.value + 1;
        final startIndex = nextPage * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, allItems.length);

        if (startIndex >= allItems.length) {
          _hasMoreRecent.value = false;
          return;
        }

        final newItems = allItems.sublist(startIndex, endIndex);
        itemsToShow = [...currentItems, ...newItems];
        _recentCurrentPage.value = nextPage;
        _hasMoreRecent.value = endIndex < allItems.length;

        // Preload next batch if near threshold
        _checkAndPreloadRecent(itemsToShow.length, allItems.length);
      } else {
        final endIndex = _itemsPerPage.clamp(0, allItems.length);
        itemsToShow = allItems.sublist(0, endIndex);
        _recentCurrentPage.value = PageConstants.initialPage;
        _hasMoreRecent.value = allItems.length > _itemsPerPage;
      }

      _homeData.value =
          _homeData.value.copyWith(ultimasPragasAcessadas: itemsToShow);
    } catch (e) {
      if (!loadMore) {
        _homeData.value = _homeData.value.copyWith(ultimasPragasAcessadas: []);
      }
    } finally {
      if (loadMore) {
        _isLoadingMoreRecent.value = false;
      }
    }
  }

  Future<void> loadSuggestedPests({bool loadMore = false}) async {
    // PERFORMANCE OPTIMIZATION: Debounce rapid calls
    _loadDataDebounceTimer?.cancel();
    _loadDataDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _loadSuggestedPestsInternal(loadMore: loadMore);
    });
  }

  Future<void> _loadSuggestedPestsInternal({bool loadMore = false}) async {
    try {
      if (loadMore) {
        _isLoadingMoreSuggested.value = true;
      }

      List<PragaItem> itemsToShow;
      if (loadMore &&
          _homeData.value.pragasSugeridas.length < _maxSuggestedItems) {
        final currentItems = _homeData.value.pragasSugeridas;

        // Use cached items if available
        if (_cachedSuggestedItems.length > currentItems.length) {
          final nextPage = _suggestedCurrentPage.value + 1;
          final startIndex = nextPage * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage)
              .clamp(0, _cachedSuggestedItems.length);

          if (startIndex < _cachedSuggestedItems.length) {
            final newItems =
                _cachedSuggestedItems.sublist(startIndex, endIndex);
            itemsToShow = [...currentItems, ...newItems];
            _suggestedCurrentPage.value = nextPage;
          } else {
            // Load more from repository
            itemsToShow = await _loadMoreSuggestedFromRepository(currentItems);
          }
        } else {
          // Load more from repository
          itemsToShow = await _loadMoreSuggestedFromRepository(currentItems);
        }

        _hasMoreSuggested.value = itemsToShow.length < _maxSuggestedItems;

        // Preload next batch if near threshold
        _checkAndPreloadSuggested(itemsToShow.length);
      } else {
        // Initial load
        final pragasAleatorias = await repository.getPragasRandom();
        final allItems =
            pragasAleatorias.map((item) => PragaItem.fromMap(item)).toList();

        // PERFORMANCE OPTIMIZATION: Efficient cache management - avoid unnecessary operations
        if (_cachedSuggestedItems.length != allItems.length) {
          _cachedSuggestedItems.assignAll(allItems);
        }

        itemsToShow = allItems.take(_itemsPerPage).toList();
        _suggestedCurrentPage.value = PageConstants.initialPage;
        _hasMoreSuggested.value = _maxSuggestedItems > _itemsPerPage;
      }

      _homeData.value = _homeData.value.copyWith(pragasSugeridas: itemsToShow);
    } catch (e) {
      if (!loadMore) {
        _homeData.value = _homeData.value.copyWith(pragasSugeridas: []);
      }
    } finally {
      if (loadMore) {
        _isLoadingMoreSuggested.value = false;
      }
    }
  }

  Future<List<PragaItem>> _loadMoreSuggestedFromRepository(
      List<PragaItem> currentItems) async {
    final additionalItems = await repository.getPragasRandom();
    final newItems = additionalItems
        .map((item) => PragaItem.fromMap(item))
        .where((item) =>
            !currentItems.any((existing) => existing.idReg == item.idReg))
        .take(_itemsPerPage)
        .toList();

    // Update cache with new items
    _cachedSuggestedItems.addAll(newItems);

    return [...currentItems, ...newItems];
  }

  Future<bool> loadPestById(String id) async {
    try {
      if (id.isEmpty) {
        return false;
      }
      await repository.getPragaById(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // NAVIGATION METHODS
  void navigateToPragaDetails(String? id, {String? source}) {
    if (id == null || id.isEmpty) {
      return;
    }

    try {
      final args = PragaDetailsArgs(
        idReg: id,
        source: source ?? 'home_pragas',
      );

      // Validate arguments before navigation
      if (!NavigationHelper.validateNavigation(
          args, AppRoutes.pragasDetalhes)) {
        return;
      }

      // Log navigation attempt
      NavigationHelper.logNavigationAttempt(AppRoutes.pragasDetalhes, args);

      // Load pest data before navigation
      loadPestById(id);

      // Navigate with typed arguments
      final context = Get.context;
      if (context != null && Navigator.of(context).canPop()) {
        // Usa Navigator local se disponível
        Navigator.of(context)
            .pushNamed(AppRoutes.pragasDetalhes, arguments: args.toMap());
      } else {
        // Fallback para GetX se Navigator local não estiver disponível
        Get.toNamed(
          AppRoutes.pragasDetalhes,
          arguments: args.toMap(),
        );
      }
    } catch (e) {
      // Navigation error handled silently
    }
  }

  void navigateToPragasList(String tipoPraga,
      {String? filterCultura, String? searchTerm, String? source}) {
    if (tipoPraga.isEmpty) {
      return;
    }

    try {
      final args = PragasListArgs(
        tipoPraga: tipoPraga,
        filterCultura: filterCultura,
        searchTerm: searchTerm,
        source: source ?? 'home_pragas',
      );

      // Validate arguments before navigation
      if (!NavigationHelper.validateNavigation(args, AppRoutes.pragasListar)) {
        return;
      }

      // Log navigation attempt
      NavigationHelper.logNavigationAttempt(AppRoutes.pragasListar, args);

      // Navigate with typed arguments
      final context = Get.context;
      if (context != null && Navigator.of(context).canPop()) {
        // Usa Navigator local se disponível
        Navigator.of(context)
            .pushNamed(AppRoutes.pragasListar, arguments: args.toMap());
      } else {
        // Fallback para GetX se Navigator local não estiver disponível
        Get.toNamed(
          AppRoutes.pragasListar,
          arguments: args.toMap(),
        );
      }
    } catch (e) {
      // Navigation error handled silently
    }
  }

  void navigateToCulturasList({String? searchTerm, String? source}) {
    try {
      final args = CulturasListArgs(
        searchTerm: searchTerm,
        source: source ?? 'home_pragas',
      );

      // Validate arguments (always passes for CulturasListArgs but good practice)
      NavigationHelper.validateNavigation(args, AppRoutes.culturasListar);

      // Log navigation attempt
      NavigationHelper.logNavigationAttempt(AppRoutes.culturasListar, args);

      // Navigate with typed arguments
      final context = Get.context;
      if (context != null && Navigator.of(context).canPop()) {
        // Usa Navigator local se disponível
        Navigator.of(context)
            .pushNamed(AppRoutes.culturasListar, arguments: args.toMap());
      } else {
        // Fallback para GetX se Navigator local não estiver disponível
        Get.toNamed(
          AppRoutes.culturasListar,
          arguments: args.toMap(),
        );
      }
    } catch (e) {
      // Navigation error handled silently
    }
  }

  // Navigation helpers with different praga types
  void navigateToInsetos() {
    navigateToPragasList('1', source: 'home_pragas_insetos_card');
  }

  void navigateToDoencas() {
    navigateToPragasList('2', source: 'home_pragas_doencas_card');
  }

  void navigateToPlantasDaninhas() {
    navigateToPragasList('3', source: 'home_pragas_plantas_card');
  }

  // Enhanced navigation with error handling and recovery
  void navigateWithErrorHandling(String routeName, NavigationArgs? args) {
    try {
      final context = Get.context;
      if (context != null && Navigator.of(context).canPop()) {
        // Usa Navigator local se disponível
        if (args != null) {
          args.validate();
          NavigationHelper.logNavigationAttempt(routeName, args);
          Navigator.of(context).pushNamed(routeName, arguments: args.toMap());
        } else {
          NavigationHelper.logNavigationAttempt(routeName, null);
          Navigator.of(context).pushNamed(routeName);
        }
      } else {
        // Fallback para GetX se Navigator local não estiver disponível
        if (args != null) {
          args.validate();
          NavigationHelper.logNavigationAttempt(routeName, args);
          Get.toNamed(routeName, arguments: args.toMap());
        } else {
          NavigationHelper.logNavigationAttempt(routeName, null);
          Get.toNamed(routeName);
        }
      }
    } catch (e) {
      // Could show user-friendly error message here
      _handleNavigationError(routeName, e);
    }
  }

  void _handleNavigationError(String routeName, dynamic error) {
    // Could implement fallback navigation or show error dialog
    // For now, just log the error
    debugPrint('   Error details: $error');
  }

  // CAROUSEL METHODS
  void onCarouselPageChanged(int index) {
    _homeData.value = _homeData.value.copyWith(carouselCurrentIndex: index);
  }

  void animateToCarouselPage(int index) {
    carouselController.animateToPage(index);
  }

  // LAZY LOADING METHODS
  Future<void> loadMoreSuggestedPests() async {
    if (!_hasMoreSuggested.value || _isLoadingMoreSuggested.value) return;
    await loadSuggestedPests(loadMore: true);
  }

  Future<void> loadMoreRecentPests() async {
    if (!_hasMoreRecent.value || _isLoadingMoreRecent.value) return;
    await loadRecentlyAccessedPests(loadMore: true);
  }

  // LAZY LOADING OPTIMIZATION METHODS
  void _checkAndPreloadSuggested(int currentItemsCount) {
    if (currentItemsCount >= _loadThreshold && !_isLoadingMoreSuggested.value) {
      _isNearLoadThreshold.value = true;
      // Preload next batch in background
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_hasMoreSuggested.value) {
          loadMoreSuggestedPests();
        }
      });
    }
  }

  void _checkAndPreloadRecent(int currentItemsCount, int totalItemsCount) {
    if (currentItemsCount >= _loadThreshold &&
        currentItemsCount < totalItemsCount &&
        !_isLoadingMoreRecent.value) {
      _isNearLoadThreshold.value = true;
    }
  }

  // VIRTUAL PAGINATION METHODS
  void onScrollPositionChanged(double scrollPosition, double maxScrollExtent) {
    final threshold =
        maxScrollExtent * PerformanceConstants.scrollLoadThresholdMultiplier;
    if (scrollPosition >= threshold) {
      _isNearLoadThreshold.value = true;
      if (_hasMoreRecent.value && !_isLoadingMoreRecent.value) {
        loadMoreRecentPests();
      }
    }
  }

  // CACHE MANAGEMENT
  void clearCache() {
    _cachedSuggestedItems.clear();
    _cachedRecentItems.clear();
    _suggestedCurrentPage.value = PageConstants.initialPage;
    _recentCurrentPage.value = PageConstants.initialPage;
  }

  // PERFORMANCE OPTIMIZATION: Adaptive cache management
  void _optimizeCacheStrategy() {
    // Start periodic cache cleanup to prevent memory bloat
    _cacheCleanupTimer?.cancel();
    _cacheCleanupTimer =
        Timer.periodic(TimeoutConstants.cacheCleanupInterval, (timer) {
      _performCacheCleanup();
    });
  }

  void _performCacheCleanup() {
    const maxCacheSize = 100; // Adaptive based on device performance

    // Cleanup suggested items cache if too large
    if (_cachedSuggestedItems.length > maxCacheSize) {
      final itemsToKeep = _cachedSuggestedItems.take(maxCacheSize).toList();
      _cachedSuggestedItems.assignAll(itemsToKeep);
    }

    // Cleanup recent items cache if too large
    if (_cachedRecentItems.length > maxCacheSize) {
      final itemsToKeep = _cachedRecentItems.take(maxCacheSize).toList();
      _cachedRecentItems.assignAll(itemsToKeep);
    }
  }

  void optimizeMemoryUsage() {
    // Keep only visible items + buffer in memory
    const maxCacheSize = 100;

    if (_cachedSuggestedItems.length > maxCacheSize) {
      final itemsToKeep = _cachedSuggestedItems.take(maxCacheSize).toList();
      _cachedSuggestedItems.assignAll(itemsToKeep);
    }

    if (_cachedRecentItems.length > maxCacheSize) {
      final itemsToKeep = _cachedRecentItems.take(maxCacheSize).toList();
      _cachedRecentItems.assignAll(itemsToKeep);
    }
  }

  // REFRESH METHOD
  Future<void> refreshData() async {
    try {
      _setLoadingState(LoadingState.loading);
      _hasMoreSuggested.value = true;
      _hasMoreRecent.value = true;

      // Clear cache on refresh for fresh data
      clearCache();

      await _loadData().timeout(
        TimeoutConstants.operationTimeout,
      );

      _setLoadingState(LoadingState.success);
    } catch (e) {
      _setLoadingState(LoadingState.error);
      rethrow;
    }
  }

  @override
  void onClose() {
    // PERFORMANCE OPTIMIZATION: Dispose timers to prevent memory leaks
    _loadDataDebounceTimer?.cancel();
    _preloadSuggestedTimer?.cancel();
    _preloadRecentTimer?.cancel();
    _cacheCleanupTimer?.cancel();

    super.onClose();
  }
}
