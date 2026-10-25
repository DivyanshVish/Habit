import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either, Unit;
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_habit_detail.dart';
import 'package:habit_tracker/features/groups/domain/usecases/group_usecases.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/cycle_progress_block.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/date_field.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/emblem_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/history_card.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/rule_editor.dart';
import 'package:habit_tracker/features/invitations/presentation/pending_invitations.dart';
import 'package:habit_tracker/features/notifications/domain/reminders_domain.dart';
import 'package:habit_tracker/features/notifications/presentation/reminder_tile.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';
import 'package:habit_tracker/features/invitations/presentation/invite_sheet.dart';

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WatchCubit<List<GroupMembership>>(
        () => getIt<WatchMemberships>()(const NoParams()),
      )..start(),
      child: const _GroupsView(),
    );
  }
}

class _GroupsView extends StatelessWidget {
  const _GroupsView();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ViewStateBuilder<List<GroupMembership>>(
          builder: (context, groups) => ListView(
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
                  'Groups',
                  style: tokens.text.displayTitle.copyWith(fontSize: 40),
                ),
              ),
              SizedBox(height: tokens.space.s16),
              const PendingInvitationsSection(),
              if (groups.isEmpty)
                const EmptyView(
                  message: 'No groups yet. Create one or join with a code.',
                )
              else
                for (final group in groups)
                  InfoRow(
                    key: ValueKey(group.groupId),
                    leading: EmblemAvatar(emblem: group.emblem, size: 40),
                    title: group.groupName,
                    subtitle: group.groupArchived
                        ? 'Archived'
                        : switch (group.role) {
                            MemberRole.owner => 'Owner',
                            MemberRole.admin => 'Admin',
                            MemberRole.member => 'Member',
                          },
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(AppRoutes.groupDetail(group.groupId)),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.join),
                child: const Text('Join with code'),
              ),
            ),
            SizedBox(width: tokens.space.s12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.groupNew),
                child: const Text('New group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Create group
// ---------------------------------------------------------------------------

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SubmitCubit<String>(),
    child: const _CreateGroupForm(),
  );
}

class _CreateGroupForm extends StatefulWidget {
  const _CreateGroupForm();

