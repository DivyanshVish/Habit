import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Unit;
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/cycle_progress_block.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/history_card.dart';
import 'package:habit_tracker/features/notifications/domain/reminders_domain.dart';
import 'package:habit_tracker/features/notifications/presentation/reminder_tile.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';
import 'package:habit_tracker/features/invitations/presentation/invite_sheet.dart';
import 'package:habit_tracker/features/shared_habits/domain/entities/shared_habit_entities.dart';
import 'package:habit_tracker/features/shared_habits/domain/usecases/shared_habit_usecases.dart';

// ---------------------------------------------------------------------------
// List
// ---------------------------------------------------------------------------

class SharedHabitsPage extends StatelessWidget {
  const SharedHabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WatchCubit<List<SharedHabit>>(
        () => getIt<WatchSharedHabits>()(const NoParams()),
      )..start(),
      child: const _SharedHabitsView(),
    );
  }
}

class _SharedHabitsView extends StatelessWidget {
  const _SharedHabitsView();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ViewStateBuilder<List<SharedHabit>>(
          builder: (context, habits) => ListView(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space.screenMargin,
            ),
            children: [
              SizedBox(height: tokens.space.s48),
              Text('TOGETHER', style: tokens.text.kicker),
              SizedBox(height: tokens.space.s8),
              Semantics(
                header: true,
                child: Text(
                  'Shared habits',
                  style: tokens.text.displayTitle.copyWith(fontSize: 40),
                ),
              ),
              SizedBox(height: tokens.space.s16),
              if (habits.isEmpty)
                const EmptyView(
                  message: 'No shared habits yet. Share one with a friend.',
                )
              else
                for (final habit in habits)
                  InfoRow(
                    key: ValueKey(habit.id),
                    title: habit.name,
                    subtitle: habit.archived
                        ? 'Archived'
                        : '${habit.participantCount} '
                              '${habit.participantCount == 1 ? 'person' : 'people'}',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.sharedDetail(habit.id)),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.sharedNew),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Share a habit'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Create
// ---------------------------------------------------------------------------

class SharedHabitFormPage extends StatelessWidget {
  const SharedHabitFormPage({
    this.sourceHabitId,
    this.initialName,
    this.initialPoints,
    super.key,
  });

  /// Set when sharing an existing personal habit.
  final String? sourceHabitId;
  final String? initialName;
  final int? initialPoints;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubmitCubit<String>(),
      child: _SharedHabitForm(
        sourceHabitId: sourceHabitId,
        initialName: initialName,
        initialPoints: initialPoints,
      ),
    );
  }
}

class _SharedHabitForm extends StatefulWidget {
  const _SharedHabitForm({
    this.sourceHabitId,
    this.initialName,
    this.initialPoints,
  });

  final String? sourceHabitId;
  final String? initialName;
  final int? initialPoints;

  @override
  State<_SharedHabitForm> createState() => _SharedHabitFormState();
}

class _SharedHabitFormState extends State<_SharedHabitForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  final TextEditingController _description = TextEditingController();
  late final TextEditingController _points = TextEditingController(
    text: '${widget.initialPoints ?? 10}',
  );
  Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _points.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final points = int.tryParse(_points.text.trim()) ?? 0;
    final params = CreateSharedHabitParams(
      name: _name.text,
      description: _description.text,
      points: points,
      weekdays: _weekdays,
      startDate: getIt<Clock>().today(),
      sourceHabitId: widget.sourceHabitId,
    );
    context.read<SubmitCubit<String>>().submit(
      () => getIt<CreateSharedHabit>()(params),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final busy = isSubmitting<String>(context);
    return SubmitListener<String>(
      onSuccess: (context, id) =>
          context.pushReplacement(AppRoutes.sharedDetail(id)),
      child: CollabScaffold(
        kicker: widget.sourceHabitId == null ? 'NEW' : 'SHARE',
        title: widget.sourceHabitId == null
            ? 'Shared habit'
            : 'Share this habit',
        close: true,
        bottom: BottomAction(
          child: OutlinedButton(
            onPressed: busy ? null : () => _submit(context),
            child: Text(busy ? 'Saving…' : 'Create'),
          ),
        ),
        children: [
          if (widget.sourceHabitId != null)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.space.s12),
              child: Text(
                'Your original habit and its history stay as they are.',
                style: tokens.text.italicNote.copyWith(color: tokens.inkMuted),
              ),
            ),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            maxLength: 60,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _description,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
            ),
          ),
          TextField(
            controller: _points,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Points per completion',
            ),
          ),
          const SectionLabel('Days'),
          WeekdayPicker(
            selected: _weekdays,
            onChanged: (days) => setState(() => _weekdays = days),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail
// ---------------------------------------------------------------------------

class SharedHabitDetailPage extends StatelessWidget {
  const SharedHabitDetailPage({required this.sharedId, super.key});

  final String sharedId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WatchCubit<SharedHabitDetail>(
            () => getIt<WatchSharedHabitDetail>()(sharedId),
          )..start(),
        ),
        BlocProvider(create: (_) => SubmitCubit<Unit>()),
      ],
      child: _SharedHabitDetailView(sharedId: sharedId),
    );
  }
}

