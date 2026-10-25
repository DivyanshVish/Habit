import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/usecases/group_usecases.dart';
import 'package:habit_tracker/features/groups/presentation/utils/audit_text.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/date_field.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';

/// Who did what in the group: joins, removals, role changes, habit edits.
/// Admins only; the security rules refuse everyone else.
class GroupActivityPage extends StatefulWidget {
  const GroupActivityPage({required this.groupId, super.key});

  final String groupId;

  @override
  State<GroupActivityPage> createState() => _GroupActivityPageState();
}

class _GroupActivityPageState extends State<GroupActivityPage> {
  static const int _pageSize = 30;
  int _limit = _pageSize;

  late final WatchCubit<List<AuditEntry>> _log = WatchCubit<List<AuditEntry>>(
    () => getIt<WatchGroupAudit>()(
      WatchAuditParams(groupId: widget.groupId, limit: _limit),
    ),
  )..start();

  late final WatchCubit<GroupOverview> _overview = WatchCubit<GroupOverview>(
    () => getIt<WatchGroupOverview>()(
      WatchGroupOverviewParams(
        groupId: widget.groupId,
        myUid: getIt<UserIdProvider>().currentUserId ?? '',
      ),
    ),
  )..start();

  @override
  void dispose() {
    _log.close();
    _overview.close();
    super.dispose();
  }

  void _showMore() {
    setState(() => _limit += _pageSize);
    _log.reload();
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview.state;
    final names = overview is ViewLoaded<GroupOverview>
        ? {for (final m in overview.data.members) m.uid: m.displayName}
        : <String, String>{};
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _log),
        BlocProvider.value(value: _overview),
      ],
      child: BlocBuilder<WatchCubit<GroupOverview>, ViewState<GroupOverview>>(
        builder: (context, state) {
          final known = state is ViewLoaded<GroupOverview>
              ? {for (final m in state.data.members) m.uid: m.displayName}
              : names;
          return ViewStateBuilder<List<AuditEntry>>(
            standalone: true,
            builder: (context, entries) => CollabScaffold(
              kicker: 'ADMINS ONLY',
              title: 'Activity',
              children: [
                if (entries.isEmpty)
                  const EmptyView(message: 'Nothing has happened yet.')
                else
                  for (final entry in entries)
                    _Line(
                      key: ValueKey(entry.id),
                      text: describeAudit(entry, known),
                      at: entry.at,
                    ),
                if (entries.length >= _limit)
                  Padding(
                    padding: EdgeInsets.only(top: context.tokens.space.s12),
                    child: OutlinedButton(
                      onPressed: _showMore,
                      child: const Text('Show older'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.text, required this.at, super.key});

  final String text;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final when = at == null
        ? ''
        : '${DateField.format(DateKey.fromDateTime(at!))}, '
              '${at!.hour.toString().padLeft(2, '0')}:'
              '${at!.minute.toString().padLeft(2, '0')}';
    return Semantics(
      label: '$text. $when',
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.space.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: tokens.text.body),
              if (when.isNotEmpty)
                Text(
                  when,
                  style: tokens.text.caption.copyWith(color: tokens.inkMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
