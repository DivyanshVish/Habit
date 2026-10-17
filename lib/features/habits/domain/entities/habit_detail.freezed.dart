// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitDetail {

 Habit get habit; HabitStreak get streak;/// The day the screen is showing as "today".
 DateKey get today;
/// Create a copy of HabitDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitDetailCopyWith<HabitDetail> get copyWith => _$HabitDetailCopyWithImpl<HabitDetail>(this as HabitDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetail&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.today, today) || other.today == today));
}


@override
int get hashCode => Object.hash(runtimeType,habit,streak,today);

@override
String toString() {
  return 'HabitDetail(habit: $habit, streak: $streak, today: $today)';
}


}

/// @nodoc
abstract mixin class $HabitDetailCopyWith<$Res>  {
  factory $HabitDetailCopyWith(HabitDetail value, $Res Function(HabitDetail) _then) = _$HabitDetailCopyWithImpl;
@useResult
$Res call({
 Habit habit, HabitStreak streak, DateKey today
});


$HabitCopyWith<$Res> get habit;$HabitStreakCopyWith<$Res> get streak;

}
/// @nodoc
class _$HabitDetailCopyWithImpl<$Res>
    implements $HabitDetailCopyWith<$Res> {
  _$HabitDetailCopyWithImpl(this._self, this._then);

  final HabitDetail _self;
  final $Res Function(HabitDetail) _then;

/// Create a copy of HabitDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habit = null,Object? streak = null,Object? today = null,}) {
  return _then(_self.copyWith(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as HabitStreak,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateKey,
  ));
}
/// Create a copy of HabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of HabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitStreakCopyWith<$Res> get streak {
  
  return $HabitStreakCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitDetail].
extension HabitDetailPatterns on HabitDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitDetail value)  $default,){
final _that = this;
switch (_that) {
case _HabitDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitDetail value)?  $default,){
final _that = this;
switch (_that) {
case _HabitDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Habit habit,  HabitStreak streak,  DateKey today)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitDetail() when $default != null:
return $default(_that.habit,_that.streak,_that.today);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Habit habit,  HabitStreak streak,  DateKey today)  $default,) {final _that = this;
switch (_that) {
case _HabitDetail():
return $default(_that.habit,_that.streak,_that.today);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Habit habit,  HabitStreak streak,  DateKey today)?  $default,) {final _that = this;
switch (_that) {
case _HabitDetail() when $default != null:
return $default(_that.habit,_that.streak,_that.today);case _:
  return null;

}
}

}

/// @nodoc


class _HabitDetail implements HabitDetail {
  const _HabitDetail({required this.habit, required this.streak, required this.today});
  

@override final  Habit habit;
@override final  HabitStreak streak;
/// The day the screen is showing as "today".
@override final  DateKey today;

/// Create a copy of HabitDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitDetailCopyWith<_HabitDetail> get copyWith => __$HabitDetailCopyWithImpl<_HabitDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitDetail&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.today, today) || other.today == today));
}


@override
int get hashCode => Object.hash(runtimeType,habit,streak,today);

@override
String toString() {
  return 'HabitDetail(habit: $habit, streak: $streak, today: $today)';
}


}

/// @nodoc
abstract mixin class _$HabitDetailCopyWith<$Res> implements $HabitDetailCopyWith<$Res> {
  factory _$HabitDetailCopyWith(_HabitDetail value, $Res Function(_HabitDetail) _then) = __$HabitDetailCopyWithImpl;
@override @useResult
$Res call({
 Habit habit, HabitStreak streak, DateKey today
});


@override $HabitCopyWith<$Res> get habit;@override $HabitStreakCopyWith<$Res> get streak;

}
/// @nodoc
class __$HabitDetailCopyWithImpl<$Res>
    implements _$HabitDetailCopyWith<$Res> {
  __$HabitDetailCopyWithImpl(this._self, this._then);

  final _HabitDetail _self;
  final $Res Function(_HabitDetail) _then;

/// Create a copy of HabitDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habit = null,Object? streak = null,Object? today = null,}) {
  return _then(_HabitDetail(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as HabitStreak,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateKey,
  ));
}

/// Create a copy of HabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of HabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitStreakCopyWith<$Res> get streak {
  
  return $HabitStreakCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}

// dart format on
