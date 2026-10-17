// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'toggle_habit_completion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ToggleHabitCompletionParams {

 String get habitId; DateKey get dateKey; bool get done;
/// Create a copy of ToggleHabitCompletionParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToggleHabitCompletionParamsCopyWith<ToggleHabitCompletionParams> get copyWith => _$ToggleHabitCompletionParamsCopyWithImpl<ToggleHabitCompletionParams>(this as ToggleHabitCompletionParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleHabitCompletionParams&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.done, done) || other.done == done));
}


@override
int get hashCode => Object.hash(runtimeType,habitId,dateKey,done);

@override
String toString() {
  return 'ToggleHabitCompletionParams(habitId: $habitId, dateKey: $dateKey, done: $done)';
}


}

/// @nodoc
abstract mixin class $ToggleHabitCompletionParamsCopyWith<$Res>  {
  factory $ToggleHabitCompletionParamsCopyWith(ToggleHabitCompletionParams value, $Res Function(ToggleHabitCompletionParams) _then) = _$ToggleHabitCompletionParamsCopyWithImpl;
@useResult
$Res call({
 String habitId, DateKey dateKey, bool done
});




}
/// @nodoc
class _$ToggleHabitCompletionParamsCopyWithImpl<$Res>
    implements $ToggleHabitCompletionParamsCopyWith<$Res> {
  _$ToggleHabitCompletionParamsCopyWithImpl(this._self, this._then);

  final ToggleHabitCompletionParams _self;
  final $Res Function(ToggleHabitCompletionParams) _then;

/// Create a copy of ToggleHabitCompletionParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habitId = null,Object? dateKey = null,Object? done = null,}) {
  return _then(_self.copyWith(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as DateKey,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ToggleHabitCompletionParams].
extension ToggleHabitCompletionParamsPatterns on ToggleHabitCompletionParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToggleHabitCompletionParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToggleHabitCompletionParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToggleHabitCompletionParams value)  $default,){
final _that = this;
switch (_that) {
case _ToggleHabitCompletionParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToggleHabitCompletionParams value)?  $default,){
final _that = this;
switch (_that) {
case _ToggleHabitCompletionParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String habitId,  DateKey dateKey,  bool done)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToggleHabitCompletionParams() when $default != null:
return $default(_that.habitId,_that.dateKey,_that.done);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String habitId,  DateKey dateKey,  bool done)  $default,) {final _that = this;
switch (_that) {
case _ToggleHabitCompletionParams():
return $default(_that.habitId,_that.dateKey,_that.done);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String habitId,  DateKey dateKey,  bool done)?  $default,) {final _that = this;
switch (_that) {
case _ToggleHabitCompletionParams() when $default != null:
return $default(_that.habitId,_that.dateKey,_that.done);case _:
  return null;

}
}

}

/// @nodoc


class _ToggleHabitCompletionParams implements ToggleHabitCompletionParams {
  const _ToggleHabitCompletionParams({required this.habitId, required this.dateKey, required this.done});
  

@override final  String habitId;
@override final  DateKey dateKey;
@override final  bool done;

/// Create a copy of ToggleHabitCompletionParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleHabitCompletionParamsCopyWith<_ToggleHabitCompletionParams> get copyWith => __$ToggleHabitCompletionParamsCopyWithImpl<_ToggleHabitCompletionParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleHabitCompletionParams&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&(identical(other.done, done) || other.done == done));
}


@override
int get hashCode => Object.hash(runtimeType,habitId,dateKey,done);

@override
String toString() {
  return 'ToggleHabitCompletionParams(habitId: $habitId, dateKey: $dateKey, done: $done)';
}


}

/// @nodoc
abstract mixin class _$ToggleHabitCompletionParamsCopyWith<$Res> implements $ToggleHabitCompletionParamsCopyWith<$Res> {
  factory _$ToggleHabitCompletionParamsCopyWith(_ToggleHabitCompletionParams value, $Res Function(_ToggleHabitCompletionParams) _then) = __$ToggleHabitCompletionParamsCopyWithImpl;
@override @useResult
$Res call({
 String habitId, DateKey dateKey, bool done
});




}
/// @nodoc
class __$ToggleHabitCompletionParamsCopyWithImpl<$Res>
    implements _$ToggleHabitCompletionParamsCopyWith<$Res> {
  __$ToggleHabitCompletionParamsCopyWithImpl(this._self, this._then);

  final _ToggleHabitCompletionParams _self;
  final $Res Function(_ToggleHabitCompletionParams) _then;

/// Create a copy of ToggleHabitCompletionParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habitId = null,Object? dateKey = null,Object? done = null,}) {
  return _then(_ToggleHabitCompletionParams(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as DateKey,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