  @override
  State<_CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<_CreateGroupForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  bool _membersCanInvite = false;
  bool _requireApproval = false;
  GroupEmblem _emblem = GroupEmblem.fallback;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = isSubmitting<String>(context);
    return SubmitListener<String>(
      onSuccess: (context, id) =>
          context.pushReplacement(AppRoutes.groupDetail(id)),
      child: CollabScaffold(
        kicker: 'NEW',
        title: 'Create a group',
        close: true,
        bottom: BottomAction(
          child: OutlinedButton(
            onPressed: busy
                ? null
                : () => context.read<SubmitCubit<String>>().submit(
                    () => getIt<CreateGroup>()(
                      CreateGroupParams(
                        name: _name.text,
                        description: _description.text,
                        membersCanInvite: _membersCanInvite,
                        requireApproval: _requireApproval,
                        emblem: _emblem,
                      ),
                    ),
                  ),
            child: Text(busy ? 'Creating…' : 'Create group'),
          ),
        ),
        children: [
          TextField(
            controller: _name,
            maxLength: GroupRules.nameMax,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Group name'),
          ),
          TextField(
            controller: _description,
            maxLength: GroupRules.descriptionMax,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
            ),
          ),
          const SectionLabel('Picture'),
          EmblemPicker(
            value: _emblem,
            onChanged: (value) => setState(() => _emblem = value),
          ),
          const SectionLabel('Who can join'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Members can invite others'),
            subtitle: const Text('Otherwise only admins can.'),
            value: _membersCanInvite,
            onChanged: (value) => setState(() => _membersCanInvite = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Approve new members'),
            subtitle: const Text(
              'People who use a code wait until an admin lets them in.',
            ),
            value: _requireApproval,
            onChanged: (value) => setState(() => _requireApproval = value),
          ),
          Text(
            'Groups are private. Only people with your code can join.',
            style: context.tokens.text.italicNote.copyWith(
              color: context.tokens.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group detail
// ---------------------------------------------------------------------------

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final myUid = getIt<UserIdProvider>().currentUserId ?? '';
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WatchCubit<GroupOverview>(
            () => getIt<WatchGroupOverview>()(
              WatchGroupOverviewParams(groupId: groupId, myUid: myUid),
            ),
          )..start(),
        ),
        BlocProvider(create: (_) => SubmitCubit<Unit>()),
      ],
      child: _GroupDetailView(groupId: groupId, myUid: myUid),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView({required this.groupId, required this.myUid});

  final String groupId;
  final String myUid;

  @override
  Widget build(BuildContext context) {
    return SubmitListener<Unit>(
      child: ViewStateBuilder<GroupOverview>(
        standalone: true,
        loadingVariant: LoadingVariant.detail,
        builder: (context, overview) =>
            _GroupBody(groupId: groupId, myUid: myUid, overview: overview),
      ),
    );
  }
}

class _GroupBody extends StatelessWidget {
  const _GroupBody({
    required this.groupId,
    required this.myUid,
    required this.overview,
  });

  final String groupId;
  final String myUid;
  final GroupOverview overview;

  Future<void> _run(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<Either<Failure, Unit>> Function() action,
  }) async {
    final cubit = context.read<SubmitCubit<Unit>>();
    final ok = await confirmAction(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    );
    if (!ok) return;
    await cubit.submit(action);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final group = overview.group;
    final role = overview.myRole;
    final isAdmin = role.isAdmin;
    final isOwner = role == MemberRole.owner;
    final canInvite = !group.archived && (isAdmin || group.membersCanInvite);
    final busy = isSubmitting<Unit>(context);
    final habits = overview.habits.where((h) => !h.archived).toList();

    return CollabScaffold(
      kicker: group.archived ? 'ARCHIVED' : '${group.memberCount} MEMBERS',
      title: group.name,
      children: [
        Row(
          children: [
            EmblemAvatar(emblem: group.emblem, size: 56),
            SizedBox(width: tokens.space.s12),
            Expanded(
              child: group.description.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      group.description,
                      style: tokens.text.body.copyWith(color: tokens.inkMuted),
                    ),
            ),
          ],
        ),
        if (group.requireApproval)
          Padding(
            padding: EdgeInsets.only(top: tokens.space.s8),
            child: Text(
              'New members need an admin to approve them.',
              style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
            ),
          ),
        if (isAdmin && !group.archived) _JoinRequestsSection(groupId: groupId),
        const SectionLabel('Habits'),
        if (habits.isEmpty)
          Text(
            isAdmin ? 'No habits yet. Add the first one.' : 'No habits yet.',
            style: tokens.text.body.copyWith(color: tokens.inkMuted),
          ),
        for (final habit in habits)
          InfoRow(
            key: ValueKey('habit-${habit.id}'),
            title: habit.name,
            subtitle: habit.groupStreak.current > 0
                ? 'Group streak ${habit.groupStreak.current}'
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.groupHabit(groupId, habit.id)),
          ),
        if (isAdmin && !group.archived)
          Padding(
            padding: EdgeInsets.only(top: tokens.space.s8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add habit'),
              onPressed: () => context.push(AppRoutes.groupHabitNew(groupId)),
            ),
          ),
        const SectionLabel('Members'),
        _MembersList(
          members: overview.members,
          myRole: role,
          myUid: myUid,
          groupId: groupId,
          onAction: (title, message, label, action) => _run(
            context,
            title: title,
            message: message,
            confirmLabel: label,
            action: action,
          ),
        ),
        SizedBox(height: tokens.space.s16),
        if (isAdmin && !group.archived) ...[
          OutlinedButton.icon(
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Group settings'),
            onPressed: () => context.push(AppRoutes.groupSettings(groupId)),
          ),
          SizedBox(height: tokens.space.s8),
        ],
        if (isAdmin)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Activity'),
              onPressed: () => context.push(AppRoutes.groupActivity(groupId)),
            ),
          ),
        if (canInvite)
          OutlinedButton.icon(
            icon: const Icon(Icons.person_add_alt, size: 18),
            label: const Text('Invite with a code'),
            onPressed: () => showInviteSheet(
              context,
              type: InvitationType.group,
              targetId: groupId,
              subject: group.name,
            ),
          ),
        if (!group.archived)
          TextButton(
            onPressed: busy
                ? null
                : () =>
                      _run(
                        context,
                        title: 'Leave this group?',
                        message: isOwner
                            ? 'Owners must transfer ownership first, unless they '
                                  'are the only member.'
                            : 'Your past completions stay in the group history.',
                        confirmLabel: 'Leave',
                        action: () => getIt<LeaveGroup>()(groupId),
                      ).then((_) {
                        if (context.mounted &&
                            context.read<SubmitCubit<Unit>>().state
                                is SubmitSuccess<Unit>) {
                          context.go(AppRoutes.groups);
                        }
                      }),
            child: const Text('Leave group'),
          ),
        if (isOwner && !group.archived)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: tokens.danger),
            onPressed: busy
                ? null
                : () => _run(
                    context,
                    title: 'Archive this group?',
                    message:
                        'All habits are archived. History is kept and '
                        'nobody can add new completions.',
                    confirmLabel: 'Archive',
                    action: () => getIt<ArchiveGroup>()(groupId),
                  ),
            child: const Text('Archive group'),
          ),
      ],
    );
  }
}

