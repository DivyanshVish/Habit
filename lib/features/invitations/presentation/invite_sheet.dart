import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';

/// Creates an invitation and shows its code to copy and share.
Future<void> showInviteSheet(
  BuildContext context, {
  required InvitationType type,
  required String targetId,
  required String subject,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        _InviteSheet(type: type, targetId: targetId, subject: subject),
  );
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet({
    required this.type,
    required this.targetId,
    required this.subject,
  });

  final InvitationType type;
  final String targetId;
  final String subject;

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  InvitationCode? _code;
  String? _error;
  bool _busy = false;
  int _ttlHours = 72;

  List<InvitablePerson>? _people;
  final Set<String> _invited = {};

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  /// People the user already shares a group with. Best effort: if it fails,
  /// the list is simply hidden and the code below still works.
  Future<void> _loadPeople() async {
    final result = await getIt<ListInvitablePeople>()(
      ListInvitablePeopleParams(type: widget.type, targetId: widget.targetId),
    );
    if (!mounted) return;
    setState(() => _people = result.getRight().toNullable());
  }

  Future<void> _invite(InvitablePerson person) async {
    if (_busy || _invited.contains(person.uid)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await getIt<InvitePerson>()(
      InvitePersonParams(
        type: widget.type,
        targetId: widget.targetId,
        inviteeUid: person.uid,
        ttlHours: _ttlHours,
      ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold((f) => _error = f.message, (_) => _invited.add(person.uid));
    });
  }

  Future<void> _create() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await getIt<CreateInvitation>()(
      CreateInvitationParams(
        type: widget.type,
        targetId: widget.targetId,
        maxUses: widget.type == InvitationType.group ? 10 : 1,
        ttlHours: _ttlHours,
      ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold((f) => _error = f.message, (code) => _code = code);
    });
  }

  Future<void> _revoke() async {
    final code = _code;
    if (code == null || _busy) return;
    setState(() => _busy = true);
    final result = await getIt<RevokeInvitation>()(code.invitationId);
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold((f) => _error = f.message, (_) {
        _code = null;
        showToast(context, 'Invitation cancelled');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final code = _code;
    final isGroup = widget.type == InvitationType.group;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space.screenMargin,
          tokens.space.s24,
          tokens.space.screenMargin,
          tokens.space.s24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Invite to ${widget.subject}',
                  style: tokens.text.dialogTitle,
                ),
              ),
              SizedBox(height: tokens.space.s8),
              Text(
                isGroup
                    ? 'Share this code. It works for up to 10 people.'
                    : 'Share this code with one person.',
                style: tokens.text.body.copyWith(color: tokens.inkMuted),
              ),
              SizedBox(height: tokens.space.s16),
              if (code == null && _people != null && _people!.isNotEmpty) ...[
                Text('PEOPLE YOU KNOW', style: tokens.text.kicker),
                SizedBox(height: tokens.space.s8),
                for (final person in _people!)
                  _PersonRow(
                    key: ValueKey('person-${person.uid}'),
                    person: person,
                    invited: _invited.contains(person.uid),
                    busy: _busy,
                    onInvite: () => _invite(person),
                  ),
                SizedBox(height: tokens.space.s16),
                Text('OR SHARE A CODE', style: tokens.text.kicker),
                SizedBox(height: tokens.space.s8),
              ],
              if (code == null) ...[
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _ttlHours,
                  decoration: const InputDecoration(labelText: 'Expires after'),
                  items: const [
                    DropdownMenuItem(value: 24, child: Text('1 day')),
                    DropdownMenuItem(value: 72, child: Text('3 days')),
                    DropdownMenuItem(value: 168, child: Text('7 days')),
                  ],
                  onChanged: (value) => setState(() => _ttlHours = value ?? 72),
                ),
                SizedBox(height: tokens.space.s16),
                OutlinedButton(
                  onPressed: _busy ? null : _create,
                  child: Text(_busy ? 'Creating…' : 'Create code'),
                ),
              ] else ...[
                Semantics(
                  label: 'Invitation code ${code.code.split('').join(' ')}',
                  child: ExcludeSemantics(
                    // Shrinks instead of overflowing at large text sizes.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        code.code,
                        key: const Key('invite-code'),
                        style: tokens.text.displayNumeral.copyWith(
                          fontSize: 40,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: tokens.space.s12),
                // Wrap, not Row: the app's outlined buttons are full width by
                // default, so they need a finite minimum width here.
                Wrap(
                  spacing: tokens.space.s12,
                  runSpacing: tokens.space.s8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(120, 52),
                      ),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code.code));
                        if (context.mounted) showToast(context, 'Code copied');
                      },
                    ),
                    TextButton(
                      onPressed: _busy ? null : _revoke,
                      child: const Text('Cancel invitation'),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                SizedBox(height: tokens.space.s12),
                Text(
                  _error!,
                  style: tokens.text.body.copyWith(color: tokens.danger),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.person,
    required this.invited,
    required this.busy,
    required this.onInvite,
    super.key,
  });

  final InvitablePerson person;
  final bool invited;
  final bool busy;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          Expanded(
            child: Text(person.displayName, style: tokens.text.rowTitle),
          ),
          // Words, not just a colour: "Invited" or an action.
          if (invited)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 18, color: tokens.accentInk),
                SizedBox(width: tokens.space.s4),
                Text(
                  'Invited',
                  style: tokens.text.body.copyWith(color: tokens.accentInk),
                ),
              ],
            )
          else
            Semantics(
              label: 'Invite ${person.displayName}',
              child: ExcludeSemantics(
                child: TextButton(
                  onPressed: busy ? null : onInvite,
                  child: const Text('Invite'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
