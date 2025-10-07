import 'dart:async';

/// Manages debounced search operations to prevent excessive calls while a user is typing.
///
/// This utility class introduces a delay after the user stops typing before
/// triggering a search, improving performance and user experience.
class DebouncedSearchManager {
  Timer? _debounceTimer;

  /// The duration to wait before executing the search.
  final Duration debounceDelay;

  /// Creates a new manager with a configurable [debounceDelay].
  /// The default delay is 300 milliseconds.
  DebouncedSearchManager({
    this.debounceDelay = const Duration(milliseconds: 300),
  });

  /// Schedules a search to be executed after the [debounceDelay].
  ///
  /// If another search is scheduled before the delay has passed, the previous
  /// timer is canceled and a new one is started.
  ///
  /// - [query]: The search term to be used.
  /// - [onSearch]: The callback to execute with the [query].
  void search(String query, void Function(String) onSearch) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDelay, () {
      onSearch(query);
    });
  }

  /// Executes a search immediately, canceling any pending debounced search.
  void searchImmediately(String query, void Function(String) onSearch) {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    onSearch(query);
  }

  /// Cancels any pending search operation.
  void cancel() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Returns `true` if a search operation is currently scheduled and pending.
  bool get isPending => _debounceTimer?.isActive == true;

  /// Releases the resources used by the manager.
  ///
  /// It's important to call this method when the manager is no longer needed
  /// to prevent memory leaks from the active [Timer].
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}