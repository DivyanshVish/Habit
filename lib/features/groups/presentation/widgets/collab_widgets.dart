import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/app_top_bar.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';

/// Page frame used by the collaboration screens: back button, a small label,
/// a serif title, then the body. Scrolls as one so large text never overflows.
class CollabScaffold extends StatelessWidget {
  const CollabScaffold({
    required this.kicker,
    required this.title,
    required this.children,
    this.bottom,
    this.close = false,
    this.topLevel = false,
    super.key,
  });

  final String kicker;
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  final bool close;

  /// A page reached from the bottom bar has nothing to go back to.
  final bool topLevel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        // With a bottom bar, that bar already sits above the system buttons.
        // Without one, the list itself must stop above them.
        bottom: bottom == null,
        child: ListView(
          padding: EdgeInsets.only(bottom: tokens.space.s32),
          children: [
            if (topLevel)
              SizedBox(height: tokens.space.s48)
            else
              AppTopBar(close: close),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space.screenMargin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kicker, style: tokens.text.kicker),
                  SizedBox(height: tokens.space.s8),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: tokens.text.headline.copyWith(
                        fontSize: 36,
                        height: 1.1,
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.space.s16),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottom,
    );
  }
}

/// Builds the right thing for each [ViewState]: skeleton, error with retry, or
/// the loaded content.
///
/// Set [standalone] when this is the root of a page (the loaded content brings
/// its own `Scaffold`). The loading and error states then get the same frame:
/// background, back button, safe area. Without that, the page has no
/// background while loading and the screen flashes when the data arrives.
class ViewStateBuilder<T> extends StatelessWidget {
  const ViewStateBuilder({
    required this.builder,
    this.loadingVariant = LoadingVariant.list,
    this.standalone = false,
    super.key,
  });

  final Widget Function(BuildContext context, T data) builder;
  final LoadingVariant loadingVariant;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchCubit<T>, ViewState<T>>(
      builder: (context, state) => switch (state) {
        ViewLoading() =>
          standalone
              ? _FramedLoading(variant: loadingVariant)
              : LoadingView(variant: loadingVariant),
        ViewFailure(:final failure) => _framed(_errorFor(context, failure)),
        ViewLoaded(:final data) => builder(context, data),
      },
    );
  }

  /// Losing access while a screen is open (removed from a group, or it was
  /// archived or deleted) is not something retrying fixes, so the page says so
  /// and offers a way out instead of a generic error.
  Widget _errorFor(BuildContext context, Failure failure) {
    if (standalone &&
        (failure is UnauthenticatedFailure || failure is NotFoundFailure)) {
      final gone = failure is NotFoundFailure;
      return ErrorView(
        kicker: gone ? 'NO LONGER HERE' : 'ACCESS CHANGED',
        title: gone ? 'Not found' : 'No access',
        message: gone
            ? 'This was deleted or is no longer available.'
            : 'You may have been removed, or this was archived. '
                  'Nothing you did is lost.',
        icon: Icons.lock_outline,
        actionLabel: 'Go back',
        onRetry: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.today),
      );
    }
    return ErrorView(
      message: failure.message,
      onRetry: context.read<WatchCubit<T>>().retry,
    );
  }

  Widget _framed(Widget child) {
    if (!standalone) return child;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Page frame plus a skeleton that appears only if loading takes longer than
/// [grace]. Data usually comes straight from the local cache, and a skeleton
/// that shows for a single frame reads as a flicker.
class _FramedLoading extends StatefulWidget {
  const _FramedLoading({required this.variant});

  final LoadingVariant variant;

  static const Duration grace = Duration(milliseconds: 150);

  @override
  State<_FramedLoading> createState() => _FramedLoadingState();
}

class _FramedLoadingState extends State<_FramedLoading> {
  bool _showSkeleton = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_FramedLoading.grace, () {
      if (mounted) setState(() => _showSkeleton = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(),
            Expanded(
              child: _showSkeleton
                  ? LoadingView(variant: widget.variant)
                  : const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a failure once as a snackbar, then clears it.
class SubmitListener<R> extends StatelessWidget {
  const SubmitListener({required this.child, this.onSuccess, super.key});

  final Widget child;
  final void Function(BuildContext context, R result)? onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubmitCubit<R>, SubmitState<R>>(
      listener: (context, state) {
        if (state is SubmitFailed<R>) {
          showErrorSnackBar(context, state.failure.message);
          context.read<SubmitCubit<R>>().acknowledge();
        } else if (state is SubmitSuccess<R>) {
          onSuccess?.call(context, state.result);
        }
      },
      child: child,
    );
  }
}

/// True while the cubit is running an action. Used to disable buttons.
bool isSubmitting<R>(BuildContext context) =>
    context.watch<SubmitCubit<R>>().state is SubmitInProgress<R>;

/// Asks before a destructive or hard-to-undo action. Resolves to true on
/// confirm.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    animationStyle: reduceMotion(context) ? AnimationStyle.noAnimation : null,
    builder: (context) {
      final tokens = context.tokens;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(88, 48),
              foregroundColor: tokens.danger,
              side: BorderSide(color: tokens.danger, width: 1.5),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// Small section label with a hairline above.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(top: tokens.space.s24, bottom: tokens.space.s8),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: tokens.text.kicker.copyWith(color: tokens.inkMuted),
        ),
      ),
    );
  }
}

/// One line: a title and an optional trailing text. At least 48dp tall.
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.space.s8),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: tokens.space.s12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: tokens.text.rowTitle),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: tokens.text.bodySmall.copyWith(
                          color: tokens.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Mon..Sun toggles. Selected days are labelled as well as filled, so state is
/// never shown by colour alone.
class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  static const List<String> _labels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Wrap(
      spacing: tokens.space.s8,
      runSpacing: tokens.space.s8,
      children: [
        for (var day = 1; day <= 7; day++)
          Semantics(
            button: true,
            selected: selected.contains(day),
            label:
                '${_labels[day - 1]}, ${selected.contains(day) ? 'on' : 'off'}',
            child: ExcludeSemantics(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(56, 48),
                  backgroundColor: selected.contains(day)
                      ? tokens.accentTint
                      : null,
                  side: BorderSide(
                    color: selected.contains(day)
                        ? tokens.accent
                        : tokens.outline,
                    width: selected.contains(day) ? 1.5 : 1,
                  ),
                ),
                onPressed: () {
                  final next = {...selected};
                  if (!next.add(day)) next.remove(day);
                  onChanged(next);
                },
                child: Text(
                  selected.contains(day)
                      ? '${_labels[day - 1]} ✓'
                      : _labels[day - 1],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "Waiting to sync" marker. Text plus icon, so it is not colour only.
class PendingSyncBadge extends StatelessWidget {
  const PendingSyncBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      label: 'Waiting to sync',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync, size: 16, color: tokens.accentInk),
            SizedBox(width: tokens.space.s4),
            Text(
              'Waiting to sync',
              style: tokens.text.caption.copyWith(color: tokens.accentInk),
            ),
          ],
        ),
      ),
    );
  }
}
