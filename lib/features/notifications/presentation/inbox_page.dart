import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Unit;
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';
import 'package:habit_tracker/features/notifications/domain/notifications_domain.dart';
import 'package:habit_tracker/features/notifications/presentation/inbox_routes.dart';

/// Everything the server told this person, newest first. Push can be off or
/// missed; this list is always complete.
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  static const int _pageSize = 30;
  int _limit = _pageSize;

  late final WatchCubit<List<InboxItem>> _cubit = WatchCubit<List<InboxItem>>(
    () => getIt<WatchInbox>()(WatchInboxParams(limit: _limit)),
  )..start();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showMore() {
    setState(() => _limit += _pageSize);
    _cubit.reload();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocProvider(
        create: (_) => SubmitCubit<Unit>(),
        child: SubmitListener<Unit>(
          child: ViewStateBuilder<List<InboxItem>>(
            standalone: true,
            builder: (context, items) =>
                _InboxBody(items: items, limit: _limit, onShowMore: _showMore),
          ),
        ),
      ),
    );
  }
}

class _InboxBody extends StatelessWidget {
  const _InboxBody({
    required this.items,
    required this.limit,
    required this.onShowMore,
  });

  final List<InboxItem> items;
  final int limit;
  final VoidCallback onShowMore;

  static String when(DateTime? at) {
    if (at == null) return '';
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return '${at.day}/${at.month}/${at.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final unread = items.where((i) => !i.read).length;
    final cubit = context.read<SubmitCubit<Unit>>();

    return CollabScaffold(
      kicker: unread == 0 ? 'ALL CAUGHT UP' : '$unread UNREAD',
      title: 'Inbox',
      topLevel: true,
      children: [
        if (unread > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                await cubit.submit(
                  () => getIt<MarkAllInboxRead>()(const NoParams()),
                );
              },
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all as read'),
            ),
          ),
        if (items.isEmpty)
          const EmptyView(message: 'Nothing here yet.')
        else
          for (final item in items)
            _Row(
              key: ValueKey(item.id),
              item: item,
              onTap: () async {
                final route = inboxRouteFor(item);
                if (!item.read) {
                  await cubit.submit(() => getIt<MarkInboxRead>()(item.id));
                }
                if (route != null && context.mounted) {
                  unawaited(context.push(route));
                }
              },
            ),
        if (items.length >= limit)
          Padding(
            padding: EdgeInsets.only(top: tokens.space.s12),
            child: OutlinedButton(
              onPressed: onShowMore,
              child: const Text('Show older'),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onTap, super.key});

  final InboxItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final time = _InboxBody.when(item.createdAt);
    return Semantics(
      button: true,
      label: '${item.read ? '' : 'Unread. '}${item.title}. ${item.body}. $time',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.space.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unread is a word and a dot, not a colour alone.
                  SizedBox(
                    width: 56,
                    child: item.read
                        ? null
                        : Text(
                            'NEW',
                            style: tokens.text.tiny.copyWith(
                              color: tokens.accentInk,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: tokens.text.rowTitle.copyWith(
                            fontWeight: item.read
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.body,
                          style: tokens.text.bodySmall.copyWith(
                            color: tokens.inkMuted,
                          ),
                        ),
                        if (time.isNotEmpty)
                          Text(
                            time,
                            style: tokens.text.caption.copyWith(
                              color: tokens.inkMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
