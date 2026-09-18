import 'dart:async';

typedef AsyncTask<T> = FutureOr<T> Function();

/// Serializes async operations while allowing the caller to await each one.
class AsyncTaskQueue {
  Future<void> _tail = Future<void>.value();

  Future<T> add<T>(AsyncTask<T> task) {
    final operation = _tail.then<T>((_) => task());

    // Keep the queue usable after a failed operation. The failure still goes
    // to the Future returned to the caller.
    _tail = operation.then<void>((_) {}, onError: (_, _) {});
    return operation;
  }

  Future<void> get idle => _tail;
}

/// Persists only the newest pending value, processing writes one at a time.
class LatestValueQueue<T extends Object> {
  LatestValueQueue(this._write);

  final Future<void> Function(T value) _write;
  T? _pending;
  bool _running = false;

  void add(T value) {
    _pending = value;
    if (_running) {
      return;
    }

    _running = true;
    unawaited(_drain());
  }

  Future<void> get idle async {
    while (_running) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<void> _drain() async {
    try {
      while (_pending != null) {
        final value = _pending!;
        _pending = null;

        try {
          await _write(value);
        } on Object {
          // A remote failure should not prevent a newer snapshot from trying.
        }
      }
    } finally {
      _running = false;
      if (_pending != null) {
        add(_pending!);
      }
    }
  }
}
