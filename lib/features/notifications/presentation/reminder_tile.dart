import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Unit;
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';
import 'package:habit_tracker/features/notifications/domain/reminders_domain.dart';

/// "Remind me at 18:30" for one habit, with a switch and a time picker. Works
/// for personal, shared and group habits.
class ReminderTile extends StatelessWidget {
  const ReminderTile({required this.target, super.key});

  final ReminderTarget target;

  @override
  Widget build(BuildContext context) {
    // Reminders are an extra. If they are not available, show nothing.
    if (!getIt.isRegistered<WatchReminder>()) return const SizedBox.shrink();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              WatchCubit<ReminderSetting?>(() => getIt<WatchReminder>()(target))
                ..start(),
        ),
        BlocProvider(create: (_) => SubmitCubit<Unit>()),
      ],
      child: _ReminderBody(target: target),
    );
  }
}

class _ReminderBody extends StatelessWidget {
  const _ReminderBody({required this.target});

  final ReminderTarget target;

  static const ReminderSetting _defaults = ReminderSetting(
    enabled: true,
    minutesOfDay: 18 * 60,
  );

  static String format(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  Future<void> _save(BuildContext context, ReminderSetting setting) async {
    final cubit = context.read<SubmitCubit<Unit>>();
    await cubit.submit(
      () => getIt<SaveReminder>()(SaveReminderParams(target, setting)),
    );
    if (context.mounted && cubit.state is SubmitFailed<Unit>) {
      final failed = cubit.state as SubmitFailed<Unit>;
      showErrorSnackBar(context, failed.failure.message);
      cubit.acknowledge();
    }
  }

  Future<void> _pickTime(BuildContext context, ReminderSetting current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current.minutesOfDay ~/ 60,
        minute: current.minutesOfDay % 60,
      ),
    );
    if (picked == null || !context.mounted) return;
    await _save(
      context,
      ReminderSetting(
        enabled: true,
        minutesOfDay: picked.hour * 60 + picked.minute,
        onlyIfIncomplete: current.onlyIfIncomplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = context.watch<WatchCubit<ReminderSetting?>>().state;
    if (state is! ViewLoaded<ReminderSetting?>) {
      // Loading or failed: keep the row's height so nothing jumps.
      return const SizedBox(height: 56);
    }
    final setting = state.data;
    final busy =
        context.watch<SubmitCubit<Unit>>().state is SubmitInProgress<Unit>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Remind me'),
          subtitle: Text(
            setting == null || !setting.enabled
                ? 'Off'
                : 'Every day at ${format(setting.minutesOfDay)}, '
                      'if it is not done yet',
          ),
          value: setting?.enabled ?? false,
          onChanged: busy
              ? null
              : (on) =>
                    _save(context, (setting ?? _defaults).copyWithEnabled(on)),
        ),
        if (setting != null && setting.enabled)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: busy ? null : () => _pickTime(context, setting),
              icon: const Icon(Icons.schedule, size: 18),
              label: Text('Change time (${format(setting.minutesOfDay)})'),
            ),
          ),
        Text(
          'Reminders are sent when notifications are turned on and outside '
          'your quiet hours.',
          style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
        ),
      ],
    );
  }
}

extension on ReminderSetting {
  ReminderSetting copyWithEnabled(bool enabled) => ReminderSetting(
    enabled: enabled,
    minutesOfDay: minutesOfDay,
    onlyIfIncomplete: onlyIfIncomplete,
  );
}
