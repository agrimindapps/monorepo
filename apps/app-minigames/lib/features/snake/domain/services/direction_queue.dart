import '../entities/enums.dart';

/// Input buffer for snake direction changes
/// Queues up to 2 direction inputs to make controls more responsive
/// Prevents rapid input loss on fast-moving snakes
class DirectionQueue {
  final List<Direction> _queue = [];
  static const int maxQueueSize = 2;

  /// Enqueues a new direction if it's valid
  /// Ignores duplicate directions and invalid (opposite) directions
  void enqueue({
    required Direction newDirection,
    required Direction currentDirection,
  }) {
    // Don't queue if already at max capacity
    if (_queue.length >= maxQueueSize) {
      return;
    }

    // Don't queue if it's opposite to current direction
    if (newDirection.isOpposite(currentDirection)) {
      return;
    }

    // Don't queue if it's the same as current direction
    if (newDirection == currentDirection) {
      return;
    }

    // Don't queue duplicate directions already in queue
    if (_queue.contains(newDirection)) {
      return;
    }

    _queue.add(newDirection);
  }

  /// Dequeues and returns the next direction, or null if queue is empty
  Direction? dequeue() {
    return _queue.isNotEmpty ? _queue.removeAt(0) : null;
  }

  /// Peeks at the next direction without removing it
  Direction? peek() {
    return _queue.isNotEmpty ? _queue.first : null;
  }

  /// Clears all queued directions
  void clear() {
    _queue.clear();
  }

  /// Gets the current queue size
  int get size => _queue.length;

  /// Checks if queue is empty
  bool get isEmpty => _queue.isEmpty;

  /// Checks if queue is full
  bool get isFull => _queue.length >= maxQueueSize;
}