/// People who used a code on a group that wants approval. Only admins can read
/// this list (the security rules refuse everyone else), so it is built for
/// admins only.
class _JoinRequestsSection extends StatelessWidget {
  const _JoinRequestsSection({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WatchCubit<List<JoinRequest>>(
            () => getIt<WatchJoinRequests>()(groupId),
          )..start(),
        ),
        BlocProvider(create: (_) => SubmitCubit<Unit>()),
      ],
      child: _JoinRequestsBody(groupId: groupId),
    );
  }
}

class _JoinRequestsBody extends StatelessWidget {
  const _JoinRequestsBody({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WatchCubit<List<JoinRequest>>>().state;
    if (state is! ViewLoaded<List<JoinRequest>> || state.data.isEmpty) {
      return const SizedBox.shrink();
    }
    final busy = isSubmitting<Unit>(context);
    final tokens = context.tokens;

    return SubmitListener<Unit>(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Waiting to join (${state.data.length})'),
          for (final request in state.data)
            Padding(
              key: ValueKey('request-${request.uid}'),
              padding: EdgeInsets.only(bottom: tokens.space.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.displayName, style: tokens.text.rowTitle),
                  Wrap(
                    spacing: tokens.space.s12,
                    runSpacing: tokens.space.s4,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(120, 48),
                        ),
                        onPressed: busy
                            ? null
                            : () => _review(context, request, approve: true),
                        child: const Text('Let in'),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => _review(context, request, approve: false),
                        child: const Text('Decline'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _review(
    BuildContext context,
    JoinRequest request, {
    required bool approve,
  }) {
    context.read<SubmitCubit<Unit>>().submit(
      () => getIt<ReviewJoinRequest>()(
        ReviewJoinRequestParams(
          groupId: groupId,
          uid: request.uid,
          approve: approve,
        ),
      ),
    );
  }
}

/// The first 20 members, with a button for the rest.
class _MembersList extends StatefulWidget {
  const _MembersList({
    required this.members,
    required this.myRole,
    required this.myUid,
    required this.groupId,
    required this.onAction,
  });

  final List<GroupMember> members;
  final MemberRole myRole;
  final String myUid;
  final String groupId;
  final _ConfirmedAction onAction;

  static const int pageSize = 20;

  @override
  State<_MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<_MembersList> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final members = widget.members;
    final shown = _all || members.length <= _MembersList.pageSize
        ? members
        : members.take(_MembersList.pageSize).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final member in shown)
          InfoRow(
            key: ValueKey('member-${member.uid}'),
            title: member.uid == widget.myUid
                ? '${member.displayName} (you)'
                : member.displayName,
            subtitle: switch (member.role) {
              MemberRole.owner => 'Owner',
              MemberRole.admin => 'Admin',
              MemberRole.member => 'Member',
            },
            trailing: _MemberMenu(
              member: member,
              myRole: widget.myRole,
              myUid: widget.myUid,
              groupId: widget.groupId,
              onAction: widget.onAction,
            ),
          ),
        if (shown.length < members.length)
          TextButton(
            onPressed: () => setState(() => _all = true),
            child: Text('Show all ${members.length} members'),
          ),
      ],
    );
  }
}

typedef _ConfirmedAction =
    Future<void> Function(
      String title,
      String message,
      String confirmLabel,
      Future<Either<Failure, Unit>> Function() action,
    );

class _MemberMenu extends StatelessWidget {
  const _MemberMenu({
    required this.member,
    required this.myRole,
    required this.myUid,
    required this.groupId,
    required this.onAction,
  });

  final GroupMember member;
  final MemberRole myRole;
  final String myUid;
  final String groupId;
  final _ConfirmedAction onAction;

