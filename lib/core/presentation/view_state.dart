import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';

/// State of a screen that shows live data.
sealed class ViewState<T> {
  const ViewState();
}

final class ViewLoading<T> extends ViewState<T> {
  const ViewLoading();
}

final class ViewLoaded<T> extends ViewState<T> {
  const ViewLoaded(this.data);

  final T data;
}

final class ViewFailure<T> extends ViewState<T> {
  const ViewFailure(this.failure);

  final Failure failure;
}

/// Subscribes to a use case stream and mirrors it as a [ViewState].
///
/// A failure ends the stream (the repositories do that), so [retry] opens a
/// fresh subscription. Closing the cubit cancels the Firestore listener.
class WatchCubit<T> extends Cubit<ViewState<T>> {
  WatchCubit(this._open) : super(const ViewLoading());

  final Stream<Either<Failure, T>> Function() _open;
  StreamSubscription<Either<Failure, T>>? _subscription;

  void start() {
    unawaited(_subscription?.cancel());
    emit(const ViewLoading());
    _subscription = _open().listen(
      (result) => result.fold(
        (failure) => emit(ViewFailure(failure)),
        (data) => emit(ViewLoaded(data)),
      ),
      onError: (Object _) => emit(const ViewFailure(Failure.unknown())),
    );
  }

  void retry() => start();

  /// Opens the stream again without going back to the loading state, so the
  /// screen keeps showing what it has until the new data arrives. Used when
  /// the query changes (for example "show more").
  void reload() {
    unawaited(_subscription?.cancel());
    _subscription = _open().listen(
      (result) => result.fold(
        (failure) => emit(ViewFailure(failure)),
        (data) => emit(ViewLoaded(data)),
      ),
      onError: (Object _) => emit(const ViewFailure(Failure.unknown())),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

/// State of a one-shot action such as saving a form.
sealed class SubmitState<R> {
  const SubmitState();
}

final class SubmitIdle<R> extends SubmitState<R> {
  const SubmitIdle();
}

final class SubmitInProgress<R> extends SubmitState<R> {
  const SubmitInProgress();
}

final class SubmitSuccess<R> extends SubmitState<R> {
  const SubmitSuccess(this.result);

  final R result;
}

final class SubmitFailed<R> extends SubmitState<R> {
  const SubmitFailed(this.failure);

  final Failure failure;
}

/// Runs one action at a time. A second request while one is running is
/// ignored, which prevents accidental duplicate submissions from double taps.
class SubmitCubit<R> extends Cubit<SubmitState<R>> {
  SubmitCubit() : super(const SubmitIdle());

  Future<void> submit(Future<Either<Failure, R>> Function() action) async {
    if (state is SubmitInProgress<R>) return;
    emit(const SubmitInProgress());
    final result = await action();
    if (isClosed) return;
    emit(result.fold<SubmitState<R>>(SubmitFailed.new, SubmitSuccess.new));
  }

  /// Clears a shown failure so the same message can appear again later.
  void acknowledge() {
    if (state is SubmitFailed<R>) emit(const SubmitIdle());
  }
}
