import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Unit;
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/usecases/group_usecases.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/emblem_widgets.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';

/// Rename the group, change who may invite, whether new people need approval,
/// and the group's picture. Admins only.
class GroupSettingsPage extends StatelessWidget {
  const GroupSettingsPage({required this.groupId, super.key});

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
      child: ViewStateBuilder<GroupOverview>(
        standalone: true,
        builder: (context, overview) => overview.myRole.isAdmin
            ? SubmitListener<Unit>(
                onSuccess: (context, _) {
                  showToast(context, 'Group updated');
                  context.pop();
                },
                child: _SettingsForm(groupId: groupId, group: overview.group),
              )
            : const CollabScaffold(
                kicker: 'GROUP',
                title: 'Settings',
                children: [Text('Only admins can change the group settings.')],
              ),
      ),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  const _SettingsForm({required this.groupId, required this.group});

  final String groupId;
  final HabitGroup group;

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.group.name,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.group.description,
  );
  late bool _membersCanInvite = widget.group.membersCanInvite;
  late bool _requireApproval = widget.group.requireApproval;
  late GroupEmblem _emblem = widget.group.emblem ?? GroupEmblem.fallback;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Only what changed is sent, so an unchanged field is never overwritten by
  /// an older copy of it.
  UpdateGroupSettingsParams _changes() {
    final group = widget.group;
    final name = _name.text.trim();
    final description = _description.text.trim();
    return UpdateGroupSettingsParams(
      groupId: widget.groupId,
      name: name == group.name ? null : name,
      description: description == group.description ? null : description,
      membersCanInvite: _membersCanInvite == group.membersCanInvite
          ? null
          : _membersCanInvite,
      requireApproval: _requireApproval == group.requireApproval
          ? null
          : _requireApproval,
      emblem: _emblem == (group.emblem ?? GroupEmblem.fallback)
          ? null
          : _emblem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final busy = isSubmitting<Unit>(context);
    return CollabScaffold(
      kicker: 'GROUP',
      title: 'Settings',
      close: true,
      bottom: BottomAction(
        child: OutlinedButton(
          onPressed: busy
              ? null
              : () async {
                  final params = _changes();
                  final nothingChanged =
                      params.name == null &&
                      params.description == null &&
                      params.membersCanInvite == null &&
                      params.requireApproval == null &&
                      params.emblem == null;
                  if (nothingChanged) {
                    context.pop();
                    return;
                  }
                  await context.read<SubmitCubit<Unit>>().submit(
                    () => getIt<UpdateGroupSettings>()(params),
                  );
                },
          child: Text(busy ? 'Saving…' : 'Save'),
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
          decoration: const InputDecoration(labelText: 'Description'),
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
        SizedBox(height: tokens.space.s12),
      ],
    );
  }
}
