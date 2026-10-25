import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';

void main() {
  group('WatchCubit', () {
    blocTest<WatchCubit<int>, ViewState<int>>(
      'emits loading, then each value',
      build: () =>
          WatchCubit<int>(() => Stream.fromIterable([right(1), right(2)])),
      act: (cubit) => cubit.start(),
      expect: () => [
        isA<ViewLoading<int>>(),
        isA<ViewLoaded<int>>().having((s) => s.data, 'data', 1),
        isA<ViewLoaded<int>>().having((s) => s.data, 'data', 2),
      ],
    );

    blocTest<WatchCubit<int>, ViewState<int>>(
      'reports a failure',
      build: () =>
          WatchCubit<int>(() => Stream.value(left(const Failure.network()))),
      act: (cubit) => cubit.start(),
      expect: () => [
        isA<ViewLoading<int>>(),
        isA<ViewFailure<int>>().having(
          (s) => s.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      ],
    );

    blocTest<WatchCubit<int>, ViewState<int>>(
      'retry opens a fresh subscription',
      build: () {
        var attempt = 0;
        return WatchCubit<int>(() {
          attempt++;
          return Stream.value(
            attempt == 1 ? left(const Failure.network()) : right(7),
          );
        });
      },
      act: (cubit) async {
        cubit.start();
        await Future<void>.delayed(Duration.zero);
        cubit.retry();
      },
      expect: () => [
        isA<ViewLoading<int>>(),
        isA<ViewFailure<int>>(),
        isA<ViewLoading<int>>(),
        isA<ViewLoaded<int>>().having((s) => s.data, 'data', 7),
      ],
    );

    test('reload keeps showing the data until the new data arrives', () async {
      var limit = 1;
      final controllers = <StreamController<Either<Failure, int>>>[];
      final cubit = WatchCubit<int>(() {
        final controller = StreamController<Either<Failure, int>>();
        controllers.add(controller);
        return controller.stream;
      });
      final states = <ViewState<int>>[];
      final sub = cubit.stream.listen(states.add);

      cubit.start();
      controllers.last.add(right(limit));
      await Future<void>.delayed(Duration.zero);
      limit = 2;
      cubit.reload();
      await Future<void>.delayed(Duration.zero);
      controllers.last.add(right(limit));
      await Future<void>.delayed(Duration.zero);

      // Loading once at the start, then 1, then 2: never back to loading.
      expect(states.whereType<ViewLoading<int>>(), hasLength(1));
      expect(states.whereType<ViewLoaded<int>>().map((s) => s.data), [1, 2]);
      await sub.cancel();
      await cubit.close();
      for (final c in controllers) {
        await c.close();
      }
    });

    test('closing cancels the underlying subscription', () async {
      var cancelled = false;
      final controller = StreamController<Either<Failure, int>>(
        onCancel: () => cancelled = true,
      );
      final cubit = WatchCubit<int>(() => controller.stream)..start();

      await cubit.close();

      expect(cancelled, isTrue);
      await controller.close();
    });
  });

  group('SubmitCubit', () {
    blocTest<SubmitCubit<String>, SubmitState<String>>(
      'goes in progress, then success',
      build: SubmitCubit<String>.new,
      act: (cubit) => cubit.submit(() async => right('done')),
      expect: () => [
        isA<SubmitInProgress<String>>(),
        isA<SubmitSuccess<String>>().having((s) => s.result, 'result', 'done'),
      ],
    );

    blocTest<SubmitCubit<String>, SubmitState<String>>(
      'reports a failure and can be acknowledged',
      build: SubmitCubit<String>.new,
      act: (cubit) async {
        await cubit.submit(
          () async => left(const Failure.validation(message: 'nope')),
        );
        cubit.acknowledge();
      },
      expect: () => [
        isA<SubmitInProgress<String>>(),
        isA<SubmitFailed<String>>(),
        isA<SubmitIdle<String>>(),
      ],
    );

    test('a second submit while one is running is ignored', () async {
      final cubit = SubmitCubit<int>();
      final gate = Completer<Either<Failure, int>>();
      var runs = 0;

      final first = cubit.submit(() {
        runs++;
        return gate.future;
      });
      await cubit.submit(() async {
        runs++;
        return right(2);
      });
      gate.complete(right(1));
      await first;

      expect(runs, 1);
      expect((cubit.state as SubmitSuccess<int>).result, 1);
      await cubit.close();
    });
  });
}
