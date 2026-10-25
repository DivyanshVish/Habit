import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Unit;
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_habit_detail.dart';
import 'package:habit_tracker/features/groups/domain/usecases/group_usecases.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/date_field.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/rule_editor.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';

/// Edit a group habit. The name and description change at once. A new schedule
/// or target starts two days from now, so days that are already open (in any
/// time zone) are never rewritten.
class GroupHabitEditPage extends StatelessWidget {
  const GroupHabitEditPage({
    required this.groupId,
    required this.habitId,
    super.key,
  });

  final String groupId;
  final String habitId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WatchCubit<GroupHabitDetail>(
            () => getIt<WatchGroupHabitDetail>()(
              GroupHabitRef(groupId: groupId, habitId: habitId),
            ),
          )..start(),
        ),
        BlocProvider(create: (_) => SubmitCubit<Unit>()),
      ],
      child: ViewStateBuilder<GroupHabitDetail>(
        standalone: true,
        builder: (context, detail) => SubmitListener<Unit>(
          onSuccess: (context, _) {
            showToast(context, 'Habit updated');
            context.pop();
          },
          child: _EditForm(
            groupId: groupId,
            habitId: habitId,
            habit: detail.habit,
          ),
        ),
      ),
    );
  }
}

class _EditForm extends StatefulWidget {
  const _EditForm({
    required this.groupId,
    required this.habitId,
    required this.habit,
  });

  final String groupId;
  final String habitId;
  final GroupHabit habit;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.habit.name,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.habit.description,
  );
  late Set<int> _weekdays = {...widget.habit.weekdays};
  late CompletionRule _rule = widget.habit.target;
  late DateKey? _endDate = widget.habit.endDate;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Only what changed is sent.
  UpdateGroupHabitParams _changes() {
    final habit = widget.habit;
    final name = _name.text.trim();
    final description = _description.text.trim();
    final sameDays =
        _weekdays.length == habit.weekdays.length &&
        _weekdays.containsAll(habit.weekdays);
    return UpdateGroupHabitParams(
      groupId: widget.groupId,
      habitId: widget.habitId,
      name: name == habit.name ? null : name,
      description: description == habit.description ? null : description,
      weekdays: sameDays ? null : _weekdays,
      target: _rule == habit.target ? null : _rule,
      endDate: _endDate != habit.endDate ? _endDate : null,
      clearEndDate: _endDate == null && habit.endDate != null,
      startDate: habit.startDate,
    );
  }

  bool _isEmpty(UpdateGroupHabitParams p) =>
      p.name == null &&
      p.description == null &&
      p.weekdays == null &&
      p.target == null &&
      p.endDate == null &&
      !p.clearEndDate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final busy = isSubmitting<Unit>(context);
    final today = getIt<Clock>().today();
    final changes = _changes();
    final scheduleChanges = changes.weekdays != null || changes.target != null;

    return CollabScaffold(
      kicker: 'EDIT',
      title: widget.habit.name,
      close: true,
      bottom: BottomAction(
        child: OutlinedButton(
          onPressed: busy
              ? null
              : () async {
                  final params = _changes();
                  if (_isEmpty(params)) {
                    context.pop();
                    return;
                  }
                  await context.read<SubmitCubit<Unit>>().submit(
                    () => getIt<UpdateGroupHabit>()(params),
                  );
                },
          child: Text(busy ? 'Saving…' : 'Save changes'),
        ),
      ),
      children: [
        TextField(
          controller: _name,
          maxLength: GroupRules.nameMax,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _description,
          maxLength: GroupRules.habitDescriptionMax,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SectionLabel('Days'),
        WeekdayPicker(
          selected: _weekdays,
          onChanged: (days) => setState(() => _weekdays = days),
        ),
        const SectionLabel('The group succeeds when'),
        RuleEditor(
          initial: _rule,
          onChanged: (rule) => setState(() => _rule = rule),
        ),
        const SectionLabel('Ends'),
        DateField(
          label: 'End date (optional)',
          value: _endDate,
          optional: true,
          firstDate: widget.habit.startDate.isAfter(today)
              ? widget.habit.startDate
              : today,
          lastDate: today.plusDays(365 * 3),
          onChanged: (date) => setState(() => _endDate = date),
        ),
        if (widget.habit.pendingFrom != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.space.s12),
            child: Text(
              'A schedule change is already queued and starts on '
              '${DateField.format(widget.habit.pendingFrom!)}. Saving a new '
              'one replaces it.',
              style: tokens.text.bodySmall.copyWith(color: tokens.accentInk),
            ),
          ),
        if (scheduleChanges)
          Padding(
            padding: EdgeInsets.only(top: tokens.space.s12),
            child: Text(
              'New days or a new target start in two days, so today and '
              'tomorrow are not changed for anyone.',
              key: const Key('schedule-note'),
              style: tokens.text.italicNote.copyWith(color: tokens.inkMuted),
            ),
          ),
      ],
    );
  }
}
