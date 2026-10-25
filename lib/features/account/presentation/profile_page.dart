import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/features/account/presentation/account_section.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:go_router/go_router.dart';
import 'package:fpdart/fpdart.dart' show Either, Unit, unit;
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/account/domain/account_domain.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              WatchCubit<Profile>(() => getIt<WatchProfile>()(const NoParams()))
                ..start(),
        ),
        BlocProvider(
          create: (_) => WatchCubit<NotificationSettings>(
            () => getIt<WatchNotificationSettings>()(const NoParams()),
          )..start(),
        ),
        BlocProvider(create: (_) => SubmitCubit<Unit>()),
        BlocProvider(create: (_) => SubmitCubit<GoogleLinkState>()),
        BlocProvider(create: (_) => SubmitCubit<bool>()),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return SubmitListener<Unit>(
      child: SubmitListener<GoogleLinkState>(
        onSuccess: (context, _) => showToast(context, 'Google account linked'),
        child: SubmitListener<bool>(
          onSuccess: (context, enabled) => showToast(
            context,
            enabled
                ? 'Notifications are on for this device'
                : 'Permission was not granted',
          ),
          child: ViewStateBuilder<Profile>(
            standalone: true,
            builder: (context, profile) => _ProfileBody(profile: profile),
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody({required this.profile});

  final Profile profile;

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  late final TextEditingController _name = TextEditingController(
    text: widget.profile.displayName,
  );
  late ActivityVisibility _visibility = widget.profile.visibility;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickTime(
    BuildContext context,
    NotificationSettings settings, {
    required bool start,
  }) async {
    final minutes = start
        ? settings.quietStartMinutes
        : settings.quietEndMinutes;
    final cubit = context.read<SubmitCubit<Unit>>();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (picked == null) return;
    final value = picked.hour * 60 + picked.minute;
    await cubit.submit(
      () => getIt<SaveNotificationSettings>()(
        start
            ? settings.copyWith(quietStartMinutes: value)
            : settings.copyWith(quietEndMinutes: value),
      ),
    );
  }

  static String _format(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  /// Asks first, runs the change, then starts over from Today so every screen
  /// loads the new account's data instead of the old one's.
  Future<void> _changeAccount(
    BuildContext context,
    AccountChangeCopy copy,
    Future<Either<Failure, Unit>> Function() action, {
    required String doneMessage,
  }) async {
    final cubit = context.read<SubmitCubit<Unit>>();
    final router = GoRouter.of(context);
    final confirmed = await confirmAction(
      context,
      title: copy.title,
      message: copy.message,
      confirmLabel: copy.confirmLabel,
    );
    if (!confirmed) return;
    await cubit.submit(action);
    if (!context.mounted || cubit.state is! SubmitSuccess<Unit>) return;
    showToast(context, doneMessage);
    router.go(AppRoutes.today);
  }

  /// Moves everything to another Google account, then starts over from Today.
  /// If the data could not move, the new account is still the one signed in,
  /// so the person is told that in plain words instead of seeing an error.
  Future<void> _moveData(BuildContext context, GoogleLinkState state) async {
    final cubit = context.read<SubmitCubit<Unit>>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final copy = AccountChangeCopy.moveData(state);
    final confirmed = await confirmAction(
      context,
      title: copy.title,
      message: copy.message,
      confirmLabel: copy.confirmLabel,
    );
    if (!confirmed) return;

    late final MoveResult result;
    await cubit.submit(() async {
      final outcome = await getIt<MoveAccountData>()(const NoParams());
      return outcome.map((value) {
        result = value;
        return unit;
      });
    });
    if (!context.mounted || cubit.state is! SubmitSuccess<Unit>) return;

    if (result.outcome == MoveOutcome.moved) {
      showToast(context, 'Your data was moved');
    } else {
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(
            '${result.message ?? 'Your data could not be moved.'} '
            'You are now signed in to the other account. Switch back to '
            'your previous account to see your data.',
          ),
        ),
      );
    }
    router.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final saving = isSubmitting<Unit>(context);
    final linking = isSubmitting<GoogleLinkState>(context);
    final link = getIt<LinkGoogleAccount>();
    final linkState = _linkState();

    return CollabScaffold(
      kicker: 'ACCOUNT',
      title: 'Profile',
      topLevel: true,
      children: [
        TextField(
          controller: _name,
          maxLength: AccountRules.nameMax,
          decoration: const InputDecoration(
            labelText: 'Name others see',
            helperText: 'Shown in groups and shared habits.',
          ),
        ),
        const SectionLabel('Who can see that I completed a habit'),
        RadioGroup<ActivityVisibility>(
          groupValue: _visibility,
          onChanged: (value) => setState(
            () => _visibility = value ?? ActivityVisibility.everyone,
          ),
          child: const Column(
            children: [
              RadioListTile<ActivityVisibility>(
                value: ActivityVisibility.everyone,
                title: Text('Members of my groups'),
                subtitle: Text('They see your name among those who are done.'),
              ),
              RadioListTile<ActivityVisibility>(
                value: ActivityVisibility.countsOnly,
                title: Text('Only the count'),
                subtitle: Text('You are included in the numbers, not named.'),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space.s8),
        OutlinedButton(
          onPressed: saving
              ? null
              : () async {
                  final cubit = context.read<SubmitCubit<Unit>>();
                  await cubit.submit(
                    () => getIt<SaveProfile>()(
                      Profile(displayName: _name.text, visibility: _visibility),
                    ),
                  );
                  if (context.mounted && cubit.state is SubmitSuccess<Unit>) {
                    showToast(context, 'Profile saved');
                  }
                },
          child: Text(saving ? 'Saving…' : 'Save profile'),
        ),
        const SectionLabel('Account'),
        AccountSection(
          state: linkState,
          busy: linking || saving,
          onLink: () => context.read<SubmitCubit<GoogleLinkState>>().submit(
            () => link(const NoParams()),
          ),
          onSwitch: () => _changeAccount(
            context,
            AccountChangeCopy.switchAccount(linkState),
            () => getIt<SwitchAccount>()(const NoParams()),
            doneMessage: 'Switched account',
          ),
          onMove: () => _moveData(context, linkState),
          onDelete: () => _changeAccount(
            context,
            AccountChangeCopy.deleteAccount(linkState),
            () => getIt<DeleteAccount>()(const NoParams()),
            doneMessage: 'Your account was deleted',
          ),
          onSignOut: () => _changeAccount(
            context,
            AccountChangeCopy.signOut(linkState),
            () => getIt<SignOut>()(const NoParams()),
            doneMessage: 'Signed out',
          ),
        ),
        const SectionLabel('Notifications'),
        ViewStateBuilder<NotificationSettings>(
          builder: (context, settings) => _NotificationSettingsView(
            settings: settings,
            format: _format,
            onPickTime: (start) => _pickTime(context, settings, start: start),
          ),
        ),
      ],
    );
  }

  GoogleLinkState _linkState() => getIt<AccountRepository>().googleLinkState;
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView({
    required this.settings,
    required this.format,
    required this.onPickTime,
  });

  final NotificationSettings settings;
  final String Function(int minutes) format;
  final void Function(bool start) onPickTime;

  Future<void> _save(BuildContext context, NotificationSettings next) {
    return context.read<SubmitCubit<Unit>>().submit(
      () => getIt<SaveNotificationSettings>()(next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Push notifications'),
          value: settings.push,
          onChanged: (value) => _save(context, settings.copyWith(push: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Invitations'),
          value: settings.invitations,
          onChanged: (value) =>
              _save(context, settings.copyWith(invitations: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Group milestones'),
          value: settings.milestones,
          onChanged: (value) =>
              _save(context, settings.copyWith(milestones: value)),
        ),
        InfoRow(
          title: 'Quiet hours start',
          trailing: Text(
            format(settings.quietStartMinutes),
            style: tokens.text.numeral,
          ),
          onTap: () => onPickTime(true),
        ),
        InfoRow(
          title: 'Quiet hours end',
          trailing: Text(
            format(settings.quietEndMinutes),
            style: tokens.text.numeral,
          ),
          onTap: () => onPickTime(false),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.read<SubmitCubit<bool>>().submit(
              () => getIt<RegisterForPush>()(const NoParams()),
            ),
            child: const Text('Turn on notifications for this device'),
          ),
        ),
      ],
    );
  }
}
