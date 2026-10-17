// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_streak.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StreakDay {

 DateKey get date; DayStatus get status; bool get isToday;
/// Create a copy of StreakDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakDayCopyWith<StreakDay> get copyWith => _$StreakDayCopyWithImpl<StreakDay>(this as StreakDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakDay&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.isToday, isToday) || other.isToday == isToday));
}


@override
int get hashCode => Object.hash(runtimeType,date,status,isToday);

@override
String toString() {
  return 'StreakDay(date: $date, status: $status, isToday: $isToday)';
}


}

/// @nodoc
abstract mixin class $StreakDayCopyWith<$Res>  {
  factory $StreakDayCopyWith(StreakDay value, $Res Function(StreakDay) _then) = _$StreakDayCopyWithImpl;
@useResult
$Res call({
 DateKey date, DayStatus status, bool isToday
});




}
/// @nodoc
class _$StreakDayCopyWithImpl<$Res>
    implements $StreakDayCopyWith<$Res> {
  _$StreakDayCopyWithImpl(this._self, this._then);

  final StreakDay _self;
  final $Res Function(StreakDay) _then;

/// Create a copy of StreakDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? status = null,Object? isToday = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateKey,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DayStatus,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakDay].
extension StreakDayPatterns on StreakDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakDay value)  $default,){
final _that = this;
switch (_that) {
case _StreakDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakDay value)?  $default,){
final _that = this;
switch (_that) {
case _StreakDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateKey date,  DayStatus status,  bool isToday)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakDay() when $default != null:
return $default(_that.date,_that.status,_that.isToday);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateKey date,  DayStatus status,  bool isToday)  $default,) {final _that = this;
switch (_that) {
case _StreakDay():
return $default(_that.date,_that.status,_that.isToday);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateKey date,  DayStatus status,  bool isToday)?  $default,) {final _that = this;
switch (_that) {
case _StreakDay() when $default != null:
return $default(_that.date,_that.status,_that.isToday);case _:
  return null;

}
}

}

/// @nodoc


class _StreakDay implements StreakDay {
  const _StreakDay({required this.date, required this.status, required this.isToday});
  

@override final  DateKey date;
@override final  DayStatus status;
@override final  bool isToday;

/// Create a copy of StreakDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakDayCopyWith<_StreakDay> get copyWith => __$StreakDayCopyWithImpl<_StreakDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakDay&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.isToday, isToday) || other.isToday == isToday));
}


@override
int get hashCode => Object.hash(runtimeType,date,status,isToday);

@override
String toString() {
  return 'StreakDay(date: $date, status: $status, isToday: $isToday)';
}


}

/// @nodoc
abstract mixin class _$StreakDayCopyWith<$Res> implements $StreakDayCopyWith<$Res> {
  factory _$StreakDayCopyWith(_StreakDay value, $Res Function(_StreakDay) _then) = __$StreakDayCopyWithImpl;
@override @useResult
$Res call({
 DateKey date, DayStatus status, bool isToday
});




}
/// @nodoc
class __$StreakDayCopyWithImpl<$Res>
    implements _$StreakDayCopyWith<$Res> {
  __$StreakDayCopyWithImpl(this._self, this._then);

  final _StreakDay _self;
  final $Res Function(_StreakDay) _then;

/// Create a copy of StreakDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? status = null,Object? isToday = null,}) {
  return _then(_StreakDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateKey,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DayStatus,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$HabitStreak {

 List<StreakDay> get days;/// Consecutive done days ending today, or ending yesterday while today is
/// still open. Only looks inside [days].
 int get currentStreak;
/// Create a copy of HabitStreak
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitStreakCopyWith<HabitStreak> get copyWith => _$HabitStreakCopyWithImpl<HabitStreak>(this as HabitStreak, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitStreak&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days),currentStreak);

@override
String toString() {
  return 'HabitStreak(days: $days, currentStreak: $currentStreak)';
}


}

/// @nodoc
abstract mixin class $HabitStreakCopyWith<$Res>  {
  factory $HabitStreakCopyWith(HabitStreak value, $Res Function(HabitStreak) _then) = _$HabitStreakCopyWithImpl;
@useResult
$Res call({
 List<StreakDay> days, int currentStreak
});




}
/// @nodoc
class _$HabitStreakCopyWithImpl<$Res>
    implements $HabitStreakCopyWith<$Res> {
  _$HabitStreakCopyWithImpl(this._self, this._then);

  final HabitStreak _self;
  final $Res Function(HabitStreak) _then;

/// Create a copy of HabitStreak
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,Object? currentStreak = null,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<StreakDay>,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitStreak].
extension HabitStreakPatterns on HabitStreak {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitStreak value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitStreak() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitStreak value)  $default,){
final _that = this;
switch (_that) {
case _HabitStreak():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitStreak value)?  $default,){
final _that = this;
switch (_that) {
case _HabitStreak() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StreakDay> days,  int currentStreak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitStreak() when $default != null:
return $default(_that.days,_that.currentStreak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StreakDay> days,  int currentStreak)  $default,) {final _that = this;
switch (_that) {
case _HabitStreak():
return $default(_that.days,_that.currentStreak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StreakDay> days,  int currentStreak)?  $default,) {final _that = this;
switch (_that) {
case _HabitStreak() when $default != null:
return $default(_that.days,_that.currentStreak);case _:
  return null;

}
}

}

/// @nodoc


class _HabitStreak extends HabitStreak {
  const _HabitStreak({required final  List<StreakDay> days, required this.currentStreak}): _days = days,super._();
  

 final  List<StreakDay> _days;
@override List<StreakDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

/// Consecutive done days ending today, or ending yesterday while today is
/// still open. Only looks inside [days].
@override final  int currentStreak;

/// Create a copy of HabitStreak
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitStreakCopyWith<_HabitStreak> get copyWith => __$HabitStreakCopyWithImpl<_HabitStreak>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitStreak&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days),currentStreak);

@override
String toString() {
  return 'HabitStreak(days: $days, currentStreak: $currentStreak)';
}


}

/// @nodoc
abstract mixin class _$HabitStreakCopyWith<$Res> implements $HabitStreakCopyWith<$Res> {
  factory _$HabitStreakCopyWith(_HabitStreak value, $Res Function(_HabitStreak) _then) = __$HabitStreakCopyWithImpl;
@override @useResult
$Res call({
 List<StreakDay> days, int currentStreak
});




}
/// @nodoc
class __$HabitStreakCopyWithImpl<$Res>
    implements _$HabitStreakCopyWith<$Res> {
  __$HabitStreakCopyWithImpl(this._self, this._then);

  final _HabitStreak _self;
  final $Res Function(_HabitStreak) _then;

/// Create a copy of HabitStreak
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? currentStreak = null,}) {
  return _then(_HabitStreak(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<StreakDay>,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
