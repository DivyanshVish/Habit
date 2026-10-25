// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_habit_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupHabitDetail {

 GroupHabit get habit; DateKey get today;/// Null when no cycle is open for [today] (not scheduled, or not opened
/// yet). The member can still tick the habit; it just does not count.
 CycleSnapshot? get cycle; bool get doneToday;/// True while a completion is waiting for the server (offline).
 bool get pendingSync; StreakStats get personalStats;/// Weekly and monthly counts of this person's own completions.
 HistoryBreakdown get history;
/// Create a copy of GroupHabitDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupHabitDetailCopyWith<GroupHabitDetail> get copyWith => _$GroupHabitDetailCopyWithImpl<GroupHabitDetail>(this as GroupHabitDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupHabitDetail&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.today, today) || other.today == today)&&(identical(other.cycle, cycle) || other.cycle == cycle)&&(identical(other.doneToday, doneToday) || other.doneToday == doneToday)&&(identical(other.pendingSync, pendingSync) || other.pendingSync == pendingSync)&&(identical(other.personalStats, personalStats) || other.personalStats == personalStats)&&(identical(other.history, history) || other.history == history));
}


@override
int get hashCode => Object.hash(runtimeType,habit,today,cycle,doneToday,pendingSync,personalStats,history);

@override
String toString() {
  return 'GroupHabitDetail(habit: $habit, today: $today, cycle: $cycle, doneToday: $doneToday, pendingSync: $pendingSync, personalStats: $personalStats, history: $history)';
}


}

