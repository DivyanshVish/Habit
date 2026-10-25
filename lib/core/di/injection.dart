import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:habit_tracker/core/auth/firebase_user_id_provider.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/features/account/data/account_repository_impl.dart';
import 'package:habit_tracker/features/account/domain/account_domain.dart';
import 'package:habit_tracker/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:habit_tracker/features/groups/data/repositories/group_repository_impl.dart';
import 'package:habit_tracker/features/groups/domain/repositories/group_repository.dart';
import 'package:habit_tracker/features/groups/domain/services/streak_history_calculator.dart';
import 'package:habit_tracker/features/groups/domain/usecases/group_usecases.dart';
import 'package:habit_tracker/features/invitations/data/invitation_repository_impl.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';
import 'package:habit_tracker/features/notifications/data/inbox_repository_impl.dart';
import 'package:habit_tracker/features/notifications/data/reminder_repository_impl.dart';
import 'package:habit_tracker/features/notifications/domain/notifications_domain.dart';
import 'package:habit_tracker/features/notifications/domain/reminders_domain.dart';
import 'package:habit_tracker/features/shared_habits/data/callable_linked_sync.dart';
import 'package:habit_tracker/features/shared_habits/data/datasources/shared_habit_remote_data_source.dart';
import 'package:habit_tracker/features/shared_habits/domain/linked_toggle.dart';
import 'package:habit_tracker/features/shared_habits/data/repositories/shared_habit_repository_impl.dart';
import 'package:habit_tracker/features/shared_habits/domain/repositories/shared_habit_repository.dart';
import 'package:habit_tracker/features/shared_habits/domain/usecases/shared_habit_usecases.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Composition root. Safe to call more than once (e.g. on bootstrap retry).
void configureDependencies({
  PlatformServices platform = PlatformServices.unavailable,
}) {
  if (getIt.isRegistered<UserIdProvider>()) return;

  // Plugin-backed services (callable functions, Google sign-in, push).
  getIt.registerSingleton<PlatformServices>(platform);
  getIt.registerLazySingleton<CallableClient>(() => platform.callable);
  getIt.registerLazySingleton<AccountLinker>(() => platform.accountLinker);
  getIt.registerLazySingleton<PushMessaging>(() => platform.push);

  // External
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Core
  getIt.registerLazySingleton<Clock>(SystemClock.new);
  getIt.registerLazySingleton<UserIdProvider>(
    () => FirebaseUserIdProvider(getIt<FirebaseAuth>()),
  );

  // Data
  getIt.registerLazySingleton<HabitRemoteDataSource>(
    () => HabitRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      userIdProvider: getIt<UserIdProvider>(),
    ),
  );
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(getIt<HabitRemoteDataSource>()),
  );

  // Domain
  getIt.registerLazySingleton<AddHabit>(
    () => AddHabit(getIt<HabitRepository>(), getIt<Clock>()),
  );

  getIt.registerLazySingleton<WatchTodayOverview>(
    () => WatchTodayOverview(
      getIt<HabitRepository>(),
      getIt<Clock>(),
      getIt<StreakCalculator>(),
    ),
  );
  // Ticking a habit that is shared also tells the server (best effort).
  getIt.registerLazySingleton<LinkedCompletionSync>(
    () => CallableLinkedCompletionSync(getIt<CallableClient>()),
  );
  getIt.registerLazySingleton<ToggleHabitCompletion>(
    () => LinkedToggleHabitCompletion(
      getIt<HabitRepository>(),
      getIt<LinkedCompletionSync>(),
    ),
  );
  getIt.registerLazySingleton<DeleteHabit>(
    () => DeleteHabit(getIt<HabitRepository>()),
  );
  getIt.registerLazySingleton<StreakCalculator>(() => const StreakCalculator());
  getIt.registerLazySingleton<WatchHabitDetail>(
    () => WatchHabitDetail(
      getIt<HabitRepository>(),
      getIt<Clock>(),
      getIt<StreakCalculator>(),
    ),
  );

  _registerCollaboration();

  // Presentation
  getIt.registerFactory<AddHabitBloc>(() => AddHabitBloc(getIt<AddHabit>()));
  getIt.registerFactoryParam<HabitDetailBloc, String, void>(
    (habitId, _) => HabitDetailBloc(
      habitId: habitId,
      watchHabitDetail: getIt<WatchHabitDetail>(),
      toggleHabitCompletion: getIt<ToggleHabitCompletion>(),
      clock: getIt<Clock>(),
    ),
  );
  getIt.registerFactory<TodayBloc>(
    () => TodayBloc(
      watchTodayOverview: getIt<WatchTodayOverview>(),
      toggleHabitCompletion: getIt<ToggleHabitCompletion>(),
      deleteHabit: getIt<DeleteHabit>(),
      clock: getIt<Clock>(),
    ),
  );
}