class _SharedHabitDetailView extends StatelessWidget {
  const _SharedHabitDetailView({required this.sharedId});

  final String sharedId;

  @override
  Widget build(BuildContext context) {
    return SubmitListener<Unit>(
      onSuccess: (context, _) {},
      child: ViewStateBuilder<SharedHabitDetail>(
        standalone: true,
        loadingVariant: LoadingVariant.detail,
        builder: (context, detail) =>
            _DetailBody(sharedId: sharedId, detail: detail),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.sharedId, required this.detail});

  final String sharedId;
  final SharedHabitDetail detail;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final busy = isSubmitting<Unit>(context);
    final myUid = getIt<UserIdProvider>().currentUserId;
    final isOwner = detail.habit.ownerUid == myUid;
    final names = {for (final p in detail.participants) p.uid: p.displayName};
    final stats = detail.personalStats;

    return CollabScaffold(
      kicker:
          'SHARED · ${detail.habit.participantCount} '
          '${detail.habit.participantCount == 1 ? 'PERSON' : 'PEOPLE'}',
      title: detail.habit.name,
      bottom: detail.habit.archived
          ? null
          : BottomAction(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => context.read<SubmitCubit<Unit>>().submit(
                        () => getIt<SetSharedCompletion>()(
                          SetSharedCompletionParams(
                            sharedId: sharedId,
                            dateKey: detail.today,
                            done: !detail.doneToday,
                          ),
                        ),
                      ),
                child: Text(
                  detail.doneToday ? 'Mark today not done' : 'Mark today done',
                ),
              ),
            ),
      children: [
        if (detail.habit.description.isNotEmpty)
          Text(
            detail.habit.description,
            style: tokens.text.body.copyWith(color: tokens.inkMuted),
          ),
        const SectionLabel('Today'),
        CycleProgressBlock(cycle: detail.cycle, namesByUid: names),
        SizedBox(height: tokens.space.s12),
        Row(
          children: [
            Text(
              detail.doneToday ? 'You: done' : 'You: not done yet',
              style: tokens.text.rowTitle,
            ),
            const Spacer(),
            if (detail.pendingSync) const PendingSyncBadge(),
          ],
        ),
        const SectionLabel('Your streak'),
        Text(
          'Current ${stats.currentStreak} · Best ${stats.bestStreak} · '
          'Rate ${stats.completionRate}% · Missed ${stats.missed}',
          key: const Key('personal-stats'),
          style: tokens.text.body,
        ),
        Text(
          'Other people missing a day never changes your streak.',
          style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
        ),
        const SectionLabel('Your history'),
        HistoryCard(history: detail.history),
        if (!detail.habit.archived) ...[
          const SectionLabel('Reminder'),
          ReminderTile(target: SharedReminderTarget(sharedId)),
        ],
        const SectionLabel('People'),
        for (final person in detail.participants)
          InfoRow(
            key: ValueKey(person.uid),
            title: person.displayName,
            subtitle: person.active ? null : 'Left',
            trailing: person.uid == detail.habit.ownerUid
                ? Text('Owner', style: tokens.text.caption)
                : null,
          ),
        SizedBox(height: tokens.space.s16),
        if (isOwner && !detail.habit.archived)
          OutlinedButton.icon(
            icon: const Icon(Icons.person_add_alt, size: 18),
            label: const Text('Invite someone'),
            onPressed: () => showInviteSheet(
              context,
              type: InvitationType.shared,
              targetId: sharedId,
              subject: detail.habit.name,
            ),
          ),
        if (!detail.habit.archived)
          TextButton(
            onPressed: busy
                ? null
                : () async {
                    final cubit = context.read<SubmitCubit<Unit>>();
                    final ok = await confirmAction(
                      context,
                      title: 'Leave this habit?',
                      message:
                          'Your past completions stay in the history. '
                          'Other people are not affected.',
                      confirmLabel: 'Leave',
                    );
                    if (!ok) return;
                    await cubit.submit(
                      () => getIt<LeaveSharedHabit>()(sharedId),
                    );
                    if (context.mounted && cubit.state is SubmitSuccess<Unit>) {
                      context.go(AppRoutes.shared);
                    }
                  },
            child: const Text('Leave habit'),
          ),
      ],
    );
  }
}
