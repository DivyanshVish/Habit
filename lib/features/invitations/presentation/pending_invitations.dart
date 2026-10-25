import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';

/// Invitations made for this person, with Accept and Decline. Shows nothing
/// when there are none, and nothing if the list cannot load: it is a
/// convenience, and a code still works.
class PendingInvitationsSection extends StatelessWidget {
  const PendingInvitationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WatchCubit<List<PendingInvitation>>(
            () => getIt<WatchPendingInvitations>()(const NoParams()),
          )..start(),
        ),
        BlocProvider(create: (_) => SubmitCubit<InvitationResult>()),
      ],
      child: const _Section(),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WatchCubit<List<PendingInvitation>>>().state;
    if (state is! ViewLoaded<List<PendingInvitation>> || state.data.isEmpty) {
      return const SizedBox.shrink();
    }
    final busy = isSubmitting<InvitationResult>(context);
    final tokens = context.tokens;

    return SubmitListener<InvitationResult>(
      onSuccess: (context, result) {
        if (!result.accepted) {
          showToast(context, 'Invitation declined');
        } else if (result.pendingApproval) {
          showToast(context, 'Request sent. An admin will answer it.');
        } else {
          context.push(
            result.type == InvitationType.group
                ? AppRoutes.groupDetail(result.targetId)
                : AppRoutes.sharedDetail(result.targetId),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Invitations for you (${state.data.length})'),
          for (final invite in state.data)
            _InviteCard(
              key: ValueKey(invite.invitationId),
              invite: invite,
              busy: busy,
            ),
          SizedBox(height: tokens.space.s16),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.invite, required this.busy, super.key});

  final PendingInvitation invite;
  final bool busy;

  void _answer(BuildContext context, {required bool accept}) {
    context.read<SubmitCubit<InvitationResult>>().submit(
      () => getIt<RespondToPending>()(
        RespondToPendingParams(
          invitationId: invite.invitationId,
          accept: accept,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final kind = invite.type == InvitationType.group ? 'group' : 'shared habit';
    return Container(
      margin: EdgeInsets.only(bottom: tokens.space.s8),
      padding: EdgeInsets.all(tokens.space.s16),
      decoration: BoxDecoration(
        border: Border.all(color: tokens.accent),
        borderRadius: BorderRadius.circular(tokens.radii.control),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${invite.inviterName} invited you to a $kind',
            style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
          ),
          SizedBox(height: tokens.space.s4),
          Text(invite.targetName, style: tokens.text.rowTitle),
          SizedBox(height: tokens.space.s12),
          // Wrap, not Row: the app's outlined buttons are full width by default.
          Wrap(
            spacing: tokens.space.s12,
            runSpacing: tokens.space.s8,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                ),
                onPressed: busy ? null : () => _answer(context, accept: true),
                child: const Text('Accept'),
              ),
              TextButton(
                onPressed: busy ? null : () => _answer(context, accept: false),
                child: const Text('Decline'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
