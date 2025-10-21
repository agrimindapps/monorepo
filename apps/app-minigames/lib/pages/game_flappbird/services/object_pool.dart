abstract class Poolable {
  void reset();
  bool get isInUse;
  void setInUse(bool inUse);
}

class ObjectPool<T extends Poolable> {
  final List<T> _pool = [];
  final T Function() _createFunction;
  final int _maxSize;

  ObjectPool({
    required T Function() createFunction,
    int maxSize = 20,
  }) : _createFunction = createFunction, _maxSize = maxSize;

  T acquire() {
    // Try to find an unused object in the pool
    for (final obj in _pool) {
      if (!obj.isInUse) {
        obj.setInUse(true);
        return obj;
      }
    }

    // If no unused object is found and pool is not at max capacity, create new one
    if (_pool.length < _maxSize) {
      final newObj = _createFunction();
      newObj.setInUse(true);
      _pool.add(newObj);
      return newObj;
    }

    // If pool is at max capacity, reuse the oldest object
    final obj = _pool.removeAt(0);
    obj.reset();
    obj.setInUse(true);
    _pool.add(obj);
    return obj;
  }

  void release(T obj) {
    if (_pool.contains(obj)) {
      obj.reset();
      obj.setInUse(false);
    }
  }

  void clear() {
    _pool.clear();
  }

  int get poolSize => _pool.length;
  int get activeCount => _pool.where((obj) => obj.isInUse).length;
}