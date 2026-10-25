import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';

/// Enter a code, see what it is for, then accept or decline.
class JoinPage extends StatelessWidget {
  const JoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SubmitCubit<InvitationPreview>()),
        BlocProvider(create: (_) => SubmitCubit<InvitationResult>()),
      ],
      child: const _JoinView(),
    );
  }
}

class _JoinView extends StatefulWidget {
  const _JoinView();

  @override
  State<_JoinView> createState() => _JoinViewState();
}

class _JoinViewState extends State<_JoinView> {
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _lookUp(BuildContext context) {
    context.read<SubmitCubit<InvitationPreview>>().submit(
      () => getIt<PreviewInvitation>()(_code.text),
    );
  }

  void _respond(BuildContext context, {required bool accept}) {
    context.read<SubmitCubit<InvitationResult>>().submit(
      () => getIt<RespondToInvitation>()(
        RespondToInvitationParams(code: _code.text, accept: accept),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final preview = context.watch<SubmitCubit<InvitationPreview>>().state;
    final responding = isSubmitting<InvitationResult>(context);
    final looking = preview is SubmitInProgress<InvitationPreview>;
    final found = preview is SubmitSuccess<InvitationPreview>
        ? preview.result
        : null;

    return SubmitListener<InvitationPreview>(
      child: SubmitListener<InvitationResult>(
        onSuccess: (context, result) {
          if (!result.accepted) {
            showToast(context, 'Invitation declined');
            context.pop();
            return;
          }
          if (result.pendingApproval) {
            // The group wants an admin to say yes first. Nothing is joined yet.
            showToast(context, 'Request sent. An admin will answer it.');
            context.pop();
            return;
          }
          context.pushReplacement(
            result.type == InvitationType.group
                ? AppRoutes.groupDetail(result.targetId)
                : AppRoutes.sharedDetail(result.targetId),
          );
        },
        child: CollabScaffold(
          kicker: 'JOIN',
          title: 'Enter a code',
          close: true,
          bottom: found == null
              ? BottomAction(
                  child: OutlinedButton(
                    onPressed: looking ? null : () => _lookUp(context),
                    child: Text(looking ? 'Checking…' : 'Look up code'),
                  ),
                )
              : BottomAction(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: responding
                              ? null
                              : () => _respond(context, accept: false),
                          child: const Text('Decline'),
                        ),
                      ),
                      SizedBox(width: tokens.space.s12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: responding
                              ? null
                              : () => _respond(context, accept: true),
                          child: Text(responding ? 'Joining…' : 'Accept'),
                        ),
                      ),
                    ],
                  ),
                ),
          children: [
            TextField(
              controller: _code,
              enabled: found == null,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Invitation code',
                helperText: 'Letters and numbers, as you were given them.',
              ),
              onSubmitted: (_) => _lookUp(context),
            ),
            if (found != null) ...[
              const SectionLabel('Invitation'),
              Text(
                found.type == InvitationType.group ? 'Group' : 'Shared habit',
                style: tokens.text.kicker,
              ),
              SizedBox(height: tokens.space.s4),
              Text(
                found.name,
                key: const Key('preview-name'),
                style: tokens.text.dialogTitle,
              ),
              SizedBox(height: tokens.space.s4),
              Text(
                'Invited by ${found.inviterName}',
                style: tokens.text.body.copyWith(color: tokens.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
