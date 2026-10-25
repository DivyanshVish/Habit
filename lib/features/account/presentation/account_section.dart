import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/account/domain/account_domain.dart';

/// The words shown before an account change. An account that is not linked to
/// Google exists only on this phone, so leaving it loses everything. The text
/// says so plainly, and the button says so too.
class AccountChangeCopy {
  const AccountChangeCopy({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.losesData,
  });

  final String title;
  final String message;
  final String confirmLabel;

  /// True when the data cannot be recovered afterwards.
  final bool losesData;

  factory AccountChangeCopy.signOut(GoogleLinkState state) {
    if (!state.linked) {
      return const AccountChangeCopy(
        title: 'Sign out and lose your data?',
        message:
            'This account is only on this phone and is not linked to a '
            'Google account. If you sign out, your habits, groups and shared '
            'habits cannot be recovered. Link Google first to keep them.',
        confirmLabel: 'Sign out anyway',
        losesData: true,
      );
    }
    return AccountChangeCopy(
      title: 'Sign out?',
      message:
          'Your habits, groups and shared habits stay saved under '
          '${_who(state)}. This phone will start a new guest account. Sign in '
          'with that Google account to get them back.',
      confirmLabel: 'Sign out',
      losesData: false,
    );
  }

  factory AccountChangeCopy.switchAccount(GoogleLinkState state) {
    if (!state.linked) {
      return const AccountChangeCopy(
        title: 'Switch account and lose your data?',
        message:
            'This account is only on this phone and is not linked to a '
            'Google account. If you switch, your habits, groups and shared '
            'habits cannot be recovered. Link Google first to keep them.',
        confirmLabel: 'Switch anyway',
        losesData: true,
      );
    }
    return AccountChangeCopy(
      title: 'Switch account?',
      message:
          'This phone will use a different Google account. ${_who(state)} '
          'keeps its data, and you can switch back any time.',
      confirmLabel: 'Choose account',
      losesData: false,
    );
  }

  /// Moving only makes sense from a Google account. A guest links Google
  /// instead, which keeps everything without moving anything.
  factory AccountChangeCopy.moveData(GoogleLinkState state) {
    return AccountChangeCopy(
      title: 'Move your data to another account?',
      message:
          'Pick the Google account that should receive everything: your '
          'habits and history, your groups (including groups you own), and '
          'your shared habits. That account must be new, with no Habitry data '
          'yet. Afterwards ${_who(state)} is empty. Other members keep '
          'seeing your history under your name.',
      confirmLabel: 'Choose account',
      losesData: false,
    );
  }

  /// Deleting is for good, so the words say exactly what goes and what stays.
  factory AccountChangeCopy.deleteAccount(GoogleLinkState state) {
    return const AccountChangeCopy(
      title: 'Delete your account?',
      message:
          'This removes your habits, history, reminders and settings, and '
          'takes you out of every group and shared habit. It cannot be undone. '
          'Other members keep seeing your past activity under "Deleted user". '
          'If you own a group or shared habit that others still use, hand it '
          'to someone else first.',
      confirmLabel: 'Delete everything',
      losesData: true,
    );
  }

  static String _who(GoogleLinkState state) =>
      state.email == null ? 'your Google account' : state.email!;
}

/// Who is signed in, and the actions for it.
class AccountSection extends StatelessWidget {
  const AccountSection({
    required this.state,
    required this.busy,
    required this.onLink,
    required this.onSwitch,
    required this.onSignOut,
    this.onMove,
    this.onDelete,
    super.key,
  });

  final GoogleLinkState state;
  final bool busy;
  final VoidCallback onLink;
  final VoidCallback onSwitch;
  final VoidCallback onSignOut;

  /// Only offered for a Google account. A guest links Google instead.
  final VoidCallback? onMove;

  /// Deletes the account for good.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.linked
              ? 'Signed in as ${state.email ?? 'your Google account'}. '
                    'Your habits and groups follow you to a new phone.'
              : 'You are using a guest account. Without a Google account your '
                    'data lives on this phone only. Link Google to keep it if '
                    'you reinstall or switch phones.',
          key: const Key('account-status'),
          style: tokens.text.body,
        ),
        if (!state.linked)
          Padding(
            padding: EdgeInsets.only(top: tokens.space.s12),
            child: OutlinedButton(
              onPressed: busy ? null : onLink,
              child: Text(busy ? 'Please wait…' : 'Link Google account'),
            ),
          ),
        SizedBox(height: tokens.space.s12),
        OutlinedButton.icon(
          onPressed: busy ? null : onSwitch,
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: const Text('Switch account'),
        ),
        if (state.linked && onMove != null) ...[
          SizedBox(height: tokens.space.s8),
          OutlinedButton.icon(
            onPressed: busy ? null : onMove,
            icon: const Icon(Icons.drive_file_move_outline, size: 18),
            label: const Text('Move my data to another account'),
          ),
        ],
        SizedBox(height: tokens.space.s8),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: tokens.danger,
            minimumSize: const Size(48, 48),
          ),
          onPressed: busy ? null : onSignOut,
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Sign out'),
        ),
        if (onDelete != null)
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: tokens.danger,
              minimumSize: const Size(48, 48),
            ),
            onPressed: busy ? null : onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete my account'),
          ),
      ],
    );
  }
}