  @override
  Widget build(BuildContext context) {
    if (member.uid == myUid || member.role == MemberRole.owner) {
      return const SizedBox.shrink();
    }
    final isOwner = myRole == MemberRole.owner;
    // Admins can only remove plain members. The owner can do everything.
    final canRemove =
        isOwner || (myRole.isAdmin && member.role == MemberRole.member);
    if (!canRemove && !isOwner) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Manage ${member.displayName}',
      onSelected: (value) {
        switch (value) {
          case 'admin':
            onAction(
              'Make ${member.displayName} an admin?',
              'Admins can add habits, invite and remove members.',
              'Make admin',
              () => getIt<SetMemberRole>()(
                SetMemberRoleParams(groupId, member.uid, MemberRole.admin),
              ),
            );
          case 'member':
            onAction(
              'Remove admin rights?',
              '${member.displayName} will become a regular member.',
              'Remove rights',
              () => getIt<SetMemberRole>()(
                SetMemberRoleParams(groupId, member.uid, MemberRole.member),
              ),
            );
          case 'transfer':
            onAction(
              'Transfer ownership?',
              'You become an admin and ${member.displayName} becomes the owner.',
              'Transfer',
              () => getIt<TransferGroupOwnership>()(
                MemberTarget(groupId, member.uid),
              ),
            );
          case 'remove':
            onAction(
              'Remove ${member.displayName}?',
              'They lose access. Their past completions stay in the history.',
              'Remove',
              () =>
                  getIt<RemoveGroupMember>()(MemberTarget(groupId, member.uid)),
            );
        }
      },
      itemBuilder: (_) => [
        if (isOwner && member.role == MemberRole.member)
          const PopupMenuItem(value: 'admin', child: Text('Make admin')),
        if (isOwner && member.role == MemberRole.admin)
          const PopupMenuItem(
            value: 'member',
            child: Text('Remove admin rights'),
          ),
        if (isOwner)
          const PopupMenuItem(
            value: 'transfer',
            child: Text('Transfer ownership'),
          ),
        if (canRemove)
          const PopupMenuItem(value: 'remove', child: Text('Remove')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// New group habit
// ---------------------------------------------------------------------------

class GroupHabitFormPage extends StatelessWidget {
  const GroupHabitFormPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SubmitCubit<String>(),
    child: _GroupHabitForm(groupId: groupId),
  );
}

class _GroupHabitForm extends StatefulWidget {
  const _GroupHabitForm({required this.groupId});

  final String groupId;

  @override
  State<_GroupHabitForm> createState() => _GroupHabitFormState();
}

class _GroupHabitFormState extends State<_GroupHabitForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};
  CompletionRule _rule = const CompletionRule.majority();
  late DateKey _startDate = getIt<Clock>().today();
  DateKey? _endDate;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final busy = isSubmitting<String>(context);
    final today = getIt<Clock>().today();
    return SubmitListener<String>(
      onSuccess: (context, id) => context.pop(),
      child: CollabScaffold(
        kicker: 'NEW',
        title: 'Group habit',
        close: true,
        bottom: BottomAction(
          child: OutlinedButton(
            onPressed: busy
                ? null
                : () => context.read<SubmitCubit<String>>().submit(
                    () => getIt<CreateGroupHabit>()(
                      CreateGroupHabitParams(
                        groupId: widget.groupId,
                        name: _name.text,
                        description: _description.text,
                        weekdays: _weekdays,
                        target: _rule,
                        startDate: _startDate,
                        endDate: _endDate,
                      ),
                    ),
                  ),
            child: Text(busy ? 'Saving…' : 'Create habit'),
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
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
            ),
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
          const SectionLabel('When'),
          DateField(
            label: 'Starts',
            value: _startDate,
            firstDate: today,
            lastDate: today.plusDays(365 * 2),
            onChanged: (date) => setState(() {
              _startDate = date ?? _startDate;
              final end = _endDate;
              if (end != null && end.isBefore(_startDate)) _endDate = null;
            }),
          ),
          DateField(
            label: 'Ends (optional)',
            value: _endDate,
            optional: true,
            firstDate: _startDate,
            lastDate: _startDate.plusDays(365 * 3),
            onChanged: (date) => setState(() => _endDate = date),
          ),
          SizedBox(height: tokens.space.s12),
          Text(
            'Everyone completes on their own. A member who joins later counts '
            'from the next day.',
            style: tokens.text.italicNote.copyWith(color: tokens.inkMuted),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group habit detail
// ---------------------------------------------------------------------------

class GroupHabitPage extends StatelessWidget {
  const GroupHabitPage({
    required this.groupId,
    required this.habitId,
    super.key,
  });

  final String groupId;
  final String habitId;

  @override
  Widget build(BuildContext context) {
    final myUid = getIt<UserIdProvider>().currentUserId ?? '';
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WatchCubit<GroupHabitDetail>(
            () => getIt<WatchGroupHabitDetail>()(
              GroupHabitRef(groupId: groupId, habitId: habitId),
            ),
          )..start(),
        ),
        BlocProvider(
          create: (_) => WatchCubit<GroupOverview>(
            () => getIt<WatchGroupOverview>()(
              WatchGroupOverviewParams(groupId: groupId, myUid: myUid),
            ),
          )..start(),
        ),
        BlocProvider(create: (_) => SubmitCubit<Unit>()),
      ],
      child: _GroupHabitView(groupId: groupId, habitId: habitId, myUid: myUid),
    );
  }
}

class _GroupHabitView extends StatelessWidget {
  const _GroupHabitView({
    required this.groupId,
    required this.habitId,
    required this.myUid,
  });

  final String groupId;
  final String habitId;
  final String myUid;

  @override
  Widget build(BuildContext context) {
    final overview = context.watch<WatchCubit<GroupOverview>>().state;
    final names = overview is ViewLoaded<GroupOverview>
        ? {for (final m in overview.data.members) m.uid: m.displayName}
        : <String, String>{};
    final isAdmin =
        overview is ViewLoaded<GroupOverview> && overview.data.myRole.isAdmin;

    return SubmitListener<Unit>(
      child: ViewStateBuilder<GroupHabitDetail>(
        standalone: true,
        loadingVariant: LoadingVariant.detail,
        builder: (context, detail) => _GroupHabitBody(
          groupId: groupId,
          habitId: habitId,
          myUid: myUid,
          detail: detail,
          names: names,
          isAdmin: isAdmin,
        ),
      ),
    );
  }
}

class _GroupHabitBody extends StatelessWidget {
  const _GroupHabitBody({
    required this.groupId,
    required this.habitId,
    required this.myUid,
    required this.detail,
    required this.names,
    required this.isAdmin,
  });

  final String groupId;
  final String habitId;
  final String myUid;
  final GroupHabitDetail detail;
  final Map<String, String> names;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final habit = detail.habit;
    final busy = isSubmitting<Unit>(context);
    final stats = detail.personalStats;
    final eligible = detail.isEligible(myUid);

    return CollabScaffold(
      kicker: habit.archived ? 'ARCHIVED' : 'GROUP HABIT',
      title: habit.name,
      bottom: habit.archived
          ? null
          : BottomAction(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => context.read<SubmitCubit<Unit>>().submit(
                        () => getIt<SetGroupCompletion>()(
                          SetGroupCompletionParams(
                            groupId: groupId,
                            habitId: habitId,
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
        if (habit.description.isNotEmpty)
          Text(
            habit.description,
            style: tokens.text.body.copyWith(color: tokens.inkMuted),
          ),
        Text(
          'Target: ${ruleSentence(habit.target)}',
          style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
        ),
        if (habit.pendingFrom != null)
          Text(
            'A schedule change starts on ${habit.pendingFrom}.',
            style: tokens.text.bodySmall.copyWith(color: tokens.accentInk),
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
        if (detail.cycle != null && !eligible)
          Padding(
            padding: EdgeInsets.only(top: tokens.space.s8),
            child: Text(
              'You joined after today started. Your completion is saved but '
              'counts toward the group from tomorrow.',
              key: const Key('not-eligible-note'),
              style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
            ),
          ),
        const SectionLabel('Your history'),
        HistoryCard(history: detail.history),
        const SectionLabel('Streaks'),
        Text(
          'You: current ${stats.currentStreak} · best ${stats.bestStreak} · '
          'rate ${stats.completionRate}% · missed ${stats.missed}',
          key: const Key('personal-stats'),
          style: tokens.text.body,
        ),
        Text(
          'Group: current ${habit.groupStreak.current} · best ${habit.groupStreak.best}',
          key: const Key('group-streak'),
          style: tokens.text.body,
        ),
        Text(
          'Your streak never resets because someone else missed a day.',
          style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
        ),
        if (!habit.archived) ...[
          const SectionLabel('Reminder'),
          ReminderTile(target: GroupReminderTarget(groupId, habitId)),
        ],
        if (isAdmin && !habit.archived) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit habit'),
              onPressed: () =>
                  context.push(AppRoutes.groupHabitEdit(groupId, habitId)),
            ),
          ),
          const SectionLabel('Admin'),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: tokens.danger),
            onPressed: busy
                ? null
                : () async {
                    final cubit = context.read<SubmitCubit<Unit>>();
                    final ok = await confirmAction(
                      context,
                      title: 'Archive this habit?',
                      message:
                          'History and statistics are kept. Nobody can '
                          'add new completions.',
                      confirmLabel: 'Archive',
                    );
                    if (!ok) return;
                    await cubit.submit(
                      () => getIt<ArchiveGroupHabit>()(
                        GroupHabitRef(groupId: groupId, habitId: habitId),
                      ),
                    );
                  },
            child: const Text('Archive habit'),
          ),
        ],
      ],
    );
  }
}