/// @nodoc
abstract mixin class $GroupHabitDetailCopyWith<$Res>  {
  factory $GroupHabitDetailCopyWith(GroupHabitDetail value, $Res Function(GroupHabitDetail) _then) = _$GroupHabitDetailCopyWithImpl;
@useResult
$Res call({
 GroupHabit habit, DateKey today, CycleSnapshot? cycle, bool doneToday, bool pendingSync, StreakStats personalStats, HistoryBreakdown history
});


$GroupHabitCopyWith<$Res> get habit;$CycleSnapshotCopyWith<$Res>? get cycle;

}
/// @nodoc
class _$GroupHabitDetailCopyWithImpl<$Res>
    implements $GroupHabitDetailCopyWith<$Res> {
  _$GroupHabitDetailCopyWithImpl(this._self, this._then);

  final GroupHabitDetail _self;
  final $Res Function(GroupHabitDetail) _then;

/// Create a copy of GroupHabitDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habit = null,Object? today = null,Object? cycle = freezed,Object? doneToday = null,Object? pendingSync = null,Object? personalStats = null,Object? history = null,}) {
  return _then(_self.copyWith(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as GroupHabit,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateKey,cycle: freezed == cycle ? _self.cycle : cycle // ignore: cast_nullable_to_non_nullable
as CycleSnapshot?,doneToday: null == doneToday ? _self.doneToday : doneToday // ignore: cast_nullable_to_non_nullable
as bool,pendingSync: null == pendingSync ? _self.pendingSync : pendingSync // ignore: cast_nullable_to_non_nullable
as bool,personalStats: null == personalStats ? _self.personalStats : personalStats // ignore: cast_nullable_to_non_nullable
as StreakStats,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as HistoryBreakdown,
  ));
}
/// Create a copy of GroupHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupHabitCopyWith<$Res> get habit {
  
  return $GroupHabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of GroupHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CycleSnapshotCopyWith<$Res>? get cycle {
    if (_self.cycle == null) {
    return null;
  }

  return $CycleSnapshotCopyWith<$Res>(_self.cycle!, (value) {
    return _then(_self.copyWith(cycle: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupHabitDetail].
extension GroupHabitDetailPatterns on GroupHabitDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupHabitDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupHabitDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupHabitDetail value)  $default,){
final _that = this;
switch (_that) {
case _GroupHabitDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupHabitDetail value)?  $default,){
final _that = this;
switch (_that) {
case _GroupHabitDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GroupHabit habit,  DateKey today,  CycleSnapshot? cycle,  bool doneToday,  bool pendingSync,  StreakStats personalStats,  HistoryBreakdown history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupHabitDetail() when $default != null:
return $default(_that.habit,_that.today,_that.cycle,_that.doneToday,_that.pendingSync,_that.personalStats,_that.history);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GroupHabit habit,  DateKey today,  CycleSnapshot? cycle,  bool doneToday,  bool pendingSync,  StreakStats personalStats,  HistoryBreakdown history)  $default,) {final _that = this;
switch (_that) {
case _GroupHabitDetail():
return $default(_that.habit,_that.today,_that.cycle,_that.doneToday,_that.pendingSync,_that.personalStats,_that.history);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GroupHabit habit,  DateKey today,  CycleSnapshot? cycle,  bool doneToday,  bool pendingSync,  StreakStats personalStats,  HistoryBreakdown history)?  $default,) {final _that = this;
switch (_that) {
case _GroupHabitDetail() when $default != null:
return $default(_that.habit,_that.today,_that.cycle,_that.doneToday,_that.pendingSync,_that.personalStats,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _GroupHabitDetail extends GroupHabitDetail {
  const _GroupHabitDetail({required this.habit, required this.today, required this.cycle, required this.doneToday, required this.pendingSync, required this.personalStats, required this.history}): super._();
  

@override final  GroupHabit habit;
@override final  DateKey today;
/// Null when no cycle is open for [today] (not scheduled, or not opened
/// yet). The member can still tick the habit; it just does not count.
@override final  CycleSnapshot? cycle;
@override final  bool doneToday;
/// True while a completion is waiting for the server (offline).
@override final  bool pendingSync;
@override final  StreakStats personalStats;
/// Weekly and monthly counts of this person's own completions.
@override final  HistoryBreakdown history;

/// Create a copy of GroupHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupHabitDetailCopyWith<_GroupHabitDetail> get copyWith => __$GroupHabitDetailCopyWithImpl<_GroupHabitDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupHabitDetail&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.today, today) || other.today == today)&&(identical(other.cycle, cycle) || other.cycle == cycle)&&(identical(other.doneToday, doneToday) || other.doneToday == doneToday)&&(identical(other.pendingSync, pendingSync) || other.pendingSync == pendingSync)&&(identical(other.personalStats, personalStats) || other.personalStats == personalStats)&&(identical(other.history, history) || other.history == history));
}


@override
int get hashCode => Object.hash(runtimeType,habit,today,cycle,doneToday,pendingSync,personalStats,history);

@override
String toString() {
  return 'GroupHabitDetail(habit: $habit, today: $today, cycle: $cycle, doneToday: $doneToday, pendingSync: $pendingSync, personalStats: $personalStats, history: $history)';
}


}

/// @nodoc
abstract mixin class _$GroupHabitDetailCopyWith<$Res> implements $GroupHabitDetailCopyWith<$Res> {
  factory _$GroupHabitDetailCopyWith(_GroupHabitDetail value, $Res Function(_GroupHabitDetail) _then) = __$GroupHabitDetailCopyWithImpl;
@override @useResult
$Res call({
 GroupHabit habit, DateKey today, CycleSnapshot? cycle, bool doneToday, bool pendingSync, StreakStats personalStats, HistoryBreakdown history
});


@override $GroupHabitCopyWith<$Res> get habit;@override $CycleSnapshotCopyWith<$Res>? get cycle;

}
/// @nodoc
class __$GroupHabitDetailCopyWithImpl<$Res>
    implements _$GroupHabitDetailCopyWith<$Res> {
  __$GroupHabitDetailCopyWithImpl(this._self, this._then);

  final _GroupHabitDetail _self;
  final $Res Function(_GroupHabitDetail) _then;

/// Create a copy of GroupHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habit = null,Object? today = null,Object? cycle = freezed,Object? doneToday = null,Object? pendingSync = null,Object? personalStats = null,Object? history = null,}) {
  return _then(_GroupHabitDetail(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as GroupHabit,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateKey,cycle: freezed == cycle ? _self.cycle : cycle // ignore: cast_nullable_to_non_nullable
as CycleSnapshot?,doneToday: null == doneToday ? _self.doneToday : doneToday // ignore: cast_nullable_to_non_nullable
as bool,pendingSync: null == pendingSync ? _self.pendingSync : pendingSync // ignore: cast_nullable_to_non_nullable
as bool,personalStats: null == personalStats ? _self.personalStats : personalStats // ignore: cast_nullable_to_non_nullable
as StreakStats,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as HistoryBreakdown,
  ));
}

/// Create a copy of GroupHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupHabitCopyWith<$Res> get habit {
  
  return $GroupHabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of GroupHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CycleSnapshotCopyWith<$Res>? get cycle {
    if (_self.cycle == null) {
    return null;
  }

  return $CycleSnapshotCopyWith<$Res>(_self.cycle!, (value) {
    return _then(_self.copyWith(cycle: value));
  });
}
}

// dart format on
