// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_with_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitWithStatus {

 Habit get habit; bool get isDone; HabitStreak get streak;
/// Create a copy of HabitWithStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitWithStatusCopyWith<HabitWithStatus> get copyWith => _$HabitWithStatusCopyWithImpl<HabitWithStatus>(this as HabitWithStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitWithStatus&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.streak, streak) || other.streak == streak));
}


@override
int get hashCode => Object.hash(runtimeType,habit,isDone,streak);

@override
String toString() {
  return 'HabitWithStatus(habit: $habit, isDone: $isDone, streak: $streak)';
}


}

/// @nodoc
abstract mixin class $HabitWithStatusCopyWith<$Res>  {
  factory $HabitWithStatusCopyWith(HabitWithStatus value, $Res Function(HabitWithStatus) _then) = _$HabitWithStatusCopyWithImpl;
@useResult
$Res call({
 Habit habit, bool isDone, HabitStreak streak
});


$HabitCopyWith<$Res> get habit;$HabitStreakCopyWith<$Res> get streak;

}
/// @nodoc
class _$HabitWithStatusCopyWithImpl<$Res>
    implements $HabitWithStatusCopyWith<$Res> {
  _$HabitWithStatusCopyWithImpl(this._self, this._then);

  final HabitWithStatus _self;
  final $Res Function(HabitWithStatus) _then;

/// Create a copy of HabitWithStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habit = null,Object? isDone = null,Object? streak = null,}) {
  return _then(_self.copyWith(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as HabitStreak,
  ));
}
/// Create a copy of HabitWithStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of HabitWithStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitStreakCopyWith<$Res> get streak {
  
  return $HabitStreakCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitWithStatus].
extension HabitWithStatusPatterns on HabitWithStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitWithStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitWithStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitWithStatus value)  $default,){
final _that = this;
switch (_that) {
case _HabitWithStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitWithStatus value)?  $default,){
final _that = this;
switch (_that) {
case _HabitWithStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Habit habit,  bool isDone,  HabitStreak streak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitWithStatus() when $default != null:
return $default(_that.habit,_that.isDone,_that.streak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Habit habit,  bool isDone,  HabitStreak streak)  $default,) {final _that = this;
switch (_that) {
case _HabitWithStatus():
return $default(_that.habit,_that.isDone,_that.streak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Habit habit,  bool isDone,  HabitStreak streak)?  $default,) {final _that = this;
switch (_that) {
case _HabitWithStatus() when $default != null:
return $default(_that.habit,_that.isDone,_that.streak);case _:
  return null;

}
}

}

/// @nodoc


class _HabitWithStatus implements HabitWithStatus {
  const _HabitWithStatus({required this.habit, required this.isDone, required this.streak});
  

@override final  Habit habit;
@override final  bool isDone;
@override final  HabitStreak streak;

/// Create a copy of HabitWithStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitWithStatusCopyWith<_HabitWithStatus> get copyWith => __$HabitWithStatusCopyWithImpl<_HabitWithStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitWithStatus&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.streak, streak) || other.streak == streak));
}


@override
int get hashCode => Object.hash(runtimeType,habit,isDone,streak);

@override
String toString() {
  return 'HabitWithStatus(habit: $habit, isDone: $isDone, streak: $streak)';
}


}

/// @nodoc
abstract mixin class _$HabitWithStatusCopyWith<$Res> implements $HabitWithStatusCopyWith<$Res> {
  factory _$HabitWithStatusCopyWith(_HabitWithStatus value, $Res Function(_HabitWithStatus) _then) = __$HabitWithStatusCopyWithImpl;
@override @useResult
$Res call({
 Habit habit, bool isDone, HabitStreak streak
});


@override $HabitCopyWith<$Res> get habit;@override $HabitStreakCopyWith<$Res> get streak;

}
/// @nodoc
class __$HabitWithStatusCopyWithImpl<$Res>
    implements _$HabitWithStatusCopyWith<$Res> {
  __$HabitWithStatusCopyWithImpl(this._self, this._then);

  final _HabitWithStatus _self;
  final $Res Function(_HabitWithStatus) _then;

/// Create a copy of HabitWithStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habit = null,Object? isDone = null,Object? streak = null,}) {
  return _then(_HabitWithStatus(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as HabitStreak,
  ));
}

/// Create a copy of HabitWithStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of HabitWithStatus
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
