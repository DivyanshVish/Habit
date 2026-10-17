// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watch_habit_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WatchHabitDetailParams {

 String get habitId;
/// Create a copy of WatchHabitDetailParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WatchHabitDetailParamsCopyWith<WatchHabitDetailParams> get copyWith => _$WatchHabitDetailParamsCopyWithImpl<WatchHabitDetailParams>(this as WatchHabitDetailParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WatchHabitDetailParams&&(identical(other.habitId, habitId) || other.habitId == habitId));
}


@override
int get hashCode => Object.hash(runtimeType,habitId);

@override
String toString() {
  return 'WatchHabitDetailParams(habitId: $habitId)';
}


}

/// @nodoc
abstract mixin class $WatchHabitDetailParamsCopyWith<$Res>  {
  factory $WatchHabitDetailParamsCopyWith(WatchHabitDetailParams value, $Res Function(WatchHabitDetailParams) _then) = _$WatchHabitDetailParamsCopyWithImpl;
@useResult
$Res call({
 String habitId
});




}
/// @nodoc
class _$WatchHabitDetailParamsCopyWithImpl<$Res>
    implements $WatchHabitDetailParamsCopyWith<$Res> {
  _$WatchHabitDetailParamsCopyWithImpl(this._self, this._then);

  final WatchHabitDetailParams _self;
  final $Res Function(WatchHabitDetailParams) _then;

/// Create a copy of WatchHabitDetailParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habitId = null,}) {
  return _then(_self.copyWith(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WatchHabitDetailParams].
extension WatchHabitDetailParamsPatterns on WatchHabitDetailParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WatchHabitDetailParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WatchHabitDetailParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WatchHabitDetailParams value)  $default,){
final _that = this;
switch (_that) {
case _WatchHabitDetailParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WatchHabitDetailParams value)?  $default,){
final _that = this;
switch (_that) {
case _WatchHabitDetailParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String habitId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WatchHabitDetailParams() when $default != null:
return $default(_that.habitId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String habitId)  $default,) {final _that = this;
switch (_that) {
case _WatchHabitDetailParams():
return $default(_that.habitId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String habitId)?  $default,) {final _that = this;
switch (_that) {
case _WatchHabitDetailParams() when $default != null:
return $default(_that.habitId);case _:
  return null;

}
}

}

/// @nodoc


class _WatchHabitDetailParams implements WatchHabitDetailParams {
  const _WatchHabitDetailParams({required this.habitId});
  

@override final  String habitId;

/// Create a copy of WatchHabitDetailParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WatchHabitDetailParamsCopyWith<_WatchHabitDetailParams> get copyWith => __$WatchHabitDetailParamsCopyWithImpl<_WatchHabitDetailParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WatchHabitDetailParams&&(identical(other.habitId, habitId) || other.habitId == habitId));
}


@override
int get hashCode => Object.hash(runtimeType,habitId);

@override
String toString() {
  return 'WatchHabitDetailParams(habitId: $habitId)';
}


}

/// @nodoc
abstract mixin class _$WatchHabitDetailParamsCopyWith<$Res> implements $WatchHabitDetailParamsCopyWith<$Res> {
  factory _$WatchHabitDetailParamsCopyWith(_WatchHabitDetailParams value, $Res Function(_WatchHabitDetailParams) _then) = __$WatchHabitDetailParamsCopyWithImpl;
@override @useResult
$Res call({
 String habitId
});




}
/// @nodoc
class __$WatchHabitDetailParamsCopyWithImpl<$Res>
    implements _$WatchHabitDetailParamsCopyWith<$Res> {
  __$WatchHabitDetailParamsCopyWithImpl(this._self, this._then);

  final _WatchHabitDetailParams _self;
  final $Res Function(_WatchHabitDetailParams) _then;

/// Create a copy of WatchHabitDetailParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habitId = null,}) {
  return _then(_WatchHabitDetailParams(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