/// Shared habits, groups, invitations and the account screen.
void _registerCollaboration() {
  // Inbox and reminders
  getIt.registerLazySingleton<InboxRepository>(
    () => InboxRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      userIdProvider: getIt<UserIdProvider>(),
    ),
  );
  getIt.registerLazySingleton<WatchInbox>(
    () => WatchInbox(getIt<InboxRepository>()),
  );
  getIt.registerLazySingleton<WatchUnreadCount>(
    () => WatchUnreadCount(getIt<InboxRepository>()),
  );
  getIt.registerLazySingleton<MarkInboxRead>(
    () => MarkInboxRead(getIt<InboxRepository>()),
  );
  getIt.registerLazySingleton<MarkAllInboxRead>(
    () => MarkAllInboxRead(getIt<InboxRepository>()),
  );
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      userIdProvider: getIt<UserIdProvider>(),
    ),
  );
  getIt.registerLazySingleton<WatchReminder>(
    () => WatchReminder(getIt<ReminderRepository>()),
  );
  getIt.registerLazySingleton<SaveReminder>(
    () => SaveReminder(getIt<ReminderRepository>()),
  );
  getIt.registerLazySingleton<RemoveReminder>(
    () => RemoveReminder(getIt<ReminderRepository>()),
  );

  // Groups
  getIt.registerLazySingleton<GroupRemoteDataSource>(
    () => GroupRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      userIdProvider: getIt<UserIdProvider>(),
      callable: getIt<CallableClient>(),
    ),
  );
  getIt.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(getIt<GroupRemoteDataSource>()),
  );
  getIt.registerLazySingleton<StreakHistoryCalculator>(
    () => const StreakHistoryCalculator(),
  );
  getIt.registerLazySingleton<CreateGroup>(
    () => CreateGroup(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<WatchMemberships>(
    () => WatchMemberships(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<WatchGroupOverview>(
    () => WatchGroupOverview(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<UpdateGroupSettings>(
    () => UpdateGroupSettings(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<WatchJoinRequests>(
    () => WatchJoinRequests(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<ReviewJoinRequest>(
    () => ReviewJoinRequest(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<WatchGroupAudit>(
    () => WatchGroupAudit(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<UpdateGroupHabit>(
    () => UpdateGroupHabit(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<CreateGroupHabit>(
    () => CreateGroupHabit(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<SetGroupCompletion>(
    () => SetGroupCompletion(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<WatchGroupHabitDetail>(
    () => WatchGroupHabitDetail(
      getIt<GroupRepository>(),
      getIt<Clock>(),
      getIt<StreakHistoryCalculator>(),
    ),
  );
  getIt.registerLazySingleton<LeaveGroup>(
    () => LeaveGroup(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<ArchiveGroup>(
    () => ArchiveGroup(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<RemoveGroupMember>(
    () => RemoveGroupMember(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<TransferGroupOwnership>(
    () => TransferGroupOwnership(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<SetMemberRole>(
    () => SetMemberRole(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<ArchiveGroupHabit>(
    () => ArchiveGroupHabit(getIt<GroupRepository>()),
  );

  // Shared habits
  getIt.registerLazySingleton<SharedHabitRemoteDataSource>(
    () => SharedHabitRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      userIdProvider: getIt<UserIdProvider>(),
      callable: getIt<CallableClient>(),
    ),
  );
  getIt.registerLazySingleton<SharedHabitRepository>(
    () => SharedHabitRepositoryImpl(getIt<SharedHabitRemoteDataSource>()),
  );
  getIt.registerLazySingleton<WatchSharedHabits>(
    () => WatchSharedHabits(getIt<SharedHabitRepository>()),
  );
  getIt.registerLazySingleton<WatchSharedHabitDetail>(
    () => WatchSharedHabitDetail(
      getIt<SharedHabitRepository>(),
      getIt<Clock>(),
      getIt<StreakHistoryCalculator>(),
    ),
  );
  getIt.registerLazySingleton<SetSharedCompletion>(
    () => SetSharedCompletion(getIt<SharedHabitRepository>()),
  );
  getIt.registerLazySingleton<CreateSharedHabit>(
    () => CreateSharedHabit(getIt<SharedHabitRepository>()),
  );
  getIt.registerLazySingleton<LeaveSharedHabit>(
    () => LeaveSharedHabit(getIt<SharedHabitRepository>()),
  );

  // Invitations
  getIt.registerLazySingleton<InvitationRepository>(
    () => InvitationRepositoryImpl(
      getIt<CallableClient>(),
      firestore: getIt<FirebaseFirestore>(),
      userIdProvider: getIt<UserIdProvider>(),
    ),
  );
  getIt.registerLazySingleton<CreateInvitation>(
    () => CreateInvitation(getIt<InvitationRepository>()),
  );
  getIt.registerLazySingleton<PreviewInvitation>(
    () => PreviewInvitation(getIt<InvitationRepository>()),
  );
  getIt.registerLazySingleton<RespondToInvitation>(
    () => RespondToInvitation(getIt<InvitationRepository>()),
  );
  getIt.registerLazySingleton<WatchPendingInvitations>(
    () => WatchPendingInvitations(getIt<InvitationRepository>()),
  );
  getIt.registerLazySingleton<InvitePerson>(
    () => InvitePerson(getIt<InvitationRepository>()),
  );
  getIt.registerLazySingleton<ListInvitablePeople>(
    () => ListInvitablePeople(getIt<InvitationRepository>()),
  );
  getIt.registerLazySingleton<RespondToPending>(
    () => RespondToPending(getIt<InvitationRepository>()),
  );
  getIt.registerLazySingleton<RevokeInvitation>(
    () => RevokeInvitation(getIt<InvitationRepository>()),
  );

  // Account
  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      userIdProvider: getIt<UserIdProvider>(),
      callable: getIt<CallableClient>(),
      linker: getIt<AccountLinker>(),
      push: getIt<PushMessaging>(),
    ),
  );
  getIt.registerLazySingleton<WatchProfile>(
    () => WatchProfile(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<SaveProfile>(
    () => SaveProfile(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<LinkGoogleAccount>(
    () => LinkGoogleAccount(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<WatchNotificationSettings>(
    () => WatchNotificationSettings(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<SaveNotificationSettings>(
    () => SaveNotificationSettings(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<RegisterForPush>(
    () => RegisterForPush(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<ReportDeviceTimeZone>(
    () => ReportDeviceTimeZone(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<SignOut>(
    () => SignOut(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<DeleteAccount>(
    () => DeleteAccount(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<MoveAccountData>(
    () => MoveAccountData(getIt<AccountRepository>()),
  );
  getIt.registerLazySingleton<SwitchAccount>(
    () => SwitchAccount(getIt<AccountRepository>()),
  );
}
