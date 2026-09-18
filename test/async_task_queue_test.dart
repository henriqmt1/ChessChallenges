import 'dart:async';

import 'package:chess_chalenges/core/async/async_task_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serial queue continues after a failed task', () async {
    final queue = AsyncTaskQueue();
    final events = <String>[];

    await expectLater(
      queue.add<void>(() async {
        events.add('first');
        throw StateError('expected');
      }),
      throwsStateError,
    );
    await queue.add<void>(() async => events.add('second'));

    expect(events, ['first', 'second']);
  });

  test('latest value queue skips stale snapshots while writing', () async {
    final firstWrite = Completer<void>();
    final written = <int>[];
    final queue = LatestValueQueue<int>((value) async {
      written.add(value);
      if (value == 1) {
        await firstWrite.future;
      }
    });

    queue.add(1);
    queue.add(2);
    queue.add(3);
    firstWrite.complete();
    await queue.idle;

    expect(written, [1, 3]);
  });
}
